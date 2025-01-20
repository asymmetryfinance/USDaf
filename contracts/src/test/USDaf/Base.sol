// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../../scripts/DeployUSDaf.s.sol";

import "forge-std/Test.sol";

abstract contract Base is DeployUSDafScript, Test {

    address alice;

    function setUp() public virtual {
        vm.selectFork(vm.createFork(vm.envString("MAINNET_RPC_URL")));

        alice = _createUser("Alice");
    }

    function deploy() public returns (DeploymentResult memory) {
        return run();
    }

    function _createUser(
        string memory _name
    ) internal returns (address payable) {
        address payable _user = payable(makeAddr(_name));
        vm.deal({account: _user, newBalance: 10_000 ether});
        deal({token: SPOT, to: _user, give: 10_000 ether});
        deal({token: WETH, to: _user, give: 10_000 ether});
        return _user;
    }
}