pragma solidity ^0.6.12;

import "./IOracleFactory.sol";
import "../Oracle.sol";
import "./wrap/chainlink/WrapChainLinkOracle.sol";
import "./wrap/combo/WrapComboOracle.sol";

contract OracleFactory is IOracleFactory {

    address proxy;

    bytes32 constant CHAINLINK = bytes32("chainlink");
    
    bytes32 constant COMBO = bytes32("combo");

    bytes32[] SUPPORT_WRAPPER = [CHAINLINK, COMBO];

    constructor(address _proxy) public{
        proxy = _proxy;
    }

    function createCommonWrapOracle(address _owner, uint256 _ocId, bool _needSubscribe, uint8 _decimals, address _state, address _wrapAddr, bytes32 _wrapKey) override external returns (address) {
        IOracle oracle;
        if (CHAINLINK == _wrapKey) {
            oracle = new WrapChainLinkOracle(_owner, _ocId, _needSubscribe, _decimals, proxy, _state, _wrapAddr);
        } else if (COMBO == _wrapKey) {
            oracle = new WrapComboOracle(_owner, _ocId, _needSubscribe, _decimals, proxy, _state, _wrapAddr);
        }
        return address(oracle);
    }

    function createCommonOracle(address _owner, uint256 _ocId, bool _needSubscribe, uint8 _decimals, address _state) override external returns (address) {
        IOracle oracle = new Oracle(_owner, _ocId, _needSubscribe, _decimals, proxy, _state);
        return address(oracle);
    }

    function supportWrapperKeys() override external view returns (bytes32[] memory) {
        return SUPPORT_WRAPPER;
    }
}