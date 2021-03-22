<template>
  <v-container>
    <v-card-title>
      ATC Form
    </v-card-title>
    <v-text-field
      v-model="contractAddress"
      label="Address"
      required
    ></v-text-field>
    <v-text-field
      v-model="product"
      disabled
      label="Product"
      required
    ></v-text-field>
    <v-text-field
      v-model="price"
      label="Price"
      disabled
      required
    ></v-text-field>
    <v-btn elevation="2" @click="setContract">Launch Auction</v-btn>
    <div v-if="isDrizzleInitialized" id="app">
      <h1>Sign the Guestbook</h1>
      <drizzle-contract-form contractName="ATC" />
      <h2>Guests:</h2>
      <ul v-if="getNames">
        <li v-for="(name, i) in getNames" :key="i">{{ utils.toUtf8(name) }}</li>
      </ul>
    </div>
    <div v-else>
      Loading application...
    </div>
  </v-container>
</template>

<script>
// import web3 from "../../contracts/web3";
// import Web3 from "web3";

// import ATCjson from "../contracts/ATC.json";
import { mapGetters } from "vuex";

export default {
  name: "ATCForm",
  data() {
    return {
      price: 0,
      product: "",
      contractAddress: "",
    };
  },
  computed: {
    ...mapGetters("drizzle", ["drizzleInstance", "isDrizzleInitialized"]),
    ...mapGetters("contracts", ["getContractData"]),
    getNames() {
      let data = this.getContractData({
        contract: "ATC",
        method: "getNames",
      });
      if (data === "loading") return false;
      return data;
    },
    utils() {
      return this.drizzleInstance.web3.utils;
    },
  },
  async created() {
    // console.log(this.drizzleInstance.web3);
    // var Contract = require("web3-eth-contract");
    // console.log("Step 1");
    // var address = "0xe39e3CC3eE04E4dE9FA43336f5280e69BA05D807";
    // // set provider for all later instances to use
    // Contract.setProvider("ws://localhost:9545");
    // var contract = new Contract(ATCjson.abi, address);
    // console.log(ATCjson.abi);
    // var MyContract = new Web3.etherium.contract(ATCjson.abi);
    // const web3 = await Web3();
    // if (!web3) {
    //   return undefined;
    // }
    // const accounts = await web3.eth.getAccounts();
    // const contract = await new web3.eth.Contract(ATCjson.abi, address);
    // console.log({ accounts });
    // console.log(contract.methods.price.call());
    //   const value = web3.utils.toWei(String(amount), "ether");
    //   await contract.methods
    //     .pay(reference, value)
    //     .send({ from: accounts[0], value: value });
    // console.log("step 1");
    // initiate contract for an address
    // console.log({ myContractInstance });
    // console.log("DRizls", data);
    // console.log("DRISZLE", this.drizzleInstance.contracts);
    // this.context.drizzle.addContract(contractConfig, events)
    // this.$store.dispatch("drizzle/REGISTER_CONTRACT", {
    //   contractName: "ATC",
    //   method: "getNames",
    //   methodArgs: [],
    // });
  },
  methods: {
    async setContract() {
      // this.drizzleInstance.contract
      const price = await this.drizzleInstance.contracts.ATC.methods.price().call();
      // .storedData()
      // .call();
      // .price()
      // .send();

      console.log({ price });
      //   let data = this.getContractData({
      //     contract: "ATC",
      //     method: "price",
      //   });
      //   console.log({ data });
    },
  },
};
</script>
