/// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {WETH9} from "../src/3.WETH9.sol";
import {Handler} from "./handler/WETH9Handler.sol";

contract WETH9Test is Test {
    WETH9 weth;
    Handler handler;

    function setUp() public {
        weth = new WETH9();
        // We deploy the handler
        handler = new Handler(weth);

        /// Set the handler as targetContract
        targetContract(address(handler));
    }

    /// Conservation of ETH through the system invariant
    function invariant_ConservationOfETH() external payable {
        assertEq(handler.ETH_SUPPLY(), address(handler).balance + weth.totalSupply());
    }


    /// NOTE Implement the invariant for matching the total balance with users balances
    // function invariant_solvencyBalances() public view {
    //     uint256 sumOfBalances = 1;
    //     assertEq(address(weth).balance, sumOfBalances);
    // }

    /// We track the sum of all deposits and withdrawals and compare the difference with Weth balance
    function invariant_SolvencyDeposits() external view {
        assertEq(address(weth).balance, handler.ghost_depositSum() - handler.ghost_withdrawSum());
    }


    /// Adding this function made the test SolvencyDeposits() pass
    receive() external payable {}

    fallback() external payable {}
}
