// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface ISimpleProxyFactory {
    function deployDeterministic(bytes32 salt, address initialImplementation, bytes memory initCall) external payable returns (address proxy);
    function predictDeterministicAddress(bytes32 salt) external view returns (address addr);
}
