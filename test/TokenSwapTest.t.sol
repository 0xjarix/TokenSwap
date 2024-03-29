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
    address alice;
    function setUp() public virtual {
        tokenSwap = new TokenSwap();
        tokenA = tokenSwap.tokenA();
        tokenB = tokenSwap.tokenB();
        console.log("tokenA address:", address(tokenA));
        console.log("tokenB address:", address(tokenB));
        console.log("tokenSwap address:", address(tokenSwap));
        console.log("tokenSwap balance tokenA:", tokenA.balanceOf(address(tokenSwap)));
        console.log("tokenSwap balance tokenB:", tokenB.balanceOf(address(tokenSwap)));
        alice = address(0x3);
        tokenA.mint(alice, 100000);
        tokenB.mint(alice, 100000);
    }

    function testTokenASwappedForTokenB() public {
        vm.startPrank(alice);
        uint256 tokenA_balance = tokenA.balanceOf(alice);
        uint256 tokenB_balance = tokenB.balanceOf(alice);
        tokenA.approve(address(tokenSwap), 100);
        tokenSwap.swapTokenAForTokenB(100);
        assertEq(tokenA.balanceOf(alice), tokenA_balance - 100);
        assertEq(tokenB.balanceOf(alice), tokenB_balance + 200);
    }
    
    function testTokenBSwappedForTokenA() public {
        vm.startPrank(alice);
        uint256 tokenA_balance = tokenA.balanceOf(alice);
        uint256 tokenB_balance = tokenB.balanceOf(alice);
        tokenB.approve(address(tokenSwap), 100);
        tokenSwap.swapTokenBForTokenA(100);
        assertEq(tokenB.balanceOf(alice), tokenB_balance - 100);
        assertEq(tokenA.balanceOf(alice), tokenA_balance + 50);
    }

    function testRecoverTokenAByOwner() public {
        vm.startPrank(address(this));
        uint256 tokenA_balance = tokenA.balanceOf(address(tokenSwap));
        tokenSwap.recoverTokenA();
        assertEq(tokenA.balanceOf(address(this)), tokenA_balance);
        assertEq(tokenA.balanceOf(address(tokenSwap)), 0);
    }

    function testRecoverTokenAByNonOwner() public {
        vm.startPrank(alice);
        vm.expectRevert();
        tokenSwap.recoverTokenA();
    }

    function testRecoverTokenBByOwner() public {
        vm.startPrank(address(this));
        uint256 tokenB_balance = tokenB.balanceOf(address(tokenSwap));
        tokenSwap.recoverTokenB();
        assertEq(tokenB.balanceOf(address(this)), tokenB_balance);
        assertEq(tokenB.balanceOf(address(tokenSwap)), 0);
    }

    function testRecoverTokenBByNonOwner() public {
        vm.startPrank(alice);
        vm.expectRevert();
        tokenSwap.recoverTokenB();
    }
}