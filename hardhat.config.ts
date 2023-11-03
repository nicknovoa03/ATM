import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from 'dotenv';
dotenv.config();

const EthPrivateKey = process.env.ETH_PRIVATE_KEY!

const EthTestPrivateKey = process.env.BSC_TEST_PRIVATE_KEY!

const EtherscanApiKey = process.env.ETHERSCAN_API_KEY!


const EthProvider = "https://mainnet.infura.io/v3/" + process.env.INFURA_API_KEY
const EthTestnetProvider = "https://sepolia.infura.io/v3/" + process.env.INFURA_API_KEY


const config: HardhatUserConfig = {
  solidity: "0.8.18",
  etherscan: {
    apiKey: EtherscanApiKey
  },
  networks: {
    mainnet: {
      url: EthProvider,
      accounts: [EthPrivateKey]
    },
    sepolia: {
      url: EthTestnetProvider,
      accounts: [EthTestPrivateKey]
    },
  }
};

export default config;
