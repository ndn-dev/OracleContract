# USING PRICE FEEDS
## API
### Functions
| Name   | Description |
| ------- | ---- |
| getCoinInfo | Get the latest price with id.   |
| getCoinInfoById | Get price by id.   |
| getCoinInfoByIdRange   | Get the price through id range.   |
| updateCoinInfo   | Feed the price.   |
| batchUpdateCoinInfo   | Batch feeding price.   |
| getOracleInfo   | Get oracle info.   |

#### getCoinInfo
```
function getCoinInfo(uint256 _ocId, bytes32 _symbol) external view returns (bytes32, int256, uint64, uint64);
```
##### Parameters
* ocId: The oracle contract id.
* symbol: The symbol name.
#### Return Values
* symbol: The symbol name.
* price: The price
* timstamp: Timestamp of the price.
* id: The price id.
#### getCoinInfoById
```
function getCoinInfoById(uint256 _ocId, bytes32 _symbol, uint64 _id) external view returns (bytes32, int256, uint64, uint64);
```
##### Parameters
* ocId: The oracle contract id.
* symbol: The symbol name.
* id: The price id.
#### Return Values
* symbol: The symbol name.
* price: The price
* timstamp: Timestamp of the price.
* id: The price id.
#### getCoinInfoByIdRange
```
function getCoinInfoByIdRange(uint256 _ocId, bytes32 _symbol, uint64 _startId, uint64 _endId) external view returns (int256[] memory, uint64[] memory);
```
##### Parameters
* ocId: The oracle contract id.
* symbol: The symbol name.
* startId: The start id of the query.
* endId: The end id of the query.

#### Return Values
* prices: Array of prices.
* timstamps: Array of timestamps.
### Events
| Name   | Description |
| ------- | ---- |
| newCoinInfo | When the price is successfully fed, the contract record changes.   |

## Solidity Example
```
pragma solidity ^0.6.12;

import "./IProxy.sol";

contract PriceConsumer {

    IProxy internal proxy;

    /**
     * Network: Rinkeby
     * Address: 0xFdE6B0b00d5662355EC81D9Ba22Fd3Fa0FC65735
     */
    constructor() public {
        proxy = IProxy(0xFdE6B0b00d5662355EC81D9Ba22Fd3Fa0FC65735);
    }

    /**
     * Returns the latest price
     */
    function getThePrice(uint256 _ocId, bytes32 _symbol) public view returns (int256) {
        (
            bytes32 symbol, 
            int256 price,
            uint64 timestamp,
            uint64 id
        ) = proxy.getCoinInfo(_ocId, _symbol);
        return price;
    }
}
```

# USING ORACLEMANAGER
## API
| Name   | Description |
| ------- | ---- |
| createCommonOracle | Use our template to create the oracle.   |
| createCommonWrapOracle | Use our interface to wrap other contracts.   |
| createCustomOracle   | Use our interface to create a oracle.   |
| upgradeCommonOracle   | Upgrade.   |
| upgradeCommonWrapOracle   | Upgrade.   |
| upgradeCustomOracle   | Upgrade.   |


# USING MARKET
## API
| Name   | Description |
| ------- | ---- |
| subscribeOracle | Subscribe the oracle in the market.   |
| withdrawProfit | Oracle provider withdraws profits.   |
| applyMarket   | Oracle applied to enter the market.   |
