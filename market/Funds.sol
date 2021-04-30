pragma solidity ^0.6.12;

import "../IERC20.sol";
import "../Owned.sol";

contract Funds is Owned {
    address public marketAddr;

    address public tokenAddr;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event changeMarket(address oldAddr, address newAddr);

    event changeToken(address oldAddr, address newAddr);

    constructor(address _owner, address _marketAddr, address _tokenAddr) public Owned (_owner) {
        marketAddr = _marketAddr;
        tokenAddr = _tokenAddr;
    }

    function transferIn(address _from, uint256 _amount) external onlyMarket {
        require(_amount > 0, "invalid amount");
        IERC20 token = IERC20(tokenAddr);
        require(token.balanceOf(_from) >= _amount, "balance not enough");
        token.transferFrom(_from, address(this), _amount);
        emit Transfer(_from, address(this), _amount);
    }

    function transferOut(address _to, uint256 _amount) external onlyMarket {
        require(_amount > 0, "invalid amount");
        IERC20 token = IERC20(tokenAddr);
        require(token.balanceOf(address(this)) >= _amount, "balance not enough");
        token.transfer(_to, _amount);
        emit Transfer(address(this), _to, _amount);
    }

    function updateMarketAddr(address _marketAddr) external onlyOwner {
        emit changeMarket(marketAddr, _marketAddr);
        marketAddr = _marketAddr;
    }

    function updateTokenAddr(address _tokenAddr) external onlyOwner {
        emit changeToken(tokenAddr, _tokenAddr);
        tokenAddr = _tokenAddr;
    }

    modifier onlyMarket {
        require(msg.sender == marketAddr, "no permission");
        _;
    }
}
