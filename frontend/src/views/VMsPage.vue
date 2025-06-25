<template>
  <div class="container py-4">
    <h2>Virtual Machines</h2>
    <table class="table" v-if="loaded">
      <thead><tr><th>Name</th><th>CPU</th><th>Memory</th><th>Power</th></tr></thead>
      <tbody><tr v-for="vm in vms" :key="vm.name"><td>{{vm.name}}</td><td>{{vm.cpu}}</td><td>{{vm.memory}}</td><td>{{vm.power_state}}</td></tr></tbody>
    </table>
    <div v-else class="text-center mt-5"><span class="spinner-border" /></div>
  </div>
</template>
<script setup>
import { ref,onMounted } from 'vue';
import axios from 'axios';
const vms = ref([]);const loaded = ref(false);
onMounted(async()=>{const res = await axios.get('/vms');vms.value=res.data;loaded.value=true;});
</script>
