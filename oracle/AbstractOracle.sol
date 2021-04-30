pragma solidity ^0.6.12;

import "../Owned.sol";
import "./IOracle.sol";
import "./OracleState.sol";
import "../proxy/IProxy.sol";

abstract contract AbstractOracle is IOracle, Owned {

    uint256 public ocId;

    bool public needSubscribe;

    uint8 public decimals;

    bool public deprecated;

    address public proxy;

    address public state;

    constructor(address _owner, uint256 _ocId, bool _needSubscribe, uint8 _decimals, address _proxy, address _state) public Owned(_owner){
        ocId = _ocId;
        needSubscribe = _needSubscribe;
        decimals = _decimals;
        proxy = _proxy;
        state = _state;
    }

    function subscribe(address _subAddress, uint256 _amount, uint64 _expireTime) override external onlyManager notDeprecated {
        OracleState(state).subscribe(_subAddress, _amount, _expireTime);
    }

    function getSubscribeInfo(address _subAddress) override public view returns (address, uint256, uint64){
        return OracleState(state).getSubscribeInfo(_subAddress);
    }

    function hasReadAuthority(address _address) override public view returns (bool) {
        return needSubscribe == false || _address == tx.origin || isSubscriber(_address);
    }

    function isSubscriber(address _address) internal view returns (bool){
        (, , uint64 expireTime) = this.getSubscribeInfo(_address);
        return expireTime > block.timestamp;
    }

    function deprecateContract() override external onlyManager notDeprecated {
        deprecated = true;
        emit deprecateOracleContract(ocId);
    }

    function supportSymbols() override virtual external view returns (bytes32[] memory) {
        return OracleState(state).supportSymbols();
    }

    function getOwner() override external view returns (address) {
        return owner;
    }

    function acceptStateOwnership() override external onlyManager notDeprecated {
        OracleState(state).acceptOwnership();
    }

    function nominateStateNewOwner(address _owner) override external onlyManager notDeprecated {
        OracleState(state).nominateNewOwner(_owner);
    }

    function getOcId() override external view returns (uint256) {
        return ocId;
    }

    function isNeedSubscribe() override external view returns (bool) {
        return needSubscribe;
    }

    function getDecimals() override external view returns (uint8) {
        return decimals;
    }

    function isDeprecated() override external view returns (bool) {
        return deprecated;
    }

    function getProxy() override external view returns (address) {
        return proxy;
    }

    function getState() override external view returns (address) {
        return state;
    }

    function getVersion() override external view returns (uint8) {
        return 1;
    }

    modifier onlyManager {
        require(msg.sender == IProxy(proxy).getOracleManagerAddr(), "no permission");
        _;
    }

    modifier notDeprecated {
        require(deprecated == false, "contract is deprecated");
        _;
    }
}
