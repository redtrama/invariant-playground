// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct AddressSet {
    address[] addrs;
    mapping(address => bool) saved;
}
/// @notice Library to store Addresses into an array
/// @dev this is for tracking all users in the system

library LibAddressSet {
    /// @dev add an address to the array
    function add(AddressSet storage s, address addr) internal {
        if (!s.saved[addr]) {
            s.addrs.push(addr);
            s.saved[addr] = true;
        }
    }

    /// @dev check if an address is in the array
    function contains(AddressSet storage s, address addr) internal view returns (bool) {
        return s.saved[addr];
    }

    /// @dev get the number of addresses in the array
    function count(AddressSet storage s) internal view returns (uint256) {
        return s.addrs.length;
    }
}
