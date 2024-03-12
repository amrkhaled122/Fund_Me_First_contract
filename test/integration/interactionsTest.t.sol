// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe,WithdrawFundMe}  from "../../script/interactions.s.sol";

contract interactionsTest is Test {

    FundMe fundme;
    address User = makeAddr("User");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant START_VALUE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployfundme = new DeployFundMe();
        fundme = deployfundme.run();
        vm.deal(User, START_VALUE);
    }

    // function testUserCanFundInteractions () public{
    //    FundFundMe fundFundMe = new FundFundMe();
    //    vm.prank(User);
    //    vm.deal(User, 1e18);
    //    fundFundMe.FundFundme(address(fundme));

    //    address funder = fundme.getFunders(0);
    //    assertEq(funder, User);
    // }

    function testUserCanFundInteractions () public{
       FundFundMe fundFundMe = new FundFundMe();
       fundFundMe.FundFundme(address(fundme));
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundme));
        assert(address(fundme).balance == 0);
    }
}

