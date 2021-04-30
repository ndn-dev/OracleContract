pragma solidity ^0.6.12;

import "../Owned.sol";

contract ProxyState is Owned {

    struct OracleInfo {
        address oracleAddr;
        bool forbidden;
        bytes32 category;
    }

    event updateOracleInfo(
        uint256 ocId,
        address oracleAddr,
        bool forbidden,
        bytes32 category
    );

    //(ocId, OracleInfo)
    mapping(uint256 => OracleInfo) public oracles;

    constructor(address _owner) public Owned(_owner){

    }

    function getOracleInfo(uint256 _ocId) external view returns (address, bool, bytes32) {
        return (
        oracles[_ocId].oracleAddr,
        oracles[_ocId].forbidden,
        oracles[_ocId].category
        );
    }

    function addOracleInfo(uint256 _ocId, address _oracleAddr, bytes32 _category) external onlyOwner {
        oracles[_ocId] = (OracleInfo(_oracleAddr, false, _category));
        emit updateOracleInfo(_ocId, _oracleAddr, false, _category);
    }

    function forbidOracle(uint256 _ocId) external onlyOwner {
        if (oracles[_ocId].oracleAddr != address(0)) {
            oracles[_ocId].forbidden = true;
            emit updateOracleInfo(_ocId, oracles[_ocId].oracleAddr, true, oracles[_ocId].category);
        }
    }

}
