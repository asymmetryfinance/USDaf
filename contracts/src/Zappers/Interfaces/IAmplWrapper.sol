// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IAmplWrapper {
    function depositFor(address to, uint256 amples) external returns (uint256);
    function withdrawTo(address to, uint256 amples) external returns (uint256);
    function wrapperToUnderlying(uint256 wamples) external view returns (uint256);
}