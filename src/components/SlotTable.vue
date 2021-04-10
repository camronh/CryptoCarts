<template>
  <v-data-table :headers="headers" :items="slots" class="elevation-1">
    <template v-slot:item.slotStatus="{ item }">
      <v-chip :color="yellow" dark>
        {{ slotStatusStr(item.slotStatus) }}
      </v-chip>
    </template>

    <template v-slot:item.paidOut="{ item }">
      <v-icon>
        {{ paidOutIcon(item.paidOut) }}
      </v-icon>
    </template>
    <template v-slot:item.actions="{ item }">
      <v-btn-toggle>
        <v-btn :disabled="item.paidOut" @click="markSuccessful(item)">
          Mark Successful
        </v-btn>
        <v-btn :disabled="item.paidOut" @click="markSuccessful(item)">
          Mark Failed
        </v-btn>
        <v-btn :loading="loading" @click="makeAirnodeRequest(item)">
          ?
        </v-btn>
      </v-btn-toggle>
    </template>
  </v-data-table>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  props: ["drop", "dropIndex", "dropSlots", "account"],
  data() {
    return {
      slots: [],
      loading: false,
      headers: [
        {
          text: "Address",
          value: "customer",
        },
        { text: "Title", value: "title" },
        { text: "Price", value: "price" },
        { text: "Paid Out", value: "paidOut" },
        { text: "Slot ID", value: "slotID" },
        { text: "Status", value: "slotStatus" },
        { text: "Actions", value: "actions", sortable: false },
      ],
    };
  },
  computed: {
    ...mapGetters("drizzle", ["drizzleInstance", "isDrizzleInitialized"]),
    ...mapGetters("contracts", ["getContractData"]),
  },
  async created() {
    await this.getSlots();
  },

  watch: {
    async dropIndex() {
      await this.getSlots();
    },
  },

  methods: {
    getColor(calories) {
      console.log(this.dropSlots[0].title);
      if (calories > 400) return "red";
      else if (calories > 200) return "orange";
      else return "green";
    },
    slotStatusStr(status) {
      // console.log({ status });
      switch (status) {
        case "0":
          return "Pending...";
        case "1":
          return "Success!";
        case "2":
          return "Failed";
      }
    },
    paidOutIcon(paidOut) {
      if (paidOut) return "mdi-check";
      else return "mdi-close";
    },
    async markSuccessful(slot) {
      await this.drizzleInstance.contracts.ATC.methods
        .markSuccessful(slot.slotID)
        .send({ from: this.account });
      await this.getSlots();
    },
    async markFailed(slot) {
      await this.drizzleInstance.contracts.ATC.methods
        .markFailed(slot.slotID)
        .send({ from: this.account });

      await this.getSlots();
    },

    async makeAirnodeRequest(slot) {
      console.log(slot);
      // console.log(this.account);
      // const providerID =
      //   "0xa174f6c8e7b73708b667a335527960112ebaad179e7ba519f4fde60ba1269c39";
      // const endpointID =
      //   "0xf466b8feec41e9e50815e0c9dca4db1ff959637e564bb13fefa99e9f9f90453c";

      // const requesterIndex = "46";

      const encodedData =
        "0x31620000000000000000000000000000000000000000000000000000000000006f726465724944000000000000000000000000000000000000000000000000003432303639000000000000000000000000000000000000000000000000000000";

      // const designatedWaller = "0xF353A7BAc05A01902c6d3f7CA62493BF6ce5DcB4";
      // this.loading = true;
      const requestResults = await this.drizzleInstance.contracts.ATC.methods
        .makeRequest(
          "0x8d8e9e7ccb12dffd15ca5ac34310e9ad8fa66ce0cbffbac68ba4d25a96d690b6",
          "0xf466b8feec41e9e50815e0c9dca4db1ff959637e564bb13fefa99e9f9f90453c",
          "60",
          "0x9aeEAeEB5C8242Ed856104eb5A22ACE17Fb01E7b",
          // airnodeAbi.encode([
          //   { name: "orderID", type: "bytes32", value: slotID },
          // ]),
          encodedData,
          slot.slotID
        )
        .send({ from: this.account });
      console.log({ requestResults });
      this.loading = false;
    },

    async getSlots() {
      this.slots = [];
      for (let slotID of this.dropSlots) {
        const slotData = await this.drizzleInstance.contracts.ATC.methods
          .slots(slotID)
          .call();
        // console.log({ slotData });
        this.slots.push(slotData);
      }
    },
  },
};
</script>
