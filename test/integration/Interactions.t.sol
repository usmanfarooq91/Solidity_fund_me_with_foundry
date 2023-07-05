// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract TestFundMeIntegration is Test {

    FundMe s_fundMe;
    address immutable i_user = makeAddr("user123456");
    uint256 constant SEND_VALUE = 10e18;
    uint256 constant STARTING_BALANCE = 100 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        s_fundMe = deployFundMe.run();
        vm.deal(i_user, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(s_fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(s_fundMe));

        assert(address(s_fundMe).balance == 0);
    }
}