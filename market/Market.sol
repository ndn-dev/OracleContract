pragma solidity ^0.6.12;

import "../oracle/manager/IOracleManager.sol";
import "../Owned.sol";
import "./Funds.sol";
import "./IMarket.sol";
import "./MarketState.sol";

contract Market is IMarket, Owned {
    address public fundsAddr;

    address public oracleManagerAddr;

    address public state;

    constructor(address _owner, address _fundsAddr, address _oracleManagerAddr, address _state) public Owned(_owner){
        fundsAddr = _fundsAddr;
        oracleManagerAddr = _oracleManagerAddr;
        state = _state;
    }

    function subscribeOracle(uint256 _ocId, uint256 _amount, address _subAddr, address _inviteAddr) override external {

        require(isInMarket(_ocId), "not in market");
        address subOwner = MarketState(state).getSubOwner(_ocId, _subAddr);
        require(subOwner == address(0) || subOwner == msg.sender, "no permission");
        (uint256 subPrice, uint8 inviteRatio, uint8 commissionRatio, ,) = MarketState(state).getMarketInfo(_ocId);
        require(_amount == subPrice, "invalid amount");
        (uint64 expireTime, bool first) = IOracleManager(oracleManagerAddr).subscribeOracle(_ocId, _subAddr, subPrice);
        Funds(fundsAddr).transferIn(msg.sender, subPrice);
        uint256 inviteAmount = 0;
        uint256 commissionAmount = 0;
        if (first) {
            if(inviteRatio > 0 && _inviteAddr != address(0)) {
                inviteAmount = (inviteRatio * subPrice) / 100;
                Funds(fundsAddr).transferOut(_inviteAddr, inviteAmount);
            }
        } else {
            commissionAmount = (commissionRatio * subPrice) / 100;
            //放到股东奖励池一部分
        }
        uint256 profitAmount = _amount - inviteAmount - commissionAmount;
        MarketState(state).addProfit(_ocId, _subAddr, expireTime / 4 weeks, profitAmount, msg.sender);
        emit newSubscribe(_ocId, _subAddr, _inviteAddr, _amount);

    }


    function withdrawProfit(uint256 _ocId, uint64 _startTime, uint64 _endTime) override external {
        require(isInMarket(_ocId), "not in market");
        MarketState marketState = MarketState(state);
        (, , , address withdrawAddr, uint64 createTime) = marketState.getMarketInfo(_ocId);
        require(withdrawAddr == msg.sender, "no permission");
        uint64 now = uint64(block.timestamp);
        require(_endTime >= _startTime && _endTime <= now - 5 weeks && _startTime > createTime, "invalid time");
        uint256 total = 0;
        for (uint64 i = _startTime / 4 weeks; i <= _endTime / 4 weeks; i++) {
            total += marketState.withdraw(_ocId, i);
        }
        require(total > 0, "The withdrawal amount is 0");
        Funds(fundsAddr).transferOut(msg.sender, total);

    }

    function applyMarket(uint256 _ocId, uint256 _subPrice, uint256 _depositAmount, uint8 _inviteRatio, uint8 _commissionRatio, address _withdrawAddr) override external {
        require(!isInMarket(_ocId), "already in market");
        require(_depositAmount > 10, "invalid depositAmount");
        require(_subPrice * 10 <= _depositAmount, "invalid subPrice");
        require(IOracleManager(oracleManagerAddr).isOracleOwner(_ocId, msg.sender), "no permission");
        (, bytes32 category) = IOracleManager(oracleManagerAddr).getOracleInfo(_ocId);
        require(bytes32("common") == category, "pls use common oracle");
        require(IOracleManager(oracleManagerAddr).isNeedSubscribe(_ocId), "no subscription required");
        MarketState(state).addMarket(_ocId, _subPrice, _depositAmount, _inviteRatio, _commissionRatio, _withdrawAddr);
        Funds(fundsAddr).transferIn(msg.sender, _depositAmount);
        emit newMarket(_ocId, _subPrice, _depositAmount, _inviteRatio, _commissionRatio);
    }

    function isInMarket(uint256 _ocId) override public view returns (bool) {
        return MarketState(state).isInMarket(_ocId);
    }

    function updateFundsAddr(address _fundsAddr) override external onlyOwner {
        emit changeFunds(fundsAddr, _fundsAddr);
        fundsAddr = _fundsAddr;
    }

    function updateOracleManagerAddr(address _oracleManagerAddr) override external onlyOwner {
        emit changeOracleManager(oracleManagerAddr, _oracleManagerAddr);
        oracleManagerAddr = _oracleManagerAddr;
    }

    function acceptStateOwnership() override external onlyOwner {
        MarketState(state).acceptOwnership();
    }

    function nominateStateNewOwner(address _owner) override external onlyOwner {
        MarketState(state).nominateNewOwner(_owner);
    }

}