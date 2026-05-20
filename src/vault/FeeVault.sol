// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";

contract FeeVault is ERC4626, Ownable {
    constructor(ERC20 asset_, address owner_)
        ERC20("PredictX LP Fee Vault", "pxVAULT")
        ERC4626(asset_)
        Ownable(owner_)
    {}

    function sweep(address to, uint256 assets) external onlyOwner {
        withdraw(assets, to, msg.sender);
    }
}
