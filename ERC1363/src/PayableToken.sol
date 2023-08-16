// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";

contract PayableToken is ERC1363 {
    address owner;

    constructor() ERC20("PayableToken", "PT") {
        owner = msg.sender;
        _mint(msg.sender, 1 ether);
    }

    //function that calls & mints
    function freeMint() public {
        _mint(msg.sender, 1 ether);
    }
}
