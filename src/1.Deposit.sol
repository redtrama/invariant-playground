// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title Deposit
/// @notice A simple native token deposit contract
contract Deposit {
    address public seller = msg.sender;
    mapping(address => uint256) public balance;

    /// @notice Deposit native tokens into the contract
    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    /// @notice Withdraw native tokens from the contract
    function withdraw() external {
        uint256 amount = balance[msg.sender];
        balance[msg.sender] = 0;
        (bool s,) = msg.sender.call{value: amount}("");
        require(s, "failed to send");
    }
}
