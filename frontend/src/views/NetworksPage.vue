<template>
  <div class="container py-4">
    <h2>Networks</h2>
    <table class="table" v-if="loaded">
      <thead><tr><th>Name</th><th>Type</th></tr></thead>
      <tbody><tr v-for="net in networks" :key="net.name"><td>{{net.name}}</td><td>{{net.type}}</td></tr></tbody>
    </table>
    <div v-else class="text-center mt-5"><span class="spinner-border" /></div>
  </div>
</template>
<script setup>
import { ref,onMounted } from 'vue';
import axios from 'axios';
const networks = ref([]);const loaded = ref(false);
onMounted(async()=>{const res = await axios.get('/networks');networks.value=res.data;loaded.value=true;});
</script>
