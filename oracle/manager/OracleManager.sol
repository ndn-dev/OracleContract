pragma solidity ^0.6.12;

import "../../Owned.sol";
import "../../proxy/ProxyState.sol";
import "../IOracle.sol";
import "../OracleState.sol";
import "../factory/IOracleFactory.sol";
import "./IOracleManager.sol";
import "../../market/Market.sol";

contract OracleManager is IOracleManager, Owned {

    bool public deprecated;

    address public proxyState;

    address public proxy;

    address public factory;

    address public market;

    uint64 public ocIdCount;

    bytes32 constant public COMMON = bytes32("common");

    bytes32 constant public COMMON_WRAP = bytes32("commonWrap");

    bytes32 constant public CUSTOM = bytes32("custom");

    constructor(address _owner, address _proxy, address _proxyState, address _factory, uint64 _ocIdCount) public Owned(_owner) {
        proxy = _proxy;
        proxyState = _proxyState;
        factory = _factory;
        ocIdCount = _ocIdCount;
    }

    function createCommonOracle(bool _needSubscribe, uint8 _decimals) override external notDeprecated returns (uint256) {
        return createOracle(_needSubscribe, _decimals, COMMON);
    }

    function createCustomOracle(bool _needSubscribe, uint8 _decimals) override external notDeprecated returns (uint256) {
        return createOracle(_needSubscribe, _decimals, CUSTOM);
    }

    function createCommonWrapOracle(bool _needSubscribe, uint8 _decimals, bytes32 _wrapKey, address _wrapAddr) override external notDeprecated returns (uint256) {
        OracleState oracleState = new OracleState(address(this));
        uint256 ocId = generateOcId();
        address oracleAddr = IOracleFactory(factory).createCommonWrapOracle(msg.sender, ocId, _needSubscribe, _decimals, address(oracleState), _wrapAddr, _wrapKey);
        oracleState.nominateNewOwner(oracleAddr);
        IOracle(oracleAddr).acceptStateOwnership();
        ProxyState(proxyState).addOracleInfo(ocId, oracleAddr, COMMON_WRAP);
        emit addOracle(ocId, msg.sender, oracleAddr);
        return ocId;
    }

    function createOracle(bool _needSubscribe, uint8 _decimals, bytes32 _category) internal returns (uint256) {
        OracleState oracleState = new OracleState(address(this));
        uint256 ocId = generateOcId();
        address oracleAddr = IOracleFactory(factory).createCommonOracle(msg.sender, ocId, _needSubscribe, _decimals, address(oracleState));
        oracleState.nominateNewOwner(oracleAddr);
        IOracle(oracleAddr).acceptStateOwnership();
        ProxyState(proxyState).addOracleInfo(ocId, oracleAddr, _category);
        emit addOracle(ocId, msg.sender, oracleAddr);
        return ocId;
    }

    function upgradeCommonOracle(uint256 _ocId) override external notDeprecated {
        address creator = msg.sender;
        IOracle oldOracle = checkForUpgrade(creator, _ocId, COMMON);
        address newOracleAddr = IOracleFactory(factory).createCommonOracle(creator, _ocId, oldOracle.isNeedSubscribe(), oldOracle.getDecimals(), oldOracle.getState());
        oldOracle.nominateStateNewOwner(newOracleAddr);
        IOracle(newOracleAddr).acceptStateOwnership();
        ProxyState(proxyState).addOracleInfo(_ocId, newOracleAddr, COMMON);
        emit updateOracle(_ocId, creator, address(oldOracle), newOracleAddr);
    }

    function upgradeCustomOracle(uint256 _ocId, address _newOracleAddr) override external notDeprecated {
        address creator = msg.sender;
        IOracle oldOracle = checkForUpgrade(creator, _ocId, CUSTOM);
        oldOracle.nominateStateNewOwner(_newOracleAddr);
        IOracle(_newOracleAddr).acceptStateOwnership();
        ProxyState(proxyState).addOracleInfo(_ocId, _newOracleAddr, CUSTOM);
        emit updateOracle(_ocId, creator, address(oldOracle), _newOracleAddr);
    }

    function upgradeCommonWrapOracle(uint256 _ocId, bytes32 _wrapKey, address _wrapAddr) override external notDeprecated {
        address creator = msg.sender;
        IOracle oldOracle = checkForUpgrade(creator, _ocId, COMMON_WRAP);
        address newOracleAddr = IOracleFactory(factory).createCommonWrapOracle(creator, _ocId, oldOracle.isNeedSubscribe(), oldOracle.getDecimals(), oldOracle.getState(), _wrapAddr, _wrapKey);
        oldOracle.nominateStateNewOwner(newOracleAddr);
        IOracle(newOracleAddr).acceptStateOwnership();
        ProxyState(proxyState).addOracleInfo(_ocId, newOracleAddr, COMMON_WRAP);
        emit updateOracle(_ocId, creator, address(oldOracle), newOracleAddr);
    }

    function checkForUpgrade(address _creator, uint256 _ocId, bytes32 _category) internal view returns (IOracle){
        (address oracleAddr, bool forbidden, bytes32 category) = ProxyState(proxyState).getOracleInfo(_ocId);
        require(oracleAddr != address(0), "oracle not found");
        require(category == _category, "category not match");
        require(!forbidden, "oracle is forbidden");
        IOracle oracle = IOracle(oracleAddr);
        require(!oracle.isDeprecated(), "oracle is deprecated");
        require(_creator == oracle.getOwner(), "only oracle owner can upgrade");
        return oracle;
    }

    function subscribeOracle(uint256 _ocId, address _contractAddress, uint256 _amount) override external notDeprecated returns (uint64, bool) {
        if (Market(market).isInMarket(_ocId)) {
            require(msg.sender == market, "no permission");
        }
        require(_contractAddress != address(0), "contract address is empty");
        (address oracleAddr, ) = getOracleInfo(_ocId);
        IOracle oracle = IOracle(oracleAddr);
        require(!oracle.isDeprecated(), "oracle is deprecated");
        require(oracle.isNeedSubscribe(), "no subscription required");
        (, , uint64 expireTime) = oracle.getSubscribeInfo(_contractAddress);
        bool first = false;
        if (expireTime > 0 && expireTime > block.timestamp) {
            require(expireTime < block.timestamp + 1 weeks, "expire time > 10 days");
            expireTime = expireTime + 4 weeks;
        } else {
            expireTime = uint64(block.timestamp + 4 weeks);
            first = true;
        }
        oracle.subscribe(_contractAddress, _amount, expireTime);
        return (expireTime, first);
    }

    function isOracleOwner(uint256 _ocId, address _addr) override external view notDeprecated returns (bool) {
        (address oracleAddr, ) = getOracleInfo(_ocId);
        IOracle oracle = IOracle(oracleAddr);
        return oracle.getOwner() == _addr;
    }
    
    function isNeedSubscribe(uint256 _ocId) override external view notDeprecated returns (bool) {
        (address oracleAddr, ) = getOracleInfo(_ocId);
        IOracle oracle = IOracle(oracleAddr);
        return oracle.isNeedSubscribe();
    }
    
    function getOracleInfo(uint256 _ocId) override public view returns (address, bytes32) {
        (address oracleAddr, bool forbidden, bytes32 category) = ProxyState(proxyState).getOracleInfo(_ocId);
        require(oracleAddr != address(0), "oracle not found");
        require(!forbidden, "oracle is forbidden");
        return (oracleAddr, category);
    }

    function forbidOracle(uint256 _ocId) override external onlyOwner notDeprecated {
        ProxyState(proxyState).forbidOracle(_ocId);
    }

    function nominateProxyStateNewOwner(address _address) override external onlyOwner {
        ProxyState(proxyState).nominateNewOwner(_address);
    }

    function acceptProxyStateOwnership() override external onlyOwner notDeprecated {
        ProxyState(proxyState).acceptOwnership();
    }

    function deprecateContract() override external onlyOwner notDeprecated {
        deprecated = true;
        emit deprecateOracleManager();
    }

    function updateFactoryAddr(address _factoryAddr) override external onlyOwner notDeprecated {
        emit changeFactory(factory, _factoryAddr);
        factory = _factoryAddr;
    }
    
    function updateMarketAddr(address _marketAddr) external onlyOwner notDeprecated {
        emit changeMarket(market, _marketAddr);
        market = _marketAddr;
    }

    function deprecateOracle(uint256 _ocId) override external notDeprecated {
        (address oracleAddr, ,) = ProxyState(proxyState).getOracleInfo(_ocId);
        IOracle oracle = IOracle(oracleAddr);
        require(!oracle.isDeprecated(), "oracle is deprecated");
        require(msg.sender == oracle.getOwner(), "only oracle owner can deprecate");
        oracle.deprecateContract();
    }

    function generateOcId() internal returns (uint256) {
        return block.timestamp * 10 ** 6 + (ocIdCount++ % (10 ** 6));
    }

    modifier notDeprecated {
        require(deprecated == false, "contract is deprecated");
        _;
    }

}
