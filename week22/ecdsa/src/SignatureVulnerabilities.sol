// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SignatureVulnerabilities is ERC20 {
    address _signer; //     caution! defaults to address(0)

    uint256 public constant AIRDROP_AMOUNT = 1000 * 10 ** 18;

    constructor(uint256 initialSupply) ERC20("Gold", "GLD") {
        _mint(msg.sender, initialSupply);
    }

    function airdrop() external {
        _mint(msg.sender, AIRDROP_AMOUNT);
    }

    // address _signer is initialized to (0), this compares _signer to the ecrecover signature
    // function airdropV1(address who, uint256 amount, uint8 v, bytes32 r, bytes32 s) external {
    //     //ecrecover = address from ecdsa sig
    //     // require(_signer == ecrecover(keccak256(abi.encode(who, amount)), v, r, s), "invalid");
    //     _mint(msg.sender, AIRDROP_AMOUNT);
    // }

    // checks for address(0)
    function airdropV2Better(address who, uint256 amount, uint8 v, bytes32 r, bytes32 s) external {
        require(_signer != address(0), "invalid sig, can't be 0");
        require(_signer == ecrecover(keccak256(abi.encode(who, amount)), v, r, s), "invalid");
        _mint(msg.sender, AIRDROP_AMOUNT);
    }
}
