// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract AssemblyMath {
    function quoteSolidity(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) external pure returns (uint256) {
        require(amountIn > 0, "amount zero");
        require(reserveIn > 0 && reserveOut > 0, "liquidity zero");
        uint256 amountInWithFee = amountIn * 9970;
        return (amountInWithFee * reserveOut) / (reserveIn * 10000 + amountInWithFee);
    }

    function quoteYul(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        external
        pure
        returns (uint256 amountOut)
    {
        require(amountIn > 0, "amount zero");
        require(reserveIn > 0 && reserveOut > 0, "liquidity zero");
        assembly {
            let amountInWithFee := mul(amountIn, 9970)
            let numerator := mul(amountInWithFee, reserveOut)
            let denominator := add(mul(reserveIn, 10000), amountInWithFee)
            amountOut := div(numerator, denominator)
        }
    }
}
