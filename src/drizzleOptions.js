import ATC from "@/contracts/ATC.json";
import web3 from "../contracts/web3";

const options = {
  web3: {
    block: false,
    fallback: {
      type: "ws",
      url: "ws://127.0.0.1:9545",
    },
  },
  // The contracts to monitor
  contracts: [
    {
      contractName: "ATC",
      web3Contract: new web3.eth.Contract(
        ATC.abi,
        // Ropsten
        "0x72380857D023c33BF07098EA8E31CE3D8d041b6c"
        // Local
        // "0x5FbDB2315678afecb367f032d93F642f64180aa3"
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
