pragma solidity ^0.6.12;

interface IOracleFactory {
    function createCommonWrapOracle(address _owner, uint256 _ocId, bool _needSubscribe, uint8 _decimals, address _state, address _wrapAddr, bytes32 _wrapKey) external returns (address);

    function createCommonOracle(address _owner, uint256 _ocId, bool _needSubscribe, uint8 _decimals, address _state) external returns (address);

    function supportWrapperKeys() external view returns (bytes32[] memory);
}