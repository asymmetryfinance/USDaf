// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IWrapper {
    function depositFor(address account, uint256 amount) external returns (bool);
    function withdrawTo(address account, uint256 amount) external returns (bool);
}