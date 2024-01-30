// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

import './PeripheryImmutableState.sol';
import '../interfaces/IPoolInitializer.sol';

/// @title Creates and initializes V3 Pools
abstract contract PoolInitializer is IPoolInitializer, PeripheryImmutableState {

    // 创建交易对
    /// @inheritdoc IPoolInitializer
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96    // 初始价格
    ) external payable override returns (address pool) {
        require(token0 < token1);
        // token0、token1、fee 三个参数确定一个交易对
        // 通过调用工厂合约来查询交易对池子是否存在
        pool = IUniswapV3Factory(factory).getPool(token0, token1, fee);

        // 如果交易对不存在
        if (pool == address(0)) {
            // 创建交易对池子
            pool = IUniswapV3Factory(factory).createPool(token0, token1, fee);
            // 初始化交易对池子
            IUniswapV3Pool(pool).initialize(sqrtPriceX96);
        } else {
            (uint160 sqrtPriceX96Existing, , , , , , ) = IUniswapV3Pool(pool).slot0();
            if (sqrtPriceX96Existing == 0) {
                IUniswapV3Pool(pool).initialize(sqrtPriceX96);
            }
        }
    }
}
