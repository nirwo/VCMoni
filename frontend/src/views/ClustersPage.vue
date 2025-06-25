<template>
  <div class="container py-4">
    <h2>Clusters Utilization</h2>
    <div v-if="!loaded" class="text-center mt-5"><span class="spinner-border" /></div>
    <div v-else class="row">
      <div class="col-md-6 mb-4" v-for="cluster in clusters" :key="cluster.name">
        <div class="card p-3">
          <h5>{{ cluster.name }}</h5>
          <canvas :id="'chart-'+cluster.name"></canvas>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue';
import axios from 'axios';
import { Chart, PieController, ArcElement, Tooltip, Legend } from 'chart.js';

Chart.register(PieController, ArcElement, Tooltip, Legend);

const clusters = ref([]);
const loaded = ref(false);

onMounted(async () => {
  const res = await axios.get('/clusters');
  clusters.value = res.data;
  await nextTick();
  clusters.value.forEach((c) => {
    const ctx = document.getElementById('chart-' + c.name);
    new Chart(ctx, {
      type: 'pie',
      data: {
        labels: ['CPU', 'Memory', 'Storage'],
        datasets: [
          {
            data: [c.cpu_pct, c.mem_pct, c.storage_pct],
            backgroundColor: ['#36a2eb', '#ff6384', '#ffcd56'],
          },
        ],
      },
    });
  });
  loaded.value = true;
});
</script>
