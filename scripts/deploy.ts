import { ethers } from "hardhat";

async function main() {

  const oasisToken = '0xF0Dc9fc0669f068e04aD79f7d70618D3f9Aad439'

  const AtmOasis = await ethers.deployContract("AtmOasis", [oasisToken]);

  await AtmOasis.waitForDeployment();

  console.log(
    `ATM Oasis deployed to ${AtmOasis}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
