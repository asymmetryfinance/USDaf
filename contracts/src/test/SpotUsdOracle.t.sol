// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {SpotUsdOracle} from "../PriceFeeds/SpotUsdOracle.sol";

import "forge-std/Test.sol";
import "lib/forge-std/src/console2.sol";

contract SpotUsdOracleTest is Test {

    SpotUsdOracle public oracle;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"));

        oracle = new SpotUsdOracle();
    }

    function testSpotOracleSanity() public view {
        (, int256 answer,, uint256 updatedAt,) = oracle.latestRoundData();
        assertTrue(answer > 0);
        assertEq(updatedAt, block.timestamp);
    }
}