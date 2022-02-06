require("@nomiclabs/hardhat-waffle");
const projectId = "5ba06443ee6a47b58b4f1639b1587c20"
const fs = require("fs")
const privateKey = fs.readFileSync(".secret").toString()
module.exports = {
  networks: {
      hardhat : {
          chainId: 1337
      },
      mumbai : {
          url: `https://polygon-mumbai.infura.io/v3/${projectId}`,
          accounts: [privateKey]
      },
      mainnet : {
          url: `https://polygon-mainnet.infura.io/v3/${projectId}`,
          accounts: [privateKey]
      }
  },
  solidity: "0.8.4",
};
