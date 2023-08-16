// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Test.sol";
import {NFTToken, ERC165Checker} from "../src/NFTToken.sol";
import {PayableToken} from "../src/PayableToken.sol";

contract PayableTest is Test {
    NFTToken public nft;
    PayableToken public payableToken;

    address contractDeployer = makeAddress("deployer");

    function setUp() public {
        payableToken = new PayableToken();
        nft = new NFTToken(address(payableToken));
    }

    function testTokenMint() public {
        vm.startPrank(contractDeployer);
        payableToken.freeMint();
        payableToken.transferAndCall(address(nft), 0.5 ether, "");
        payableToken.approveAndCall(address(nft), 0.5 ether, "");
        vm.stopPrank();
    }

    function makeAddress(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }
}
