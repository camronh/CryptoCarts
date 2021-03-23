<template>
  <v-card>
    {{ drop }}
    {{ dropSlots }}
  </v-card>
</template>

<script>
export default {
  props: ["drop", "dropSlots"],
  watch: {
    drop() {
      console.log(this.drop);
    },
  },
};
</script>
