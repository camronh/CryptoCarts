<template>
  <v-container>
    <v-card-title>
      ATC Form
    </v-card-title>
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
    <v-btn elevation="2">Launch Auction</v-btn>
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
// import ATC from "../../contracts/ATCInstance";
import { mapGetters } from "vuex";

export default {
  name: "ATCForm",
  data() {
    return {
      price: 100,
      product: "ps5",
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
  created() {
    this.$store.dispatch("drizzle/REGISTER_CONTRACT", {
      contractName: "ATC",
      method: "getNames",
      methodArgs: [],
    });
  },
  methods() {},
};
</script>
