import { createApp, ref } from 'https://unpkg.com/vue@3/dist/vue.esm-browser.js';

const App = {
  setup() {
    const loggedIn = ref(false);
    const message = ref('');
    const server = ref('');
    const username = ref('');
    const password = ref('');

    const login = async () => {
      try {
        const res = await fetch('/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ server: server.value, username: username.value, password: password.value }),
        });
        if (!res.ok) throw new Error('Login failed');
        loggedIn.value = true;
        loadOverview();
      } catch (e) {
        message.value = e.message;
      }
    };

    const overview = ref({});
    const loadOverview = async () => {
      const res = await fetch('/overview');
      overview.value = await res.json();
    };

    return { loggedIn, message, server, username, password, login, overview };
  },
  template: `
    <div>
      <div v-if="!loggedIn" class="card mx-auto" style="max-width:400px;">
        <div class="card-body">
          <h5 class="card-title">Login to vCenter</h5>
          <div class="mb-3"><input v-model="server" placeholder="Server" class="form-control"/></div>
          <div class="mb-3"><input v-model="username" placeholder="Username" class="form-control"/></div>
          <div class="mb-3"><input v-model="password" type="password" placeholder="Password" class="form-control"/></div>
          <button class="btn btn-primary w-100" @click="login">Login</button>
          <div class="text-danger mt-2">{{message}}</div>
        </div>
      </div>

      <div v-else>
        <h2>Overview</h2>
        <pre>{{overview}}</pre>
      </div>
    </div>`,
};

createApp(App).mount('#app');
