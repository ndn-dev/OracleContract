pragma solidity ^0.6.12;

interface IMarket {

    function subscribeOracle(uint256 _ocId, uint256 _amount, address _subAddr, address _inviteAddr) external;

    function withdrawProfit(uint256 _ocId, uint64 _startTime, uint64 _endTime) external;

    function applyMarket(uint256 _ocId, uint256 _subPrice, uint256 _depositAmount, uint8 _inviteRatio, uint8 _commissionRatio, address _withdrawAddr) external;

    function isInMarket(uint256 _ocId) external view returns (bool);

    function updateFundsAddr(address _fundsAddr) external;

    function updateOracleManagerAddr(address _oracleManagerAddr) external;

    function acceptStateOwnership() external;

    function nominateStateNewOwner(address _owner) external;

    event newSubscribe(uint256 _ocId, address _subAddr, address _inviteAddr, uint256 _amount);

    event newMarket(uint256 _ocId, uint256 _subPrice, uint256 _depositAmount, uint8 _inviteRatio, uint8 _commissionRatio);

    event newWithdraw(uint256 _ocId, uint64 _startTime, uint64 _endTime, uint256 _total);

    event changeFunds(address _oldAddr, address _newAddr);

    event changeOracleManager(address _oldAddr, address _newAddr);

}