// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {WETH9} from "../../src/3.WETH9.sol";
import {Test} from "forge-std/Test.sol";

/// @title Handler for WETH9
/// @notice handler for testing WETH9 invariants
/// @dev Here we define the "Surface Area" of the fuzzer by exposing State Changing functions
/// @dev actors and balances should be defined here as well
/// @author 0xredtrama
contract Handler is Test {
    WETH9 public weth;
    /// We use this for checking the conservation of ETH property
    uint256 public constant ETH_SUPPLY = 120_500_000 ether;

    /// #### GHOST VARIABLES ####
    /// ghost variables are for tracking and account variables that doesn't exists in the
    /// current contract implementation for example the sum of all deposits and withdrawals.
    uint256 public ghost_depositSum;
    uint256 public ghost_withdrawSum;

    constructor(WETH9 _weth) {
        weth = _weth;
        // we give the handler 100 ether
        vm.deal(address(this), ETH_SUPPLY);
    }

    /// #### Surface Area ####
    /// all function declared below this line are the function that we expose to the fuzzer and say
    /// - "hey this is the entrypoint and here's how you use it"

    /// We expose here usually State Changing functions, where we set pre-conditions to the fuzzer to make more
    /// efficient and meaningful fuzz runs.

    /// This function will call random amount values
    /// We test the system as a whole so we give the handler the total supply of ETH
    function deposit(uint256 amount) external payable {
        /// instead of passing an amount between 0 and uint256.max
        /// we just bound this value to be not bigger than ETH_SUPPLY
        amount = bound(amount, 0, address(this).balance);
        /// send ETH to the actor
        _pay(msg.sender, amount);
        /// Add actors
        vm.prank(msg.sender);
        /// deposit ETH to the WETH contract
        weth.deposit{value: amount}();
        /// We add up the ghost variable to track all user deposits
        ghost_depositSum += amount;
    }

    function withdraw(uint256 amount) external {
        /// This function changes WETH token for native ETH
        /// so we bound the input amount to handler WETH balance
        /// this will be enought to avoid reverts due to Not enough balance errors
        uint256 balance = weth.balanceOf(msg.sender);
        vm.assume(balance > 0);
        amount = bound(amount, 1, balance);

        // This fails because amount is zero
        // vm.assume(amount > 0);
        // Add actor
        vm.startPrank(msg.sender);
        weth.withdraw(amount);
        _pay(address(this), amount);
        vm.stopPrank();
        
        ghost_withdrawSum += amount;
    }

    /// @notice WETH9 has a fallback function that calls deposit()
    /// @dev let's give the fuzzer a way to test this behave
    function sendFallback(uint256 amount) public {
        /// send between 0 and the amount of ETH handler has
        uint256 ethBalance = address(this).balance;
        // vm.assume(ethBalance > 0);
        if (ethBalance == 0) {
            return;
        }
        amount = bound(amount, 0, ethBalance);
        _pay(msg.sender, amount);
        /// send non empty data to trigger fallback() instead receive()
        vm.prank(msg.sender);
        (bool success,) = address(weth).call{value: amount}("");

        require(success, "sendFallback failed");
        ghost_depositSum += amount;
    }

    /// @notice function to send ETH from Handler(this) to an actor
    function _pay(address to, uint256 amount) internal {
        /// we use call instead of vm.deal() to use the same token balance within the fuzzer
        (bool success,) = to.call{value: amount}("");
        require(success, "_pay failed");
    }

    /// A receive function is needed to receive ETH when withdraw() is called
    receive() external payable {}

    fallback() external payable {}
}
