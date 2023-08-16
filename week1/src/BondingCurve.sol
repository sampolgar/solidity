// The more tokens a user buys, the more expensive the token becomes.
// To keep things simple, use a linear bonding curve.
// When a person sends a token to the contract with ERC1363 or ERC777, it should trigger the receive function.
// If you use a separate contract to handle the reserve and use ERC20, you need to use the approve and send workflow.
// This should support fractions of tokens.

// 1. create an ERC1363 contract that mints tokens when a sent tokens
// 2. ensure it works with fractions of tokens
// 3. change the minting mechanism to bonding curve

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC1363, ERC20} from "../lib/erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IERC1363Receiver} from "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";
import {IERC1363Spender} from "@openzeppelin/contracts/interfaces/IERC1363Spender.sol";
import "../lib/abdk-libraries-solidity/ABDKMath64x64.sol";

// import "../lib/openzeppelin-contracts/contracts/interfaces/IERC1363.sol";
// import "../lib/openzeppelin-contracts/contracts/interfaces/IERC1363Receiver.sol";
// import "../lib/openzeppelin-contracts/contracts/interfaces/IERC1363Spender.sol";

// contract BondingCurve is ERC1363 {
//     address _owner;

//     constructor() ERC20("PayableToken", "PT") {
//         _owner = msg.sender;
//         _mint(msg.sender, 1 ether);
//     }

//     //function that calls & mints
//     function freeMint() public {
//         _mint(msg.sender, 1 ether);
//     }
// }

contract BondingCurve is ERC20 {
    uint256 public poolBalanceInReserveTokens;
    uint256 private constant _MAX_RESERVE_RATIO = 1_000_000;
    uint256 private constant _RESERVE_RATIO = 500_000; //50%
    uint256 public tokenSupply;

    constructor() ERC20("TokenName", "TKN") {
        poolBalanceInReserveTokens = 0;
        tokenSupply = 0;
    }

    //PurchaseReturn = ContinuousTokenSupply * ((1 + ReserveTokensReceived / ReserveTokenBalance) ^ (ReserveRatio) - 1)
    //_reserveTokenReceivedOverBalance = (1 + ReserveTokensReceived / ReserveTokenBalance)
    //_reserveRatioMinusOne = (ReserveRatio) - 1
    function calculatePurchaseReturn(uint256 _depositAmountInReserveTokens) public view returns (uint256) {
        uint256 result;
        uint256 _reserveTokenReceivedOverBalance = (1 + _depositAmountInReserveTokens) / poolBalanceInReserveTokens;
        uint256 _reserveRatioMinusOne = (_RESERVE_RATIO / _MAX_RESERVE_RATIO) - 1;
        result = tokenSupply * _reserveTokenReceivedOverBalance ^ _reserveRatioMinusOne;
        return result;
    }

    function buyTokens() public payable returns (bool) {
        // require(msg.value > 0);
        uint256 tokensToMint = calculatePurchaseReturn(msg.value);
        tokenSupply = tokenSupply + tokensToMint;
        poolBalanceInReserveTokens = poolBalanceInReserveTokens + msg.value;
        _mint(msg.sender, tokensToMint);
        return true;
    }
}
