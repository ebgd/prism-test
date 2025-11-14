// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Interface for the Wisdom Token
 * @dev Defines the functions that the StakingContract will call.
 */
interface IWisdomToken {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
