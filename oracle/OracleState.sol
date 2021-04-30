pragma solidity ^0.6.12;

import "../Owned.sol";

contract OracleState is Owned {

    mapping(bytes32 => mapping(uint64 => CoinInfo)) coins;

    mapping(bytes32 => uint64) ids;

    mapping(address => SubscribeInfo) subscribers;

    bytes32[] symbols;

    uint64 constant public MAX_PRICE_COUNT = 512;

    struct SubscribeInfo {
        address subAddr;
        uint256 amount;
        uint64 expireTime;
    }

    struct CoinInfo {
        int256 price;
        uint64 lastUpdateTimestamp;
    }

    event newCoinInfo(bytes32 symbol, int256 price, uint64 lastUpdateTimestamp);

    event newSubscribeInfo(address subAddr, uint256 amount, uint64 expireTime);

    constructor(address _owner) public Owned(_owner){

    }

    function batchUpdateCoinInfo(bytes32[] memory _symbols, int256[] memory _newPrices, uint64 _newTimestamp, uint8 _maxSymbolCount) public onlyOwner {
        require(_symbols.length == _newPrices.length, "symbols.len != newPrices.len");

        for (uint256 i = 0; i < _symbols.length; i++) {
            bytes32 symbol = _symbols[i];
            uint64 index = ids[symbol] % MAX_PRICE_COUNT;
            if (_newTimestamp > coins[symbol][index].lastUpdateTimestamp) {
                if (coins[symbol][index].lastUpdateTimestamp == 0) {
                    require(symbols.length < _maxSymbolCount, "symbol count over limit");
                    symbols.push(symbol);
                }
                uint64 newIndex = ++ids[symbol] % MAX_PRICE_COUNT;
                coins[symbol][newIndex] = CoinInfo(_newPrices[i], _newTimestamp);
                emit newCoinInfo(symbol, _newPrices[i], _newTimestamp);
            }
        }
    }

    function getCoinInfo(bytes32 _symbol) external view onlyOwner returns (bytes32, int256, uint64, uint64) {
        uint64 currentId = ids[_symbol];
        return getCoinInfoById(_symbol, currentId);
    }

    function getCoinInfoById(bytes32 _symbol, uint64 _id) public view onlyOwner returns (bytes32, int256, uint64, uint64) {
        require(_id <= ids[_symbol] && _id + MAX_PRICE_COUNT > ids[_symbol], "invalid id");
        uint64 index = _id % MAX_PRICE_COUNT;
        CoinInfo memory coinInfo = coins[_symbol][index];
        return (_symbol, coinInfo.price, coinInfo.lastUpdateTimestamp, _id);
    }

    function supportSymbols() external view onlyOwner returns (bytes32[] memory) {
        return symbols;
    }

    function subscribe(address _subAddress, uint256 _amount, uint64 _expireTime) external onlyOwner {
        subscribers[_subAddress] = SubscribeInfo(_subAddress, _amount, _expireTime);
        emit newSubscribeInfo(_subAddress, _amount, _expireTime);
    }

    function getSubscribeInfo(address _subAddress) external view onlyOwner returns (address, uint256, uint64){
        return (
        subscribers[_subAddress].subAddr,
        subscribers[_subAddress].amount,
        subscribers[_subAddress].expireTime
        );
    }

}
