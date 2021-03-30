<template>
  <v-app>
    <v-app-bar app color="primary" dark>
      CRYPTO CARTS
    </v-app-bar>

    <v-main>
      <ATCForm />
    </v-main>
  </v-app>
</template>

<script>
import ATCForm from "./components/ATCForm";
// import web3 from "../contracts/web3";

export default {
  name: "App",

  components: {
    ATCForm,
  },

  data: () => ({
    //
  }),
  created() {
    // console.log("In!", web3);
  },
};
</script>
