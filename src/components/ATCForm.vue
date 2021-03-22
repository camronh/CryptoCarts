<template>
  <v-container>
    <template v-if="!attemptedLogin">
      <v-btn elevation="2" @click="checkAccount">Check for Account!</v-btn>
    </template>
    <template v-if="unregisteredUser">
      <v-card-title>
        Register
      </v-card-title>
      <v-text-field
        v-model="freshUsername"
        label="Create a username"
        required
      ></v-text-field>
      <v-btn @click="register">
        Sign Up!
      </v-btn>
    </template>
    <template v-if="loggedIn">
      <v-card>
        <v-card-title>D R O P S</v-card-title>
        <v-list>
          <v-list-item-group v-model="selectedDrop" color="primary">
            <v-list-item v-for="(drop, i) of userDrops" :key="i">
              {{ drop.title }}
            </v-list-item>
          </v-list-item-group>
        </v-list>
        <v-card-actions>
          <v-btn @click="addingDropDialog = true"
            ><v-icon>mdi-plus</v-icon></v-btn
          >
          <!-- <v-btn :disabled="!selectedDrop" @click="closeDrop"
            ><v-icon>mdi-minus</v-icon></v-btn
          > -->
        </v-card-actions>
        <v-divider></v-divider>
        <v-card-title>S L O T S</v-card-title>
        <v-list>
          <v-list-item-group v-model="selectedSlot" color="primary">
            <v-list-item v-for="(slot, i) of userSlots" :key="i">
              {{ slot.title }}
            </v-list-item>
          </v-list-item-group>
        </v-list>
        <v-card-actions>
          <v-btn @click="addingSlotDialog = true"
            ><v-icon>mdi-plus</v-icon></v-btn
          >
          <!-- <v-btn :disabled="!selectedDrop" @click="closeDrop"
            ><v-icon>mdi-minus</v-icon></v-btn
          > -->
        </v-card-actions>
      </v-card>
    </template>
    <v-dialog v-model="addingDropDialog">
      <v-card>
        <v-card-title>Create Drop</v-card-title>
        <v-card-text>
          <v-text-field
            v-model="newDrop.title"
            label="Title"
            required
          ></v-text-field>
          <v-text-field
            v-model="newDrop.price"
            label="Price"
            required
          ></v-text-field>
        </v-card-text>
        <v-card-actions>
          <v-btn @click="addNewDrop">
            Create Drop
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-dialog v-model="addingSlotDialog">
      <v-card>
        <v-card-title>Add Slot</v-card-title>
        <v-card-text>
          <v-text-field
            v-model="procurer.address"
            :disabled="procurer.valid"
            label="Address of Procurer"
            required
          ></v-text-field>
          <v-list>
            <v-list-item-group v-model="procurer.selectedDrop" color="primary">
              <v-list-item v-for="(drop, i) of procurer.drops" :key="i">
                {{ drop.title }}
              </v-list-item>
            </v-list-item-group>
          </v-list>
        </v-card-text>
        <v-card-actions>
          <v-btn v-if="!procurer.valid" @click="searchForProcurer">
            Find Procurer
          </v-btn>
          <v-btn v-else @click="addNewDrop">
            Create Drop
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-snackbar v-model="snackbar"> {{ snackbarMsg }} </v-snackbar>
  </v-container>
</template>

<script>
import web3 from "../../contracts/web3";
// import Web3 from "web3";

import ATCjson from "../contracts/ATC.json";
import { mapGetters } from "vuex";

