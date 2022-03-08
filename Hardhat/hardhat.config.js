require("@nomiclabs/hardhat-waffle");
const secrets = require("./secrets.json");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.0",
  networks: {
    mumbai: {
      url: secrets.MumbaiUrl,
      accounts: [secrets.MumbaiPrivateKey],
    },
  },
};
