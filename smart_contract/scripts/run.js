// updated main as per latest changes

const main = async () => {
  const [owner, superCoder] = await hre.ethers.getSigners();

  const domainContractFactory = await hre.ethers.getContractFactory("Domains");

  // Passing ninja to constructor
  const domainContract = await domainContractFactory.deploy("ninja");
  await domainContract.deployed();

  console.log("Contract deployed to:", domainContract.address);
  console.log("Contract Owner:", owner.address);
  // console.log("Contract deployed by:", owner.address);

  // Passing in a second variable - value. This is the moneyyyyyyyyyy
  let txn = await domainContract.register("amaz", {
    value: hre.ethers.utils.parseEther("1234"), // '0.1'< >'1234' as I'm not using metamask wallet, not deploying on Alchemy network this "" run.js ""
  });
  await txn.wait();

  // const address = await domainContract.getAddress("mortal");
  // console.log("Owner of domain mortal:", address);

  const balance = await hre.ethers.provider.getBalance(domainContract.address);
  console.log("Contract Balance: ", hre.ethers.utils.formatEther(balance));

  // Grabbing the funds from the contract! (as superCoder)[other than owner]
  try {
    txn = await domainContract.connect(superCoder).withdraw();
    await txn.wait();
  } catch (error) {
    console.log("Could not rob contract");
  }

  // Let's look in their wallet so we can compare later
  let ownerBalance = await hre.ethers.provider.getBalance(owner.address);
  console.log(
    "Balance of owner before withdrawal:",
    hre.ethers.utils.formatEther(ownerBalance)
  );

  // Oops, looks like the owner is saving their money!
  txn = await domainContract.withdraw(); // Transferring balance of CONTRACT to Owner
  await txn.wait(); // domainContract.connect(owner).withdraw() not required as by default the first element of an array is the owner

  // Fetch balance of contract & owner
  const contractBalance = await hre.ethers.provider.getBalance(
    domainContract.address
  );
  ownerBalance = await hre.ethers.provider.getBalance(owner.address);

  console.log(
    "Contract balance after withdrawal:",
    hre.ethers.utils.formatEther(contractBalance)
  );
  console.log(
    "Balance of owner after withdrawal:",
    hre.ethers.utils.formatEther(ownerBalance)
  );

  // make it even better, experiment various possiblities

  // Trying to set a record that doesn't belong to me!
  //   txn = await domainContract
  //     .connect(randomPerson)
  //     .setRecord("doom", "Haha my domain now!");
  //   await txn.wait();
};

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
