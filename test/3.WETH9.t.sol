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

    /*///////////////////////////////////////////////////////////////
                            INVARIANTS
    //////////////////////////////////////////////////////////////*/

    /// INVARIANT 1) The ETH amount supply should be equal to the sum of handler eth balance and weth total supply
    function invariant_ConservationOfETH() external payable {
        assertEq(handler.ETH_SUPPLY(), address(handler).balance + weth.totalSupply());
    }

    /// INVARIANT 2) Eth balance in WETH shoud be equal to the difference between all deposits and all withdrawals
    function invariant_SolvencyDeposits() external view {
        assertEq(address(weth).balance, handler.ghost_depositSum() - handler.ghost_withdrawSum());
    }

    /// INVARIANT 3) ETH balance in WETH should be equal to the total supply of WETH
    function invariant_ETHbalanceEqToWethSupply() public view {
        assertEq(address(weth).balance, weth.totalSupply());
    }

    /// @dev Helper function to calculate sum of all WETH balances across actors
    function _sumOfBalances() internal view returns (uint256) {
        uint256 sumOfAllBalances;
        address[] memory actors = handler.actors();

        for (uint256 i; i < actors.length; i++) {
            sumOfAllBalances += weth.balanceOf(actors[i]);
        }

        return sumOfAllBalances;
    }

    /// INVARIANT 4) The ETH balance on WETH should be equal to the sum of all deposits
    /// For implementing this one we need to track balances of all users
    /// Once we have the actor arrays we can sum up all the balances of all users and compare it with the WETH balance
    /// NOTE it may take longer since it has to loop through all actors
    function invariant_ETHbalanceEqToSumOfDeposits() public view {
        uint256 sumOfAllBalances = _sumOfBalances();
        assertEq(address(weth).balance, sumOfAllBalances);
    }

    /// INVARIANT 5) sum of all balances should not exceed total supply
    function invariant_sumOfBalancesShouldNotExceedSupply() public view {
        uint256 sumOfAllBalances = _sumOfBalances();
        assertLe(sumOfAllBalances, weth.totalSupply());
    }

    /// INVARIANT 6) user balance not higher than the total supply
    function invariant_userBalanceNotHigherThanTotalSupply() public view {
        assertLe(weth.balanceOf(msg.sender), weth.totalSupply());
    }

    /// Adding this function made the test SolvencyDeposits() pass
    receive() external payable {}

    fallback() external payable {}
}
