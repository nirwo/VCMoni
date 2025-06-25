<template>
  <div class="container py-4">
    <h2>Hosts</h2>
    <table class="table mt-3" v-if="loaded">
      <thead><tr><th>Name</th><th>CPU</th><th>Memory</th><th>Status</th></tr></thead>
      <tbody><tr v-for="h in hosts" :key="h.name"><td>{{h.name}}</td><td>{{h.cpu}}</td><td>{{h.memory}}</td><td>{{h.status}}</td></tr></tbody>
    </table>
    <div v-else class="text-center mt-5"><span class="spinner-border" /></div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
const hosts = ref([]);
const loaded = ref(false);
onMounted(async ()=>{ const res = await axios.get('/hosts'); hosts.value = res.data; loaded.value=true;});
</script>
