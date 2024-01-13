// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {TokenA} from "./TokenA.sol";
import {TokenB} from "./TokenB.sol";

contract TokenSwap {
    address public tokenA;
    address public tokenB;
    address public owner;
    uint256 public tokenAPrice;
    uint256 public tokenBPrice;

    constructor(
        address _tokenA,
        address _tokenB,
        uint256 _tokenAPrice,
        uint256 _tokenBPrice
    ) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        tokenAPrice = _tokenAPrice;
        tokenBPrice = _tokenBPrice;
        owner = msg.sender;
    }

    function swapTokens(uint256 _amount, address _token) external {
        require(_token == tokenA || _token == tokenB, "Token not supported");
        if (_token == tokenA) {
            require(
                IERC20(tokenA).transferFrom(msg.sender, owner, _amount),
                "Transfer failed"
            );
            require(
                IERC20(tokenB).transfer(msg.sender, _amount * tokenAPrice),
                "Transfer failed"
            );
        } else {
            require(
                IERC20(tokenB).transferFrom(msg.sender, owner, _amount),
                "Transfer failed"
            );
            require(
                IERC20(tokenA).transfer(msg.sender, _amount * tokenBPrice),
                "Transfer failed"
            );
        }
    }
}