// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {SignatureVulnerabilities} from "../src/SignatureVulnerabilities.sol";
import {DeploySignatureVulnerabilities} from "../script/DeploySignatureVulnerabilities.s.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "forge-std/console.sol";

contract SignatureVulnerabilitiesTest is Test {
    using ECDSA for bytes32;

    SignatureVulnerabilities public signatureVulnerabilityContract;
    DeploySignatureVulnerabilities public deployer;
    address public deployerAddress;

    address owner;
    uint256 _privateKey = 0x1010101010101010101010101010101010101010101010101010101010101010;

    function setUp() public {
        console.log("deploying contract");
        deployer = new DeploySignatureVulnerabilities();
        signatureVulnerabilityContract = deployer.run();

        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);

        owner = vm.addr(_privateKey);
    }

    function testInitialSupply() public {
        assertEq(signatureVulnerabilityContract.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testOwnerBalance() public {
        uint256 ownerOriginalBal = owner.balance;
        assertEq(ownerOriginalBal, 0);
    }

    function testAirdrop() public {
        vm.prank(owner);
        signatureVulnerabilityContract.airdrop();
        console.log(signatureVulnerabilityContract.balanceOf(owner));
        console.log("test here");
        assertTrue(signatureVulnerabilityContract.balanceOf(owner) > 0);
    }

    // function testAirdropV1() public {
    //     //create message, hash, sign
    //     string memory message = "give me airdrop";
    //     bytes32 msgHash = keccak256(abi.encode(message)).toEthSignedMessageHash();
    //     (uint8 v, bytes32 r, bytes32 s) = vm.sign(_privateKey, msgHash);
    //     // bytes memory signature = abi.encodePacked(r, s, v);

    //     signatureVulnerabilityContract.airdropV1(owner, 100, v, r, s);
    //     console.log(signatureVulnerabilityContract.balanceOf(owner));
    //     assertTrue(signatureVulnerabilityContract.balanceOf(owner) > 0);
    // }
}
