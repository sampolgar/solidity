// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Verifier} from "../src/Verifier.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "forge-std/console.sol";

contract VerifierTest is Test {
    using ECDSA for bytes32;

    Verifier _verifier;

    address _owner;
    uint256 _privateKey = 0x1010101010101010101010101010101010101010101010101010101010101010;

    function setUp() public {
        _owner = vm.addr(_privateKey);
        _verifier = new Verifier(_owner);
    }

    function testVerifyV1andV2() public {
        string memory message = "attack at dawn";

        bytes32 msgHash = keccak256(abi.encode(message)).toEthSignedMessageHash();

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_privateKey, msgHash);

        bytes memory signature = abi.encodePacked(r, s, v);
        assertEq(signature.length, 65);

        console.logBytes(signature);
        _verifier.verifyV1(message, r, s, v);
        _verifier.verifyV2(message, signature);
    }
}
