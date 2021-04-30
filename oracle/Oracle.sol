pragma solidity ^0.6.12;

import "./OracleState.sol";
import "./AbstractOracle.sol";

contract Oracle is AbstractOracle {

    uint8 constant public MAX_SYMBOL_COUNT = 32;

    constructor(address _owner, uint256 _ocId, bool _needSubscribe, uint8 _decimals, address _proxy, address _state)
    public AbstractOracle(_owner, _ocId, _needSubscribe, _decimals, _proxy, _state){
    }

    function updateCoinInfo(bytes32 _symbol, int256 _newPrice, uint64 _newTimestamp) override external notDeprecated {
        require(msg.sender == proxy || msg.sender == owner, "no permission");
        bytes32[] memory symbols = new bytes32[](1);
        symbols[0] = _symbol;
        int256[] memory newPrices = new int256[](1);
        newPrices[0] = _newPrice;
        OracleState(state).batchUpdateCoinInfo(symbols, newPrices, _newTimestamp, MAX_SYMBOL_COUNT);
    }

    function batchUpdateCoinInfo(bytes32[] calldata _symbols, int256[] calldata _newPrices, uint64 _newTimestamp) override external notDeprecated {
        require(msg.sender == proxy || msg.sender == owner, "no permission");
        OracleState(state).batchUpdateCoinInfo(_symbols, _newPrices, _newTimestamp, MAX_SYMBOL_COUNT);
    }

    function getCoinInfo(bytes32 _symbol) override external view notDeprecated returns (bytes32, int256, uint64, uint64) {
        require(msg.sender == proxy || hasReadAuthority(msg.sender), "no permission");
        return OracleState(state).getCoinInfo(_symbol);
    }

    function getCoinInfoById(bytes32 _symbol, uint64 _id) override external view notDeprecated returns (bytes32, int256, uint64, uint64) {
        require(msg.sender == proxy || hasReadAuthority(msg.sender), "no permission");
        return OracleState(state).getCoinInfoById(_symbol, _id);
    }
}
