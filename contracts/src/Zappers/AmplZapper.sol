// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IAmplWrapper} from "./Interfaces/IAmplWrapper.sol";

import "./UnwrappedZapper.sol";

contract AmplZapper is UnwrappedZapper {
    using SafeERC20 for IERC20;

    address private constant _AMPL = 0xD46bA6D942050d489DBd938a2C909A5d5039A161;

    constructor(IAddressesRegistry _addressesRegistry) UnwrappedZapper(_addressesRegistry, _AMPL) {}

    function _pullColl(uint256 _amount) internal override {
        uint256 amples = IAmplWrapper(collToken).wrapperToUnderlying(_amount) + 1; // +1 due to rounding
        unwrappedCollToken.safeTransferFrom(msg.sender, address(this), amples);
        IAmplWrapper(collToken).depositFor(address(this), amples);
    }

    function _sendColl(address _receiver, uint256 _amount) internal override {
        uint256 amples = IAmplWrapper(collToken).wrapperToUnderlying(_amount);
        IAmplWrapper(collToken).withdrawTo(_receiver, amples);
    }
}