//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//Create a fungible token that allows an admin to ban specified addresses from sending and receiving tokens.
contract TokenWithSanctions is ERC20 {
    //godmode address
    address public godmodeUser;

    constructor(uint256 initialSupply) ERC20("GodMode", "GDM") {
        godmodeUser = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    /// @notice
    // why does this work, I thought the transfer needs to be approved?
    function adminCanTransfer(address from, address to, uint256 amount) public {
        require(msg.sender == godmodeUser, "only godmode user can transfer");
        _transfer(from, to, amount);
    }

    event AdminChanged(address indexed newAdmin);
    event AddressBanned(address indexed _address);
}
