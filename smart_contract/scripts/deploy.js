// update it as per latest changes

const { hexStripZeros } = require("ethers/lib/utils");

const main = async () => {
  const domainContractFactory = await hre.ethers.getContractFactory("Domains");
  const domainContract = await domainContractFactory.deploy("ninja");
  await domainContract.deployed();

  console.log("Contract deployed to:", domainContract.address);

  let txn = await domainContract.register("mortal", {
    value: hre.ethers.utils.parseEther("0.2"),
  });
  await txn.wait();
  console.log("Minted Doamin {{ mortal.ninja }}");

  // Now lets set some records in our Domain
  txn = await domainContract.setRecord("mortal", "I am Mortal or Crypt??");
  await txn.wait();
  console.log("Set record for {{ mortal.ninja }}");

  const address = await domainContract.getAddress("mortal");
  console.log("Owner of the domain mortal: ", address);

  const balance = await hre.ethers.provider.getBalance(domainContract.address);
  console.log("Contract Balance: ", hre.ethers.utils.formatEther(balance));
};

// update it as required
const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
