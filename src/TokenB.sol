// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenB is ERC20 {
    constructor(uint256 initialSupply) ERC20("TokenB", "TB") {
        _mint(msg.sender, initialSupply);
    }
}