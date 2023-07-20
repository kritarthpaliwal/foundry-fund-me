// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/FundMe.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    HelperConfig helperConfig;
    DeployFundMe deployFundMe;
    address internal USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        deployFundMe = new DeployFundMe();
        (fundMe, helperConfig) = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinUsdIsFive() public {
        assertEq(fundMe.MIN_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersionIsFour() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testUpdatedFundersArray() public {
        vm.prank(USER);

        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(address(USER));
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddressUpdatedToFundersArray() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(USER, funder);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        // withdraw function fails because USER is not owner
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testWithdrawFromASingleFunder() public funded {
        // Arrange
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // vm.txGasPrice(GAS_PRICE);
        // uint256 gasStart = gasleft();
        // // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance // + gasUsed
        );
    }

    function testWithdrawFromMultipleUsers() public {
        //Arrange
        uint160 startingFunderIndex = 1;
        uint160 numberOfFunders = 10;

        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assertEq(address(fundMe).balance, 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
}
