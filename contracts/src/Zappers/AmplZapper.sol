// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "./UnwrappedZapper.sol";

contract AmplZapper is UnwrappedZapper {
    using SafeERC20 for IERC20;

    address private constant _AMPL = 0xD46bA6D942050d489DBd938a2C909A5d5039A161;

    constructor(IAddressesRegistry _addressesRegistry) UnwrappedZapper(_addressesRegistry, _AMPL) {}

    function _pullColl(uint256 _amount) internal override {
        unwrappedCollToken.safeTransferFrom(msg.sender, address(this), _amount);
        collToken.depositFor(address(this), _amount);
    }

    function _sendColl(address _receiver, uint256 _amount) internal override {
        collToken.withdrawTo(_receiver, _amount);
    }
}