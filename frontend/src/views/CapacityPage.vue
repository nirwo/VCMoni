<template>
  <div class="container py-4">
    <h2>Capacity Calculator</h2>
    <div class="input-group mb-3" v-for="r in resources" :key="r.key">
      <span class="input-group-text text-uppercase">{{r.key}}</span>
      <input type="number" class="form-control" v-model.number="r.used" placeholder="Used %" />
    </div>
    <button class="btn btn-primary" @click="calc">Calculate</button>
    <div class="mt-4" v-if="Object.keys(result).length">
      <h5>Remaining Capacity (to 85%)</h5>
      <ul><li v-for="(v,k) in result" :key="k">{{k}} : {{v}} %</li></ul>
    </div>
  </div>
</template>
<script setup>
import { reactive, ref } from 'vue';
import axios from 'axios';
const resources = reactive([{key:'cpu_pct',used:0},{key:'mem_pct',used:0},{key:'storage_pct',used:0}]);
const result = ref({});
const calc = async()=>{const payload={};resources.forEach(r=>payload[r.key]=r.used);const res=await axios.post('/capacity',payload);result.value=res.data;};
</script>
