// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IAmplWrapper {
    function burnTo(address to, uint256 wamples) external returns (uint256);
    function depositFor(address to, uint256 amples) external returns (uint256);
    function withdrawTo(address to, uint256 amples) external returns (uint256);
    function wrapperToUnderlying(uint256 wamples) external view returns (uint256);
    function mint(uint256 wamples) external returns (uint256);
}