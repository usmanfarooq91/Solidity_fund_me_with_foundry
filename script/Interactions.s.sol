// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {

    uint256 constant private SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecenlyDeplyed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecenlyDeplyed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s ETH", SEND_VALUE);
    }

    function run() external{

        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        
        fundFundMe(mostRecentlyDeployed);
        
    }
}

contract WithdrawFundMe is Script {

    function withdrawFundMe(address mostRecenlyDeplyed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecenlyDeplyed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external{

        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        
        withdrawFundMe(mostRecentlyDeployed);
        
    }
}