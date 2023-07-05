// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract TestFundMe is Test {

    FundMe s_fundMe;
    address immutable i_user = makeAddr("user123456");
    uint256 constant SEND_VALUE = 10e18;
    uint256 constant STARTING_BALANCE = 100 ether;


    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        s_fundMe = deployFundMe.run();
        vm.deal(i_user, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        assertEq(s_fundMe.getMinimumUsd(), 5 * 10e18);
    }

    function testMsgSenderIsOwner() public {
        assertEq(s_fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        assertEq(s_fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        s_fundMe.fund();
    }

    modifier funded() {
        vm.prank(i_user);
        s_fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded{
        assertEq(s_fundMe.getAddressToAmountFunded(i_user), SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded{
        assertEq(s_fundMe.getFunder(0), i_user);
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.expectRevert();
        vm.prank(i_user);
        s_fundMe.withdraw();
    }

    function testWithdrawWithSinleFunder() public funded{
        uint256 startingOwnerBalance = s_fundMe.getOwner().balance;
        uint256 startingFundMeBalnce = address(s_fundMe).balance;

        vm.prank(s_fundMe.getOwner());
        s_fundMe.withdraw();

        uint256 endingOwnerBalance = s_fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(s_fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalnce, endingOwnerBalance);

    }

    function testWithdrawFromMultipleFunders() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), STARTING_BALANCE);
            s_fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = s_fundMe.getOwner().balance;
        uint256 startingFundMeBalnce = address(s_fundMe).balance;

        vm.startPrank(s_fundMe.getOwner());
        s_fundMe.withdraw();
        vm.stopPrank();

        assertEq(address(s_fundMe).balance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalnce, s_fundMe.getOwner().balance);


    }

    function testWithdrawFromMultipleFundersCheaper() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders; i++){
            hoax(address(i), STARTING_BALANCE);
            s_fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = s_fundMe.getOwner().balance;
        uint256 startingFundMeBalnce = address(s_fundMe).balance;

        vm.startPrank(s_fundMe.getOwner());
        s_fundMe.cheaperWithdraw();
        vm.stopPrank();

        assertEq(address(s_fundMe).balance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalnce, s_fundMe.getOwner().balance);


    }

}