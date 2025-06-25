<template>
  <div class="container py-4">
    <h2>Datastores</h2>
    <table class="table" v-if="loaded">
      <thead><tr><th>Name</th><th>Capacity GB</th><th>Free GB</th><th>Type</th></tr></thead>
      <tbody><tr v-for="ds in datastores" :key="ds.name"><td>{{ds.name}}</td><td>{{ds.capacity_gb}}</td><td>{{ds.free_gb}}</td><td>{{ds.type}}</td></tr></tbody>
    </table>
    <div v-else class="text-center mt-5"><span class="spinner-border" /></div>
  </div>
</template>
<script setup>
import { ref,onMounted } from 'vue';
import axios from 'axios';
const datastores = ref([]);const loaded = ref(false);
onMounted(async()=>{const res = await axios.get('/datastores');datastores.value=res.data;loaded.value=true;});
</script>
