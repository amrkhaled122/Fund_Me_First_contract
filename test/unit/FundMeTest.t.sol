// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
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

    function testMinimumDollarIsFive() public {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        assertEq(fundme.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundme.fund{value: 1}();
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundme.getaddressToAmountFunded(User);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFunderToArrayOfFunders() public funded {
        
        vm.prank(User);
        fundme.fund{value: SEND_VALUE};
        address funder = fundme.getFunders(0);
        assertEq(funder, User);
    }

    modifier funded() {
        vm.prank(User);
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testWithdrawIfNotOwnerFails() public funded {
        vm.expectRevert();
        vm.prank(User);
        fundme.withdraw();
    }

    function testWithdrawWithAsingleFunder() public funded {

        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.prank(fundme.getOwner());
        fundme.withdraw();

        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundMeBalance = address(fundme).balance;
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
        assertEq(endingFundMeBalance, 0);
    }

    function testWithdrawFromMultipleFunders() public funded {
 
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
    
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.prank(fundme.getOwner());
        fundme.withdraw();

        assert(startingOwnerBalance + startingFundMeBalance == fundme.getOwner().balance);
        assert(address(fundme).balance == 0);
}
   function testWithdrawFromMultipleFundersCheaper() public funded {

        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }
    
        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundMeBalance = address(fundme).balance;

        vm.prank(fundme.getOwner());
        fundme.cheaperWithdraw();

        assert(startingOwnerBalance + startingFundMeBalance == fundme.getOwner().balance);
        assert(address(fundme).balance == 0);
}
}