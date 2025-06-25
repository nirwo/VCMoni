<template>
  <div class="container py-5" style="max-width:400px;">
    <div class="card">
      <div class="card-body">
        <h3 class="card-title mb-3">Login to vCenter</h3>
        <div class="mb-2"><input v-model="server" placeholder="Server" class="form-control" /></div>
        <div class="mb-2"><input v-model="username" placeholder="Username" class="form-control" /></div>
        <div class="mb-2"><input v-model="password" type="password" placeholder="Password" class="form-control" /></div>
        <button class="btn btn-primary w-100" @click="login">Login</button>
        <div class="text-danger mt-2">{{ message }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';

const router = useRouter();
const server = ref('');
const username = ref('');
const password = ref('');
const message = ref('');

const login = async () => {
  try {
    await axios.post('/login', { server: server.value, username: username.value, password: password.value });
    router.push('/overview');
  } catch (e) {
    message.value = e.response?.data?.detail || e.message;
  }
};
</script>
