/// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {SideEntranceLenderPool} from "../../src/2.SideEntranceLenderPool.sol";

import {Test} from "forge-std/Test.sol";


contract Handler is Test {
    SideEntranceLenderPool pool;

    bool canWithdraw;

    constructor(SideEntranceLenderPool _pool) {
        /// deploy pool contract
        pool = _pool;

        /// send funds to the handler
        vm.deal(address(this), 10 ether);
    }
    /// this function will be called by the fuzzer
    /// What we do here is to wrap deposit and give the fuzzer 
    /// a clue on how to call it and avoid different errors
    function execute() external payable {
        pool.deposit{value: msg.value}();
        canWithdraw = true;
    }
    /// User should be able to withdraw only when has made a deposit before
    /// This is save fuzz runs
    function withdraw() external {
        if(canWithdraw) pool.withdraw();
    }

    function flashLoan(uint amount) external {
        pool.flashLoan(amount);
    }

    /// Is this receive because we use this test suite as contract?
    receive() external payable {}

}