export default {
  name: "ATCForm",
  data() {
    return {
      price: 0,
      accountFound: false,
      attemptedLogin: false,
      addingDropDialog: false,
      addingSlotDialog: false,
      procurerFound: false,
      selectedDrop: null,
      selectedSlot: null,
      selectedProcurerDrop: null,
      snackbarMsg: "",
      snackbar: false,
      product: "",
      freshUsername: "",

      contractAddress: "",
      userDrops: [],
      userSlots: [],
      procurer: {
        valid: false,
        address: "",
        drops: [],
        selectedDrop: null,
      },
      newDrop: {
        title: "",
        price: 0,
      },
      fetchSlot: {
        address: "",
      },
      contract: {},
      userData: {},
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
    priceInEther() {
      return this.price / 1000000000000000000;
    },
    unregisteredUser() {
      if (this.attemptedLogin && !this.loggedIn) return true;
      else return false;
    },
  },
  async created() {
    const [account] = await web3.eth.getAccounts();
    const userData = await this.drizzleInstance.contracts.ATC.methods
      .userData(account)
      .call();
    console.log({ userData });
    // this.userData = userData;
    // console.log(this.drizzleInstance.web3);
    // var Contract = require("web3-eth-contract");
    // console.log("Step 1");
    // console.log(Contract);
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
    async checkAccount() {
      try {
        const [account] = await web3.eth.getAccounts();
        const userData = await this.drizzleInstance.contracts.ATC.methods
          .userData(account)
          .call();
        console.log({ userData });
        await this.getUserDrops();
        this.attemptedLogin = true;
        if (!userData.username.length) return;
        this.userData = userData;
        this.userData.address = account;
        this.loggedIn = true;
      } catch (e) {
        console.log("Auth Error", e);
        return false;
      }
    },
    async setContract() {
      if (await this.loggedIn) return;
      const Contract = new web3.eth.Contract(ATCjson.abi, this.contractAddress);

      // this.drizzleInstance.contract

      const price = await Contract.methods.price().call();
      const title = await Contract.methods.title().call();
      //   const address = await Contract.address;

      this.price = price;
      this.product = title;
      this.contract = Contract;
      //   this.contractAddress = this.address;
      // .storedData()
      // .call();
      // .price()
      // .send();

      //   console.log({ price });
      //   let data = this.getContractData({
      //     contract: "ATC",
      //     method: "price",
      //   });
      //   console.log({ data });
    },
    async buyCart() {
      //   console.log(this.drizzleInstance.web3.eth.accounts);
      //   const [account] = await this.drizzleInstance.web3.eth.getAccounts();
      const [account] = await web3.eth.getAccounts();
      console.log({ account });
      //   console.log(address);
      await this.contract.methods
        .createDeal()
        .send({ from: account, value: this.price });
    },
    async registered() {
      try {
        const [account] = await web3.eth.getAccounts();
        const userData = await this.drizzleInstance.contracts.ATC.methods
          .userData(account)
          .call();
        console.log({ userData });
        if (!userData.username.length) return false;
        this.userData = userData;
        this.userData.address = account;
        return true;
      } catch (e) {
        console.log("Auth Error", e);
        return false;
      }
    },
    async register() {
      // console.log(this.userData.address);
      const [account] = await web3.eth.getAccounts();
      // console.log(account);
      const results = await this.drizzleInstance.contracts.ATC.methods
        .register(this.freshUsername)
        .send({ from: account });
      console.log(results);
    },
    async addNewDrop() {
      const results = await this.drizzleInstance.contracts.ATC.methods
        .addDrop(this.newDrop.title, this.newDrop.price)
        .send({ from: this.userData.address });

      console.log({ results });
      this.addingDropDialog = false;
      await this.getUserDrops();
    },
    async getUserDrops() {
      const userDrops = await this.drizzleInstance.contracts.ATC.methods
        .getDrops()
        .call();
      console.log({ userDrops });
      this.userDrops = userDrops;
    },
    async searchForProcurer() {
      try {
        const results = await this.drizzleInstance.contracts.ATC.methods
          .searchProcurerDrops(this.procurer.address)
          .call();
        if (!results.length) {
          this.snackbarMsg = "Address is not running any slots right now";
          this.snackbar = true;
          return;
        }
        this.procurer.drops = results;
        this.procurer.valid = true;

        // console.log({ results });
      } catch (error) {
        this.snackbarMsg = "Failed to fetch address";
        this.snackbar = true;
      }
      // this.addingDropDialog = false;
      // await this.getUserDrops();
    },
  },
};
</script>
