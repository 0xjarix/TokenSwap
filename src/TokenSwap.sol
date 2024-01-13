// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {SomeERC20} from "./SomeERC20.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";
contract TokenSwap {
    // Libs
    using SafeTransferLib for SomeERC20;

    // errors
    error TokenSwap__NotEnoughTokenA();
    error TokenSwap__NotEnoughTokenB();
    error TokenSwap__MustBeTheOwnerToRecoverTokens();

    // state variables
    address immutable public i_tokenA;
    address immutable public i_tokenB;
    address public i_owner;
    uint256 public i_exchangeRate; // Fixed exchange rate: Amount of Token B per Token A

    // events
    event TokenASwappedForTokenB(address swapper, uint256 amountA, uint256 amountB);
    event TokenBSwappedForTokenA(address swapper, uint256 amountA, uint256 amountB);
    constructor(
        address _tokenA,
        address _tokenB,
        uint256 _exchangeRate
    ) {
        i_tokenA = _tokenA;
        i_tokenB = _tokenB;
        i_exchangeRate = _exchangeRate;
        i_owner = msg.sender;
    }

    /// @notice swaps tokenA for tokenB.
    /// @param _amountA The amount of tokenA to swap for tokenB.
    function swapTokenAForTokenB(uint256 _amountA) external {
        if (SomeERC20(i_tokenA).balanceOf(msg.sender) < _amountA) {
            revert TokenSwap__NotEnoughTokenB();
        }
        uint256 amountB = _amountA * i_exchangeRate / 1e18;
        if (SomeERC20(i_tokenB).balanceOf(address(this)) < amountB) {
            revert TokenSwap__NotEnoughTokenB();
        }
        SomeERC20(i_tokenB).safeTransferFrom(msg.sender, address(this), _amountA);
        SomeERC20(i_tokenB).transfer(msg.sender, amountB);
        emit TokenASwappedForTokenB(msg.sender, _amountA, amountB);
    }

    /// @notice swaps tokenB for tokenA.
    /// @param _amountB The amount of tokenB to swap for tokenA.
    function swapTokenBForTokenA(uint256 _amountB) external {
        if (SomeERC20(i_tokenB).balanceOf(msg.sender) < _amountB) {
            revert TokenSwap__NotEnoughTokenB();
        }
        uint256 amountA = (_amountB / i_exchangeRate) / 1e18;
        if (SomeERC20(i_tokenA).balanceOf(address(this)) < amountA) {
            revert TokenSwap__NotEnoughTokenA();
        }
        SomeERC20(i_tokenB).safeTransferFrom(msg.sender, address(this), _amountB);
        SomeERC20(i_tokenA).transfer(msg.sender, amountA);
        emit TokenBSwappedForTokenA(msg.sender, _amountB, amountA);
    }

    function recoverTokenA() external {
        if (msg.sender != i_owner) {
            revert TokenSwap__MustBeTheOwnerToRecoverTokens();
        }
        SomeERC20(i_tokenA).safeTransfer(msg.sender, SomeERC20(i_tokenA).balanceOf(address(this)));
    }

    function recoverTokenB() external {
        if (msg.sender != i_owner) {
            revert TokenSwap__MustBeTheOwnerToRecoverTokens();
        }
        SomeERC20(i_tokenB).safeTransfer(msg.sender, SomeERC20(i_tokenB).balanceOf(address(this)));
    }
}