const hre = require("hardhat");

async function main() {
  const FlashX = await hre.ethers.getContractFactory("FlashX");
  const flashX = await FlashX.deploy();

  await flashX.deployed();
  console.log("FlashX contract deployed to:", flashX.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error deploying contract:", error);
    process.exit(1);
  });
const hre = require("hardhat");

async function main() {
  const FlashX = await hre.ethers.getContractFactory("FlashX");
  const flashX = await FlashX.deploy();

  await flashX.deployed();
  console.log("FlashX contract deployed to:", flashX.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error deploying contract:", error);
    process.exit(1);
  });
