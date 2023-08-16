// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, Vm} from "forge-std/test.sol";
import {TokenWithSanctions} from "../src/TokenWithSanctions.sol";
import {DeployTokenWithSanctions} from "../script/DeployTokenWithSanctions.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "forge-std/console.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract TokenWithSanctionsTest is Test {
    TokenWithSanctions public token;
    DeployTokenWithSanctions public deployer;
    address public deployerAddress;
    address _alice;
    address _bob;

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        console.log("deploying contract");

        deployer = new DeployTokenWithSanctions();
        token = deployer.run();
        _alice = makeAddr("alice");
        _bob = makeAddr("bob");

        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);

        token.transfer(_alice, STARTING_BALANCE);
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testBalance() public {
        assertEq(STARTING_BALANCE, token.balanceOf(_alice));
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 50;

        //Alice approves bob to spend tokens on her behalf
        vm.prank(_alice);
        token.approve(_bob, initialAllowance);

        //Bob transfers tokens from Alice to himself
        vm.prank(_bob);
        token.transferFrom(_alice, _bob, transferAmount);

        assertEq(token.balanceOf(_alice), STARTING_BALANCE - transferAmount);
        assertEq(token.balanceOf(_bob), transferAmount);
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(token)).mint(address(this), 1);
    }

    function testTransfer() public {
        uint256 transferAmount = 50;

        //Alice transfers tokens to Bob
        vm.prank(_alice);
        token.transfer(_bob, transferAmount);

        assertEq(token.balanceOf(_alice), STARTING_BALANCE - transferAmount);
        assertEq(token.balanceOf(_bob), transferAmount);
    }

    function testTransferFrom() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 50;

        //Alice approves bob to spend tokens on her behalf
        vm.prank(_alice);
        token.approve(_bob, initialAllowance);

        //Bob transfers tokens from Alice to himself
        vm.prank(_bob);
        token.transferFrom(_alice, _bob, transferAmount);

        assertEq(token.balanceOf(_alice), STARTING_BALANCE - transferAmount);
        assertEq(token.balanceOf(_bob), transferAmount);
    }

    function testAdminChange() public {
        address newAdmin = makeAddr("newAdmin");

        // Initial admin changes admin to a new address
        vm.prank(token.admin());
        token.setAdmin(newAdmin);
        assertEq(token.admin(), newAdmin);

        // Non-admin tries to change the admin
        vm.expectRevert();
        vm.prank(_alice);
        token.setAdmin(deployerAddress);
    }

    function testBanAddress() public {
        uint256 transferAmount = 50;
        address _charlie = makeAddr("charlie");

        // Admin bans Alice
        vm.prank(token.admin());
        token.banAddress(_alice);

        // Alice tries to transfer tokens to Bob
        vm.expectRevert();
        vm.prank(_alice);
        token.transfer(_bob, transferAmount);

        // Bob tries to transfer tokens to Alice
        vm.expectRevert();
        vm.prank(_bob);
        token.transfer(_alice, transferAmount);

        // Charlie tries to approve Alice to spend his tokens
        vm.expectRevert();
        vm.prank(_charlie);
        token.approve(_alice, transferAmount);
    }
}
