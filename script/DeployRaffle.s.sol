// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        /// @notice destructuing ActiveNetworkConfig to it's individual variable with assigned values.
        (
            uint256 entranceFee,
            uint256 interval,
            address vrfCordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit
        ) = helperConfig.activeNetworkConfig();

        if (subscriptionId == 0) {
            
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            entranceFee,
            interval,
            vrfCordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );

        vm.stopBroadcast();

        return (raffle, helperConfig);
    }
}
