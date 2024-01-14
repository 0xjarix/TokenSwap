// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {TokenSwap} from "../src/TokenSwap.sol";
import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";

contract TokenSwapTest is Test {
    TokenSwap tokenSwap;
    address tokenA = address(0x1);
    address tokenB = address(0x2);
    function setUp() public virtual {
        vm.prank(address(this));
        tokenSwap = new TokenSwap(tokenA, tokenB);
    }

    function testTokenASwappedForTokenB() public {
        address alice = address(0x3);
        TokenA(tokenA).mint(alice, 100);
        tokenSwap.swapTokenAForTokenB(100);
        assertEq(TokenA(tokenA).balanceOf(alice), 0);
        assertEq(TokenB(tokenB).balanceOf(alice), 100);
    }
    
}