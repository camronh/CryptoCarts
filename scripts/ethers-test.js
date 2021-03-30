const ethers = require("ethers");

async function run() {
  const contractJson = require("../src/contracts/ATC.json");
  // An example Provider

  const provider = new ethers.providers.JsonRpcProvider();
//   const provider = ethers.getDefaultProvider();
  provider.listAccounts().then(result => console.log(result))

  const signer = ethers.Wallet.createRandom().connect(provider);

  const exampleClient = new ethers.Contract(
    "0xd8D403602f125AFb6b597771317284F28B5F2D15",
    contractJson.abi,
    signer
    // "d63372c9ec2e312fe98747c6075112987abf2871beffa9677716937a446dee13"
  );

  console.log("Registering");
  await exampleClient.register("Camron");
  console.log(`getting slots....\n\n`);
  const data = await exampleClient.getSlots();
  console.log({ data });
}

run();
