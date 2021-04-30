pragma solidity ^0.6.12;

interface IProxy {

    function getOracleManagerAddr() external view returns (address);

    function getOracleInfo(uint256 _ocId) external view returns (address, bool, bytes32);

    function getCoinInfo(uint256 _ocId, bytes32 _symbol) external view returns (bytes32, int256, uint64, uint64);

    function getCoinInfoById(uint256 _ocId, bytes32 _symbol, uint64 _id) external view returns (bytes32, int256, uint64, uint64);

    function getCoinInfoByIdRange(uint256 _ocId, bytes32 _symbol, uint64 _startId, uint64 _endId) external view returns (int256[] memory, uint64[] memory);

    function updateCoinInfo(uint256 _ocId, bytes32 _symbol, int256 _newPrice, uint64 _newTimestamp) external;

    function batchUpdateCoinInfo(uint256 _ocId, bytes32[] calldata _symbols, int256[] calldata _newPrices, uint64 _newTimestamp) external;

    event changeState(address oldAddr, address newAddr);

    event newCoinInfo(uint256 ocId, bytes32 symbol, int256 price, uint64 lastUpdateTimestamp);
}
