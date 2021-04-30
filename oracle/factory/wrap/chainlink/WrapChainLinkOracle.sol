pragma solidity ^0.6.12;

import "../../../AbstractOracle.sol";
import "./AggregatorProxy.sol";

contract WrapChainLinkOracle is AbstractOracle {

    uint256 constant private PHASE_OFFSET = 64;

    address target;

    bytes32 symbolName;

    constructor(address _owner, uint256 _ocId, bool _needSubscribe, uint8 _decimals, address _proxy, address _state, address _target)
    public AbstractOracle(_owner, _ocId, _needSubscribe, _decimals, _proxy, _state){
        target = _target;
        string memory strName = AggregatorProxy(target).description();
        bytes32 result;
        assembly {
            result := mload(add(strName, 32))
        }
        symbolName = result;
    }

    function getCoinInfo(bytes32 _symbol) override external view notDeprecated returns (bytes32, int256, uint64, uint64) {
        require(msg.sender == proxy || hasReadAuthority(msg.sender), "no permission");
        (uint80 roundId,int256 answer, ,uint256 updatedAt,) = AggregatorProxy(target).latestRoundData();
        return (symbolName, answer, uint64(updatedAt), uint64(roundId));
    }
    
    function getCoinInfoById(bytes32 _symbol, uint64 _id) override external view notDeprecated returns (bytes32, int256, uint64, uint64) {
        require(msg.sender == proxy || hasReadAuthority(msg.sender), "no permission");
        uint16 pId = AggregatorProxy(target).phaseId();
        uint80 tId = uint80(uint256(pId) << PHASE_OFFSET | _id);
        (uint80 roundId,int256 answer, ,uint256 updatedAt,) = AggregatorProxy(target).getRoundData(tId);
        return (symbolName, answer, uint64(updatedAt), uint64(roundId));
    }

    function updateCoinInfo(bytes32 _symbol, int256 _newPrice, uint64 _newTimestamp) override external notDeprecated {
        require(msg.sender == proxy || msg.sender == owner, "no permission");
    }

    function batchUpdateCoinInfo(bytes32[] calldata _symbols, int256[] calldata _newPrices, uint64 _newTimestamp) override external notDeprecated {
        require(msg.sender == proxy || msg.sender == owner, "no permission");
    }
    
    function supportSymbols() override external view returns (bytes32[] memory) {
        bytes32[] memory symbols = new bytes32[](1);
        symbols[0] = symbolName;
        return symbols;
    }
}
