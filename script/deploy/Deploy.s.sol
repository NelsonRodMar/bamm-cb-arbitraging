// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Script} from "forge-std/Script.sol";
import {BammArbitrage} from "../../src/BammArbitrage.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        BammArbitrage bammArbitrage = new BammArbitrage();
        vm.stopBroadcast();
    }
}