// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IWrapper} from "./Interfaces/IWrapper.sol";

import "./UnwrappedZapper.sol";

contract SpotZapper is UnwrappedZapper {
    using SafeERC20 for IERC20;

    address private constant _SPOT = 0xC1f33e0cf7e40a67375007104B929E49a581bafE;

    uint256 private constant _DECIMALS_DIFF = 9;

    constructor(IAddressesRegistry _addressesRegistry) UnwrappedZapper(_addressesRegistry, _SPOT) {}

    function _pullColl(uint256 _amount) internal override {
        uint256 collAmountInStrangeDecimals = _amount / 10 ** _DECIMALS_DIFF;
        require(collAmountInStrangeDecimals * 10 ** _DECIMALS_DIFF == _amount, "!precision");
        unwrappedCollToken.safeTransferFrom(msg.sender, address(this), collAmountInStrangeDecimals);
        IWrapper(collToken).depositFor(address(this), collAmountInStrangeDecimals);
    }

    function _sendColl(address _receiver, uint256 _amount) internal override {
        IWrapper(collToken).withdrawTo(_receiver, _amount);
    }
}