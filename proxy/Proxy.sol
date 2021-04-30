pragma solidity ^0.6.12;

import "../Owned.sol";
import "../oracle/IOracle.sol";
import "../proxy/ProxyState.sol";
import "./IProxy.sol";

contract Proxy is IProxy, Owned {

    address state;

    constructor(address _owner, address _state) public Owned(_owner) {
        state = _state;
    }

    function getOracleManagerAddr() override external view returns (address) {
        return ProxyState(state).owner();
    }

    function getOracleInfo(uint256 _ocId) override public view returns (address, bool, bytes32) {
        return ProxyState(state).getOracleInfo(_ocId);
    }

    function getOracle(uint256 _ocId) internal view returns (IOracle) {
        (address oracleAddr, bool forbidden,) = getOracleInfo(_ocId);
        require(oracleAddr != address(0), "oracle not exists");
        require(forbidden == false, "oracle is forbidden");
        return IOracle(oracleAddr);
    }

    function getCoinInfo(uint256 _ocId, bytes32 _symbol) override external view returns (bytes32, int256, uint64, uint64) {
        IOracle oracle = getOracle(_ocId);
        require(oracle.hasReadAuthority(msg.sender), "no permission");
        return oracle.getCoinInfo(_symbol);
    }

    function getCoinInfoById(uint256 _ocId, bytes32 _symbol, uint64 _id) override public view returns (bytes32, int256, uint64, uint64) {
        IOracle oracle = getOracle(_ocId);
        require(oracle.hasReadAuthority(msg.sender), "no permission");
        return oracle.getCoinInfoById(_symbol, _id);
    }

    function getCoinInfoByIdRange(uint256 _ocId, bytes32 _symbol, uint64 _startId, uint64 _endId) override external view returns (int256[] memory, uint64[] memory) {
        require(_endId >= _startId, "invalid id");
        IOracle oracle = getOracle(_ocId);
        require(oracle.hasReadAuthority(msg.sender), "no permission");
        uint64 length = _endId - _startId + 1;
        int256[] memory prices = new int256[](length);
        uint64[] memory timestamps = new uint64[](length);
        for(uint64 i = 0; i < length; i++) {
            (, int256 price, uint64 timestamp, ) = oracle.getCoinInfoById(_symbol, _startId++);
            prices[i] = price;
            timestamps[i] = timestamp;
        }
        return (prices, timestamps);
    }

    function updateCoinInfo(uint256 _ocId, bytes32 _symbol, int256 _newPrice, uint64 _newTimestamp) override external {
        IOracle oracle = getOracle(_ocId);
        require(msg.sender == oracle.getOwner(), "no permission");
        oracle.updateCoinInfo(_symbol, _newPrice, _newTimestamp);
        emit newCoinInfo(_ocId, _symbol, _newPrice, _newTimestamp);
    }

    function batchUpdateCoinInfo(uint256 _ocId, bytes32[] calldata _symbols, int256[] calldata _newPrices, uint64 _newTimestamp) override external {
        IOracle oracle = getOracle(_ocId);
        require(msg.sender == oracle.getOwner(), "no permission");
        oracle.batchUpdateCoinInfo(_symbols, _newPrices, _newTimestamp);
        for (uint i = 0; i < _symbols.length; i++) {
            emit newCoinInfo(_ocId, _symbols[i], _newPrices[i], _newTimestamp);
        }
    }

    function updateStateAddr(address _stateAddr) external onlyOwner {
        emit changeState(state, _stateAddr);
        state = _stateAddr;
    }
}
