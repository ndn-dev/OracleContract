pragma solidity ^0.6.12;

import "../../../AbstractOracle.sol";
import "../../../../proxy/IProxy.sol";
import "./Combo.sol";

contract WrapComboOracle is AbstractOracle {

    address public target;

    constructor(address _owner, uint256 _ocId, bool _needSubscribe, uint8 _decimals, address _proxy, address _state, address _target)
    public AbstractOracle(_owner, _ocId, _needSubscribe, _decimals, _proxy, _state){
        target = _target;
    }

    function getCoinInfo(bytes32 _symbol) override external view notDeprecated targetNotNull returns (bytes32, int256, uint64, uint64) {
        require(msg.sender == proxy || hasReadAuthority(msg.sender), "no permission");
        (bytes32 symbol, uint256 ocId) = Combo(target).getParam(_symbol);
        return IProxy(proxy).getCoinInfo(ocId, symbol);
    }

    function getCoinInfoById(bytes32 _symbol, uint64 _id) override external view notDeprecated targetNotNull returns (bytes32, int256, uint64, uint64) {
        require(msg.sender == proxy || hasReadAuthority(msg.sender), "no permission");
        (bytes32 symbol, uint256 ocId) = Combo(target).getParam(_symbol);
        return IProxy(proxy).getCoinInfoById(ocId, symbol, _id);
    }

    function updateCoinInfo(bytes32 _symbol, int256 _newPrice, uint64 _newTimestamp) override external notDeprecated {
        require(msg.sender == proxy || msg.sender == owner, "no permission");
    }

    function batchUpdateCoinInfo(bytes32[] calldata _symbols, int256[] calldata _newPrices, uint64 _newTimestamp) override external notDeprecated {
        require(msg.sender == proxy || msg.sender == owner, "no permission");
    }

    function supportSymbols() override external view targetNotNull returns (bytes32[] memory) {
        return Combo(target).supportSymbols();
    }

    modifier targetNotNull {
        require(target != address(0), "target is null");
        _;
    }
}
