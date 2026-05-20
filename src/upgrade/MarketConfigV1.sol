// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";

contract MarketConfigV1 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    uint256 public marketCreationFee;
    uint256 public disputeWindow;
    address public treasury;

    event MarketCreationFeeUpdated(uint256 oldFee, uint256 newFee);
    event DisputeWindowUpdated(uint256 oldWindow, uint256 newWindow);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, address initialTreasury, uint256 initialFee, uint256 initialDisputeWindow)
        public
        initializer
    {
        require(initialTreasury != address(0), "treasury zero");
        require(initialDisputeWindow >= 1 hours, "window too short");
        __Ownable_init(initialOwner);
        marketCreationFee = initialFee;
        disputeWindow = initialDisputeWindow;
        treasury = initialTreasury;
    }

    function setMarketCreationFee(uint256 newFee) external onlyOwner {
        emit MarketCreationFeeUpdated(marketCreationFee, newFee);
        marketCreationFee = newFee;
    }

    function setDisputeWindow(uint256 newWindow) external onlyOwner {
        require(newWindow >= 1 hours, "window too short");
        emit DisputeWindowUpdated(disputeWindow, newWindow);
        disputeWindow = newWindow;
    }

    function setTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), "treasury zero");
        emit TreasuryUpdated(treasury, newTreasury);
        treasury = newTreasury;
    }

    function version() external pure virtual returns (string memory) {
        return "1.0.0";
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
