<template>
  <v-container>
    <v-btn @click="refresh">
      <v-icon>
        mdi-refresh
      </v-icon>
    </v-btn>
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
        <v-card-title>Welcome {{ userData.username }}</v-card-title>

        <v-card-title>D R O P S</v-card-title>
        <v-list>
          <v-list-item-group v-model="selectedDrop" mandatory color="primary">
            <v-list-item
              v-for="(drop, i) of userDrops"
              :key="i"
              @click="getDropSlots(i)"
            >
              {{ drop.title }}
              <v-dialog v-model="dropInfoDialog">
                <SlotTable
                  :drop="drop"
                  :dropSlots="dropSlots"
                  :account="myAddress"
                  :dropIndex="selectedDrop"
                />
              </v-dialog>
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
            <v-list-item
              v-for="(slot, i) of userSlots"
              :key="i"
              @click="getSlotData(slot)"
            >
              {{ slot }}
              <v-dialog v-model="slotInfoDialog">
                <v-card>
                  <v-card-title>Slot Info</v-card-title>
                  <v-card-text>
                    <v-text-field
                      v-model="slotInfo.title"
                      label="Title"
                      disabled
                    ></v-text-field>
                    <v-text-field
                      v-model="slotInfo.slotID"
                      label="Slot ID"
                      disabled
                    ></v-text-field>
                    <v-text-field
                      v-model="slotInfo.price"
                      label="Price"
                      disabled
                    ></v-text-field>
                    <v-text-field
                      v-model="slotInfo.paidOut"
                      label="Paid Out"
                      disabled
                    ></v-text-field>
                    <v-text-field
                      v-model="slotInfo.paidOut"
                      label="Paid Out"
                      disabled
                    ></v-text-field>
                    <v-text-field
                      :value="progressString(slotInfo.slotStatus)"
                      label="Status"
                      readonly
                      disabled
                    ></v-text-field>
                  </v-card-text>
                </v-card>
              </v-dialog>
            </v-list-item>
          </v-list-item-group>
        </v-list>
        <v-card-actions>
          <v-btn @click="addNewSlot"><v-icon>mdi-plus</v-icon></v-btn>
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
              <v-list-item
                v-for="(drop, i) of procurer.drops"
                :key="i"
                @click="buyCart"
              >
                {{ drop.title }} - {{ drop.price }} Ether
              </v-list-item>
            </v-list-item-group>
          </v-list>
        </v-card-text>
        <v-card-actions>
          <v-btn v-if="!procurer.valid" @click="searchForProcurer">
            Find Procurer
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-snackbar v-model="snackbar"> {{ snackbarMsg }} </v-snackbar>
  </v-container>
</template>

<script>
import web3 from "../../contracts/web3";
import short from "short-uuid";

import SlotTable from "./SlotTable";
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
      dropInfoDialog: false,
      slotInfoDialog: false,
      procurerFound: false,
      loggedIn: false,
      selectedDrop: null,
      selectedSlot: null,
      selectedProcurerDrop: null,
      snackbarMsg: "",
      snackbar: false,
      myAddress: null,
      product: "",
      slotInfo: {},
      freshUsername: "",
      dropSlots: [],
      contractAddress: "0x6410968594fd5341a74DE5DA89FF3e637d5b0190",
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
  components: {
    SlotTable,
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
  async created() {},
  methods: {
    async checkAccount() {
      // const atcContract = new web3.eth.Contract(
      //   ATCjson.abi,
      //   this.contractAddress
      // );
      const [address] = await web3.eth.getAccounts();
      this.myAddress = address;
      // console.log(this.myAddress);
      const userData = await this.drizzleInstance.contracts.ATC.methods
        .userData(this.myAddress)
        .call();
      console.log({ userData });

      this.attemptedLogin = true;
      if (!userData.username.length) return;
      await this.refresh();
      // await this.getUserDrops();
      // this.userData = userData;
      // this.userData.address = account;
      this.loggedIn = true;
    },

    progressString(progress) {
      console.log({ progress });
      switch (progress) {
        case "0":
          return "Pending...";
        case "1":
          return "Success!";
        case "2":
          return "Failed";
      }
    },
    async setContract() {
      // if (await this.loggedIn) return;
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
      try {
        const [account] = await web3.eth.getAccounts();
        const { address, selectedDrop, drops } = this.procurer;
        const slotID = short.generate();
        const results = await this.drizzleInstance.contracts.ATC.methods
          .buySlot(address, selectedDrop, slotID, drops[selectedDrop].title)
          .send({ from: account, value: drops[selectedDrop].price });

        console.log(results);
        this.addingSlotDialog = false;
        await this.refresh();
      } catch (error) {
        this.snackbarMsg = "Slot purchase failed";
        this.snackbar = true;
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
        .send({ from: this.myAddress });

      console.log({ results });
      this.addingDropDialog = false;
      await this.getUserDrops();
    },
    addNewSlot() {
      this.procurer.valid = false;
      this.procurer.drops = [];
      this.addingSlotDialog = true;
    },
    async getUserDrops() {
      const userDrops = await this.drizzleInstance.contracts.ATC.methods
        .getDrops()
        .call();
      console.log({ userDrops });
      this.userDrops = userDrops;
    },
    async refresh() {
      await this.getUserDrops();
      await this.getSlotIDs();
      this.userData = await this.drizzleInstance.contracts.ATC.methods
        .userData(this.myAddress)
        .call();

      // await this.getUserSlots();
    },
    async getDropSlots(dropIndex) {
      // await this.refresh();
      this.dropSlots = this.userDrops[dropIndex].slotIDs;
      console.log(this.dropSlots);
      this.dropInfoDialog = true;
      console.log({ dropIndex });
    },
    async getSlotIDs() {
      this.userSlots = await this.drizzleInstance.contracts.ATC.methods
        .getUserSlotIDs()
        .call();
      // console.log({ slotIDs });
    },
    async getSlotData(slotID) {
      this.slotInfo = await this.drizzleInstance.contracts.ATC.methods
        .slots(slotID)
        .call();
      this.slotInfoDialog = true;
      // console.log({ slotIDs });
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
