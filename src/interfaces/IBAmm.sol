// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IBAmm {
    /**
     * @dev Swaps an amount of LUSD for ETH.
     * @param lusdAmount The amount of LUSD to swap.
     * @param minEthReturn The minimum amount of ETH to receive.
     * @param dest The address to send the ETH to.
     * @return The amount of ETH received.
     */
    function swap(uint lusdAmount, uint minEthReturn, address payable dest) external returns(uint);
}
