pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "../Owned.sol";

contract MarketState is Owned {
    mapping(uint256 => MarketInfo) markets;

    struct ProfitInfo {
        bool isWithDraw;
        uint256 total;
        uint256 count;
    }

    struct MarketInfo {
        uint256 subPrice;
        uint256 depositAmount;
        uint8 inviteRatio;
        uint8 commissionRatio;
        address withdrawAddr;
        uint64 createTime;
        mapping(uint64 => ProfitInfo) profits;
        mapping(address => address) subOwners;
        //股东
    }

    constructor(address _owner) public Owned(_owner){

    }

    function getMarketInfo(uint256 _ocId) external view onlyOwner returns (uint256, uint8, uint8, address, uint64){
        MarketInfo memory market = markets[_ocId];
        return (market.subPrice, market.inviteRatio, market.commissionRatio, market.withdrawAddr, market.createTime);
    }

    function addProfit(uint256 _ocId, address _subAddr, uint64 _cycle, uint256 _profit, address _subOwner) external onlyOwner {
        MarketInfo storage marketInfo = markets[_ocId];
        ProfitInfo storage profitInfo = marketInfo.profits[_cycle];
        profitInfo.total = profitInfo.total + _profit;
        profitInfo.count++;
        marketInfo.subOwners[_subAddr] = _subOwner;
    }

    function getSubOwner(uint256 _ocId, address _subAddr) external onlyOwner returns (address) {
        return markets[_ocId].subOwners[_subAddr];
    }

    function withdraw(uint256 _ocId, uint64 _cycle) external onlyOwner returns (uint256){
        ProfitInfo memory profitInfo = markets[_ocId].profits[_cycle];
        if (profitInfo.isWithDraw || profitInfo.total == 0) {
            return 0;
        }
        profitInfo.isWithDraw = true;
        return profitInfo.total;
    }

    function addMarket(uint256 _ocId, uint256 _subPrice, uint256 _depositAmount, uint8 _inviteRatio, uint8 _commissionRatio, address _withdrawAddr) external onlyOwner {
        markets[_ocId] = MarketInfo(_subPrice, _depositAmount, _inviteRatio, _commissionRatio, _withdrawAddr, uint64(block.timestamp));
    }


    function isInMarket(uint256 _ocId) public view onlyOwner returns (bool) {
        return markets[_ocId].createTime > 0;
    }

}