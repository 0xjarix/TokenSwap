// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {TokenSwap} from "../src/TokenSwap.sol";
import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";
import {console} from "forge-std/console.sol";

contract TokenSwapTest is Test {
    TokenSwap tokenSwap;
    TokenA tokenA;
    TokenB tokenB;
    function setUp() public virtual {
        vm.prank(address(this));
        tokenSwap = new TokenSwap();
        tokenA = tokenSwap.tokenA();
        tokenB = tokenSwap.tokenB();
        console.log("tokenA address:", address(tokenA));
        console.log("tokenB address:", address(tokenB));
        console.log("tokenSwap address:", address(tokenSwap));
        console.log("tokenSwap balance tokenA:", tokenA.balanceOf(address(tokenSwap)));
        console.log("tokenSwap balance tokenB:", tokenB.balanceOf(address(tokenSwap)));
    }

    function testTokenASwappedForTokenB() public {
        console.log("tokenB balance:", tokenB.balanceOf(address(tokenSwap)));
        address alice = address(0x3);
        tokenA.mint(alice, 100000);
        console.log("tokenA balance:", tokenA.balanceOf(alice));
        vm.prank(alice);
        tokenSwap.swapTokenAForTokenB(100);
        assertEq(tokenA.balanceOf(alice), 0);
        assertEq(tokenB.balanceOf(alice), 200);
    }
    
    function testTokenBSwappedForTokenA() public {
        address alice = address(0x3);
        tokenB.mint(alice, 100000);
        vm.prank(alice);
        tokenSwap.swapTokenBForTokenA(100);
        assertEq(tokenB.balanceOf(alice), 0);
        assertEq(tokenA.balanceOf(alice), 50);
    }

    function testRecoverTokenAByOwner() public {
        vm.prank(address(this));
        uint256 tokenA_balance = tokenA.balanceOf(address(tokenSwap));
        tokenSwap.recoverTokenA();
        assertEq(tokenA.balanceOf(address(this)), tokenA_balance);
        assertEq(tokenA.balanceOf(address(tokenSwap)), 0);
    }

    function testRecoverTokenAByNonOwner() public {
        address alice = address(0x3);
        vm.prank(alice);
        vm.expectRevert();
        tokenSwap.recoverTokenA();
    }

    function testRecoverTokenBByOwner() public {
        vm.prank(address(this));
        uint256 tokenB_balance = tokenB.balanceOf(address(tokenSwap));
        tokenSwap.recoverTokenB();
        assertEq(tokenB.balanceOf(address(this)), tokenB_balance);
        assertEq(tokenB.balanceOf(address(tokenSwap)), 0);
    }

    function testRecoverTokenBByNonOwner() public {
        address alice = address(0x3);
        vm.prank(alice);
        vm.expectRevert();
        tokenSwap.recoverTokenB();
    }
}