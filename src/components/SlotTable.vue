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

    async getSlots() {
      this.slots = [];
      for (let slotID of this.dropSlots) {
        const slotData = await this.drizzleInstance.contracts.ATC.methods
          .slots(slotID)
          .call();
        console.log({ slotData });
        this.slots.push(slotData);
      }
    },
  },
};
</script>
