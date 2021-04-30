pragma solidity ^0.6.12;

import "../../../../Owned.sol";

contract Combo is Owned{

    bytes32[] public symbols;
    
    bytes32 public BTC = bytes32("btc_usdt");
    
    bytes32 public ETH = bytes32("eth_usdt");

    mapping(bytes32 => Param) public params;

    struct Param {
        bytes32 symbol;
        uint256 ocId;
    }

    constructor(address _owner) public Owned(_owner) {

    }

    function getParam(bytes32 _symbol) external view returns (bytes32, uint256) {
        Param memory param = params[_symbol];
        return (param.symbol, param.ocId);
    }

    function updateParam(bytes32 _alias, bytes32 _symbol, uint256 _ocId) public onlyOwner {
        require(_ocId > 0, "invalid ocId");
        if (params[_alias].ocId == 0) {
            symbols.push(_alias);
        }
        params[_alias] = Param(_symbol, _ocId);
    }
    
    function batchUpdateParam(bytes32[] memory _aliases, bytes32[] memory _symbols, uint256[] memory _ocIds) external onlyOwner {
        require(_aliases.length == _symbols.length, "aliases.len != symbols.len");
        require(_symbols.length == _ocIds.length, "symbols.len != ocIds.len");

        for (uint256 i = 0; i < _aliases.length; i++) {
            updateParam(_aliases[i], _symbols[i], _ocIds[i]);
        }
    }
    
    function supportSymbols() external view returns (bytes32[] memory) {
        return symbols;
    }
}