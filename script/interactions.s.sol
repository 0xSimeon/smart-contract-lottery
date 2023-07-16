// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract CreateSubscription is Script {
    /// @dev Programmatically create subscription.
    function createSubscriptionUsingConfig() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCordinator, , , ) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCordinator);
    }

/// @dev Helper function to create the subscription using the VRFV2CoMock
    function createSubscription(address vrfCordinator) public returns (uint64) {
        console.log("Creating Subscription....", block.chainid);

        vm.startBroadcast();
        uint64 subId = VRFCoordinatorV2Mock(vrfCordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Your sub Id is:", subId);
        console.log(
            "Please proceed to update your subscriptionId in HelperConfig.s.sol "
        );

        return subId;
    }

    function run() external returns (uint64) {
        return createSubscriptionUsingConfig();
    }
}
