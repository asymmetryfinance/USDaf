// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {OracleLibrary} from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

import "../Dependencies/AggregatorV3Interface.sol";

contract SpotUsdOracle is AggregatorV3Interface {
    address public constant token0 = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // usdc
    address public constant token1 = 0xC1f33e0cf7e40a67375007104B929E49a581bafE; // spot
    address public immutable pool;

    AggregatorV3Interface public constant usdcUsdOracle = AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);

    int256 public constant UNIT = 1e8;
    int256 private constant TOKEN0_DECIMALS = 1e6;
    uint128 private constant TOKEN1_DECIMALS = 1e9;

    constructor() {
        address _univ3Factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
        address _pool = IUniswapV3Factory(_univ3Factory).getPool(token0, token1, 10000);
        if (_pool == address(0)) revert("!POOL");
        pool = _pool;
    }

    function decimals() external pure override returns (uint8) {
        return 8;
    }

    function latestRoundData()
        external
        view
        override
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (0, _calcPrice(), 0, block.timestamp, 0);
    }

    function _calcPrice() private view returns (int256) {
        (int24 _tick,) = OracleLibrary.consult(
            pool,
            300 // secondsAgo
        );
        (, int256 _usdcUsdOracle,,,) = usdcUsdOracle.latestRoundData();
        return int256(OracleLibrary.getQuoteAtTick(_tick, TOKEN1_DECIMALS, token1, token0)) * (UNIT / TOKEN0_DECIMALS)
            * _usdcUsdOracle / UNIT;
    }
}
