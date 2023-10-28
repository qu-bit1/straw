const hre = require("hardhat");

async function main() {
  const Straw = await hre.ethers.getContractFactory("Lock");
  const straw = await Straw.deploy();

  await straw.deployed();

  console.log(
    `Contract Address ${straw.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
