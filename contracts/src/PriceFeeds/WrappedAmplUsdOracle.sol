// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {OracleLibrary} from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

import "../Dependencies/AggregatorV3Interface.sol";

contract WrappedAmplUsdOracle is AggregatorV3Interface {
    address public constant token0 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // weth
    address public constant token1 = 0xEDB171C18cE90B633DB442f2A6F72874093b49Ef; // wampl
    address public immutable pool;

    AggregatorV3Interface public constant ethUsdOracle = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

    int256 public constant UNIT = 1e8;

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
        (, int256 _ethUsdPrice,,,) = ethUsdOracle.latestRoundData();
        return int256(OracleLibrary.getQuoteAtTick(_tick, uint128(uint256(UNIT)), token1, token0)) * _ethUsdPrice / UNIT;
    }
}