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
        "0xDC7A2184449Aa2B32e83765a67eAE8D9CA4C2FdC"
        // Local
        // "0x6712008CCD96751d586FdBa0DEf5495E0E22D904"
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
