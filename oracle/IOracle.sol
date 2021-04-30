pragma solidity ^0.6.12;

interface IOracle {

    function updateCoinInfo(bytes32 _symbol, int256 _newPrice, uint64 _newTimestamp) external;

    function batchUpdateCoinInfo(bytes32[] calldata _symbols, int256[] calldata _newPrices, uint64 _newTimestamp) external;

    function getCoinInfo(bytes32 _symbol) external view returns (bytes32, int256, uint64, uint64);

    function getCoinInfoById(bytes32 _symbol, uint64 _id) external view returns (bytes32, int256, uint64, uint64);

    function subscribe(address _subAddress, uint256 _amount, uint64 _expireTime) external;

    function getSubscribeInfo(address _subAddress) external view returns (address, uint256, uint64);

    function hasReadAuthority(address _address) external view returns (bool);

    function deprecateContract() external;

    function getOwner() external view returns (address);

    function supportSymbols() external view returns (bytes32[] memory);

    function acceptStateOwnership() external;

    function nominateStateNewOwner(address _owner) external;

    function getOcId() external view returns (uint256);

    function isNeedSubscribe() external view returns (bool);

    function getDecimals() external view returns (uint8);

    function isDeprecated() external view returns (bool);

    function getProxy() external view returns (address);

    function getState() external view returns (address);

    function getVersion() external view returns (uint8);

    event deprecateOracleContract(uint256 ocId);

}
