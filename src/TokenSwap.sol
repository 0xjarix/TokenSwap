// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {TokenA} from "./TokenA.sol";
import {TokenB} from "./TokenB.sol";
import "../lib/solady/src/utils/SafeTransferLib.sol";

contract TokenSwap {

    // errors
    error TokenSwap__NotEnoughTokenA();
    error TokenSwap__NotEnoughTokenB();
    error TokenSwap__MustBeTheOwnerToRecoverTokens();

    // state variables
    TokenA public tokenA;
    TokenB public tokenB;
    address public owner;
    uint256 public immutable exchangeRate; // Fixed exchange rate: Amount of Token B per Token A

    // events
    event TokenASwappedForTokenB(address swapper, uint256 amountA, uint256 amountB);
    event TokenBSwappedForTokenA(address swapper, uint256 amountA, uint256 amountB);
    constructor(
    ) {
        tokenA = new TokenA();
        tokenB = new TokenB();
        exchangeRate = 2; // 2 TokenB per TokenA
        owner = msg.sender;
    }

    /// @notice swaps tokenA for tokenB.
    /// @param _amountA The amount of tokenA to swap for tokenB.
    function swapTokenAForTokenB(uint256 _amountA) external {
        if (tokenA.balanceOf(msg.sender) < _amountA) {
            revert TokenSwap__NotEnoughTokenA();
        }
        uint256 amountB = _amountA * exchangeRate; // In our case TokenA and TokenB have the same decimals
        if (tokenB.balanceOf(address(this)) < amountB) {
            revert TokenSwap__NotEnoughTokenB();
        }
        SafeTransferLib.safeTransfer(address(tokenB), msg.sender, amountB);
        SafeTransferLib.safeTransferFrom(address(tokenA), msg.sender, address(this), _amountA);
        emit TokenASwappedForTokenB(msg.sender, _amountA, amountB);
    }

    /// @notice swaps tokenB for tokenA.
    /// @param _amountB The amount of tokenB to swap for tokenA.
    function swapTokenBForTokenA(uint256 _amountB) external {
        if (tokenB.balanceOf(msg.sender) < _amountB) {
            revert TokenSwap__NotEnoughTokenB();
        }
        uint256 amountA = _amountB / exchangeRate; // In our case TokenA and TokenB have the same decimals
        if (tokenA.balanceOf(address(this)) < amountA) {
            revert TokenSwap__NotEnoughTokenA();
        }
        SafeTransferLib.safeTransfer(address(tokenA), msg.sender, amountA);
        SafeTransferLib.safeTransferFrom(address(tokenB), msg.sender, address(this), _amountB);
        emit TokenBSwappedForTokenA(msg.sender, _amountB, amountA);
    }

    /// @notice security mechanism to recover tokenA if contract under attack. The owner is a trustworthy entity.
    function recoverTokenA() external {
        if (msg.sender != owner) {
            revert TokenSwap__MustBeTheOwnerToRecoverTokens();
        }
        SafeTransferLib.safeTransfer(address(tokenA), msg.sender, tokenA.balanceOf(address(this)));
    }

    /// @notice security mechanism to recover tokenB if contract under attack. The owner is a trustworthy entity.
    function recoverTokenB() external {
        if (msg.sender != owner) {
            revert TokenSwap__MustBeTheOwnerToRecoverTokens();
        }
        SafeTransferLib.safeTransfer(address(tokenB), msg.sender, tokenB.balanceOf(address(this)));
    }
}