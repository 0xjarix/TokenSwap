// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {TokenA} from "./TokenA.sol";
import {TokenB} from "./TokenB.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";

contract TokenSwap {
    // Libs
    using SafeTransferLib for TokenA;
    using SafeTransferLib for TokenB;

    // errors
    error TokenSwap__NotEnoughTokenA();
    error TokenSwap__NotEnoughTokenB();
    error TokenSwap__MustBeTheOwnerToRecoverTokens();

    // state variables
    TokenA public immutable i_tokenA;
    TokenB public immutable i_tokenB;
    address public immutable i_owner;
    uint256 public immutable i_exchangeRate; // Fixed exchange rate: Amount of Token B per Token A

    // events
    event TokenASwappedForTokenB(address swapper, uint256 amountA, uint256 amountB);
    event TokenBSwappedForTokenA(address swapper, uint256 amountA, uint256 amountB);
    constructor(
        address _tokenA,
        address _tokenB,
        uint256 _exchangeRate
    ) {
        i_tokenA = TokenA(_tokenA);
        i_tokenB = TokenB(_tokenB);
        i_exchangeRate = _exchangeRate;
        i_owner = msg.sender;
    }

    /// @notice swaps tokenA for tokenB.
    /// @param _amountA The amount of tokenA to swap for tokenB.
    function swapTokenAForTokenB(uint256 _amountA) external {
        if (i_tokenA.balanceOf(msg.sender) < _amountA) {
            revert TokenSwap__NotEnoughTokenB();
        }
        uint256 amountB = _amountA / i_exchangeRate;
        if (i_tokenB.balanceOf(address(this)) < amountB) {
            revert TokenSwap__NotEnoughTokenB();
        }
        i_tokenB.safeTransferFrom(msg.sender, address(this), _amountA);
        i_tokenB.transfer(msg.sender, amountB);
        emit TokenASwappedForTokenB(msg.sender, _amountA, amountB);
    }

    /// @notice swaps tokenB for tokenA.
    /// @param _amountB The amount of tokenB to swap for tokenA.
    function swapTokenBForTokenA(uint256 _amountB) external {
        if (i_tokenB.balanceOf(msg.sender) < _amountB) {
            revert TokenSwap__NotEnoughTokenB();
        }
        uint256 amountA = _amountB * i_exchangeRate;
        if (i_tokenA.balanceOf(address(this)) < amountA) {
            revert TokenSwap__NotEnoughTokenA();
        }
        i_tokenB.safeTransferFrom(msg.sender, address(this), _amountB);
        i_tokenA.transfer(msg.sender, amountA);
        emit TokenBSwappedForTokenA(msg.sender, _amountB, amountA);
    }

    /// @notice security mechanism to recover tokenA if contract under attack. The owner is a trustworthy entity.
    function recoverTokenA() external {
        if (msg.sender != i_owner) {
            revert TokenSwap__MustBeTheOwnerToRecoverTokens();
        }
        i_tokenA.safeTransfer(msg.sender, i_tokenA.balanceOf(address(this)));
    }

    /// @notice security mechanism to recover tokenB if contract under attack. The owner is a trustworthy entity.
    function recoverTokenB() external {
        if (msg.sender != i_owner) {
            revert TokenSwap__MustBeTheOwnerToRecoverTokens();
        }
        i_tokenB.safeTransfer(msg.sender, i_tokenB.balanceOf(address(this)));
    }
}