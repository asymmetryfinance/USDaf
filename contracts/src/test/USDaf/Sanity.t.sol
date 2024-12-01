// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "./Base.sol";

contract SanityTest is Base {

    function setUp() override public {
        super.setUp();
    }

    function testSanity() public {
        DeploymentResult memory _deployment = deploy();
        LiquityContractsTestnet memory _contracts = _deployment.contractsArray[0];

        uint256 _collAmountInSpot = 4000e9;
        uint256 _collAmount = 4000e18;
        uint256 _boldAmount = 2000e18;
        uint256 _annualInterestRate = 1e17;

        vm.startPrank(alice);

        IERC20(SPOT).approve(address(wrappedSpot), _collAmountInSpot);
        WrappedSpot(wrappedSpot).depositFor(alice, _collAmountInSpot);

        IERC20(wrappedSpot).approve(address(_contracts.borrowerOperations), _collAmount);
        IERC20(WETH).approve(address(_contracts.borrowerOperations), type(uint256).max);
        _contracts.borrowerOperations.openTrove(
            alice,
            0,
            _collAmount,
            _boldAmount,
            0, // _upperHint
            0, // _lowerHint
            _annualInterestRate,
            _deployment.hintHelpers.predictOpenTroveUpfrontFee(0, _boldAmount, _annualInterestRate),
            address(0),
            address(0),
            address(0)
        );
        vm.stopPrank();
    }

    function testWSPOT(uint256 _amount) public {
        vm.assume(_amount > 0 && _amount < 1_000 ether);

        deploy();

        WrappedSpot wspot = WrappedSpot(wrappedSpot);

        assertEq(wspot.decimals(), 18, "testWSPOT: E0");

        uint256 _aliceBalanceBefore = IERC20(SPOT).balanceOf(alice);

        vm.startPrank(alice);

        IERC20(SPOT).approve(address(wspot), _amount);
        wspot.depositFor(alice, _amount);

        assertEq(wspot.balanceOf(alice), _amount * 10 ** 9, "testWSPOT: E1");
        assertEq(IERC20(SPOT).balanceOf(alice), _aliceBalanceBefore - _amount, "testWSPOT: E2");
        assertEq(IERC20(SPOT).balanceOf(address(wspot)), _amount, "testWSPOT: E2");

        wspot.withdrawTo(alice, _amount * 10 ** 9);

        assertEq(wspot.balanceOf(alice), 0, "testWSPOT: E3");
        assertEq(IERC20(SPOT).balanceOf(alice), _aliceBalanceBefore, "testWSPOT: E4");
        assertEq(IERC20(SPOT).balanceOf(address(wspot)), 0, "testWSPOT: E5");

        vm.stopPrank();
    }
}