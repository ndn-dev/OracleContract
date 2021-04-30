pragma solidity ^0.6.12;

import "../../../IOracle.sol";

interface IOracleWithTarget is IOracle {
    function target() external returns (address);
}