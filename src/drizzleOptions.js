import ATC from "@/contracts/ATC.json";
import web3 from "../contracts/web3";

const options = {
  web3: {
    block: false,
    fallback: {
      type: "ws",
      url: "ws://127.0.0.1:8545",
    },
  },
  // The contracts to monitor
  contracts: [
    {
      contractName: "ATC",
      web3Contract: new web3.eth.Contract(
        ATC.abi,
        // Ropsten
        // "0x96626531221FB784e0494B905ea08F95Ab02B0bE"
        // Local
        "0xD962a5F050A5F0a2f8dF82aFc04CF1afFE585082"
      ), // An instance of a Web3 contract
    },
  ],
  events: {
    // ATC: ["Paid"],
  },
  polls: {
    // check accounts ever 15 seconds
    accounts: 15000,
  },
};
export default options;
