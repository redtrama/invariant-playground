// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Deposit} from "../src/1.Deposit.sol";

/// How to run this test:
/// run the whole test:
/// `forge test --mc InvariantDeposit -vvvv`
/// alternatively use --mt for specific invariant function:
/// `forge test --mt invariant_alwaysWithdrawable -vvvv`
contract InvariantDeposit is Test {
    Deposit deposit;

    function setUp() public {
        deposit = new Deposit();
        vm.deal(address(deposit), 100 ether);
    }

    function invariant_alwaysWithdrawable() external payable {
        /// start invariant test as address(0xaa) actor
        vm.startPrank(address(0xaa));
        /// give him 10 ether
        vm.deal(address(0xaa), 10 ether);

        deposit.deposit{value: 1 ether}();
        uint256 balanceBefore = deposit.balance(address(0xaa));
        vm.stopPrank();

        /// we make sure balance is 1 ether after deposit
        assertEq(balanceBefore, 1 ether);

        vm.prank(address(0xaa));
        deposit.withdraw();
        /// we make sure balance is 0 after withdraw
        uint256 balanceAfter = deposit.balance(address(0xaa));
        vm.stopPrank();

        /// when withdrawing we make sure balance is less than before
        assertGt(balanceBefore, balanceAfter);
    }

    receive() external payable {}
}
