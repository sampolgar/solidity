//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenSale is ERC20 {
    address payable public beneficiary;
    uint256 public pricePerToken;

    constructor(address payable beneficiaryAddress, uint256 _pricePerTokenInWei) ERC20("TokenName", "TKN") {
        beneficiary = beneficiaryAddress;
        pricePerToken = _pricePerTokenInWei;
    }

    function buyTokens() public payable {
        uint256 amount = msg.value / pricePerToken;
        _mint(msg.sender, amount);
        beneficiary.transfer(msg.value);
    }
}
