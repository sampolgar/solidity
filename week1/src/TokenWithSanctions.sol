//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//Create a fungible token that allows an admin to ban specified addresses from sending and receiving tokens.
contract TokenWithSanctions is ERC20 {
    //list of banned addresses
    mapping(address => bool) public bannedAddresses;
    address public admin;

    constructor(uint256 initialSupply) ERC20("Sanction", "SNCT") {
        admin = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    /// @notice modifier that checks if the sender is the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }

    /// @notice override function requiring the from or to address unbanned
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(!bannedAddresses[from], "banned");
        require(!bannedAddresses[to], "banned");
    }

    /// @notice sets new admin with modifier ensuring only admin can set new admin. Emits a log
    function setAdmin(address _admin) external onlyAdmin {
        admin = _admin;
    }

    /// @notice bans an address from transfering or receiving. Emits a log
    function banAddress(address _address) external onlyAdmin {
        bannedAddresses[_address] = true;
    }
}
