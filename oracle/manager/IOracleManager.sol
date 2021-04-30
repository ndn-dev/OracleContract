pragma solidity ^0.6.12;

interface IOracleManager {

    function createCommonOracle(bool _needSubscribe, uint8 _decimals) external returns (uint256);

    function createCommonWrapOracle(bool _needSubscribe, uint8 _decimals, bytes32 _wrapKey, address _wrapAddr) external returns (uint256);

    function createCustomOracle(bool _needSubscribe, uint8 _decimals) external returns (uint256);

    function upgradeCommonOracle(uint256 _ocId) external;

    function upgradeCommonWrapOracle(uint256 _ocId, bytes32 _wrapKey, address _wrapAddr) external;

    function upgradeCustomOracle(uint256 _ocId, address _newOracleAddr) external;

    function subscribeOracle(uint256 _ocId, address _contractAddress, uint256 _amount) external returns (uint64, bool);

    function isOracleOwner(uint256 _ocId, address _addr) external view returns (bool);
    
    function isNeedSubscribe(uint256 _ocId) external view returns (bool);

    function getOracleInfo(uint256 _ocId) external view returns (address, bytes32);

    function forbidOracle(uint256 _ocId) external;

    function nominateProxyStateNewOwner(address _address) external;

    function acceptProxyStateOwnership() external;

    function deprecateContract() external;

    function updateFactoryAddr(address _factoryAddr) external;

    function deprecateOracle(uint256 _ocId) external;

    event deprecateOracleManager();

    event addOracle(uint256 ocId, address ownerAddr, address oracleAddr);

    event updateOracle(uint256 ocId, address ownerAddr, address oldOracleAddr, address newOracleAddr);

    event changeFactory(address oldAddr, address newAddr);

    event changeMarket(address oldAddr, address newAddr);
}
