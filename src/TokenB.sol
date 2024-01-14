// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";

contract TokenB is ERC20 {
    constructor() 
    ERC20("TokenB", "TB", 18) {
        _mint(msg.sender, type(uint256).max);
    }
}