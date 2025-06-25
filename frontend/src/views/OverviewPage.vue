<template>
  <div class="container py-4">
    <h2>vCenter Overview</h2>
    <div class="row mt-4" v-if="loaded">
      <div class="col-md-3" v-for="(val,key) in overview" :key="key">
        <div class="card text-center">
          <div class="card-body">
            <h5 class="card-title text-uppercase">{{ key }}</h5>
            <p class="display-6">{{ val }}</p>
          </div>
        </div>
      </div>
    </div>
    <div v-else class="text-center mt-5"><span class="spinner-border" /></div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';

const overview = ref({});
const loaded = ref(false);

onMounted(async () => {
  const res = await axios.get('/overview');
  overview.value = res.data;
  loaded.value = true;
});
</script>
