// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title Sample Raffle Contract
 * @author Simeon Udoh & Patick Collins
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFv2
 */

contract Raffle is VRFConsumerBaseV2 {
    error Raffle__NotEnoughETHSent();
    error Raffle__TransferFailed();
    error Raffle__NotOpen();
    error Raffle__UpkeepNotNeeded(
        uint256 currentBalance,
        uint256 numPlayers,
        uint256 raffleState
    );

    /// @dev type declarations.

    enum RaffleState {
        OPEN, //Converted to integers => 0
        CALCULATING //Converted to integers => 1
    }

    /// @dev State Variables.
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;
    // @dev Duration of the lottery in seconds.
    uint256 private immutable i_interval;
    // Chainlink VRF cordinator address
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    // persisted timestamp storage
    address payable[] private s_players;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    /**
     * @dev Events
     */
    event EnteredRaffle(address indexed player);
    event PickedWinner(address indexed winner);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;

        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        // Checks - require, if, erros, etc.
        // Effects
        // Interactions.

        // Short circuit if msg.value is less than the specified entrace fee at deployment.
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughETHSent(); // Custom error instead of require for gas purposes.
        }

        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__NotOpen();
        }

        // Add depositor to list of players.
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    /**
    @dev This is the function that the Chainlink Automation nodes call to see if it is time to perform an upkeep. 
    * The following should be true for this to return true. 
    * 1. The time interval has passed between the raffle runs. 
    * 2. The raffle is in the OPEN state. 
    * 3. The contract has ETH in its balance (aka players have sent ETH to the contract).
    * 4. (Implicit) the subcription is funded with LINK
    */
    function checkUpkeep(
        bytes memory /*checkData*/
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool timeHasPassed = (block.timestamp - s_lastTimeStamp) >= i_interval;
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x0");
    }

    // 1. Get a random number.
    // 2. Use the random number to pick a player.
    // 3. Be automatically called.  No manual calls.
    function performUpkeep(bytes calldata /* performData */) external {
        // Check if enough time has passed.
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }

        i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
    }

    function fulfillRandomWords(
        uint256 /* requestId */,
        uint256[] memory randomWords
    ) internal override {
        /// @dev Getting random number and  randomly selecting the winner.
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        s_raffleState = RaffleState.OPEN;

        /// @dev Reset the array so that old players can't play for free again.
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp; // update new timestamp.

        emit PickedWinner(winner);

        (bool success, ) = s_recentWinner.call{value: address(this).balance}(
            ""
        );
        if (!success) {
            revert Raffle__TransferFailed();
        }
    }

    /** Getter Functions */
    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_raffleState;
    }

    function getPlayer(uint256 indexOfPlayer) external view returns (address) {
        return s_players[indexOfPlayer];
    }

}
