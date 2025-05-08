// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, Vm, console} from "forge-std/Test.sol";

import {SideEntranceLenderPool} from "../src/2.SideEntranceLenderPool.sol";
import {Handler} from "./handler/handler.sol";

contract InvariantSideEntranceLenderPool is Test {
    SideEntranceLenderPool pool;
    Handler handler;

    /// Pool is deployed here and in handler as well
    function setUp() public {
        /// Deploy the contract with 25 ether
        pool = new SideEntranceLenderPool{value: 25 ether}();

        /// Deploy the handler
        handler = new Handler(pool);

        /// Set the handler as the target
        targetContract(address(handler));
    }

    /// #### Invariants ####
    /// Statements that should always be true

    /// 1. Balance of the pool should be equl or greater than initial balance
    /// NOTE this was failing at first, and it found the issue by changing depth in foundry.toml from 23 to 230
    // function invariant_PoolBalaneEgThanInitialBalance() external view {
    //     assert(address(pool).balance >= pool.initialPoolBalance());
    // }
}
