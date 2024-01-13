// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";

contract SomeERC20 is ERC20 {
    constructor(string memory _name, string memory _symbol, uint8 _decimals) ERC20(_name, _symbol, _decimals) {}

    function mint(address to, uint256 value) public virtual {
        _mint(to, value);
    }

    function burn(address from, uint256 value) public virtual {
        _burn(from, value);
    }
}