import ATC from "@/contracts/ATC.json";
const options = {
  web3: {
    block: false,
    fallback: {
      type: "ws",
      url: "ws://127.0.0.1:9545",
    },
  },
  // The contracts to monitor
  contracts: [ATC],
  events: {
    // ATC: ["Paid"],
  },
  polls: {
    // check accounts ever 15 seconds
    accounts: 15000,
  },
};
export default options;
