// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

interface IERC20Like {
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
}

interface IUniswapV2Router02 {
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface IChainlinkFeed {
    function decimals() external view returns (uint8);
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
}

contract MainnetForkTest is Test {
    string internal constant MAINNET_RPC_URL = "https://ethereum-rpc.publicnode.com";

    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant USDC_WETH_PAIR = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;
    address internal constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address internal constant ETH_USD_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    function testForkReadsMainnetUsdc() public {
        vm.createSelectFork(MAINNET_RPC_URL);

        IERC20Like usdc = IERC20Like(USDC);

        assertEq(usdc.decimals(), 6);
        assertGt(usdc.totalSupply(), 1_000_000_000e6);
        assertGt(usdc.balanceOf(USDC_WETH_PAIR), 0);
    }

    function testForkQuotesUniswapV2WethToUsdc() public {
        vm.createSelectFork(MAINNET_RPC_URL);

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = USDC;

        uint256[] memory amounts = IUniswapV2Router02(UNISWAP_V2_ROUTER).getAmountsOut(1 ether, path);

        assertEq(amounts[0], 1 ether);
        assertGt(amounts[1], 1_000e6);
    }

    function testForkReadsChainlinkEthUsdFeed() public {
        vm.createSelectFork(MAINNET_RPC_URL);

        IChainlinkFeed feed = IChainlinkFeed(ETH_USD_FEED);
        (, int256 answer,, uint256 updatedAt,) = feed.latestRoundData();

        assertEq(feed.decimals(), 8);
        assertGt(answer, 1_000e8);
        assertGt(updatedAt, 0);
    }
}
