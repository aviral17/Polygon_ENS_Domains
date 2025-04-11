// import "@nomiclabs/hardhat-ethers";
// import "@nomicfoundation/hardhat-chai-matchers";
require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-web3");

/** @type import('hardhat/config').HardhatUserConfig */

// replace it with foundary

task("accounts", "Prints accounts", async (_, { web3 }) => {
  console.log(await web3.eth.getAccounts());
});

module.exports = {
  solidity: "0.8.9",
  networks: {
    mumbai: {
      url: process.env.STAGING_ALCHEMY_KEY,
      accounts: [process.env.PRIVATE_KEY],
    },
    // mainnet: {
    //   chainId: 1,
    //   url: process.env.PROD_ALCHEMY_KEY,
    //   accounts: [process.env.PRIVATE_KEY],
    // },
  },
};
