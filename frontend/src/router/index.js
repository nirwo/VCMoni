import { createRouter, createWebHistory } from 'vue-router';
import Login from '../views/LoginPage.vue';
import Overview from '../views/OverviewPage.vue';
import Clusters from '../views/ClustersPage.vue';
import Hosts from '../views/HostsPage.vue';
import VMs from '../views/VMsPage.vue';
import Datastores from '../views/DatastoresPage.vue';
import Networks from '../views/NetworksPage.vue';
import Capacity from '../views/CapacityPage.vue';

const routes = [
  { path: '/', name: 'login', component: Login },
  { path: '/overview', name: 'overview', component: Overview },
  { path: '/clusters', name: 'clusters', component: Clusters },
  { path: '/hosts', name: 'hosts', component: Hosts },
  { path: '/vms', name: 'vms', component: VMs },
  { path: '/datastores', name: 'datastores', component: Datastores },
  { path: '/networks', name: 'networks', component: Networks },
  { path: '/capacity', name: 'capacity', component: Capacity },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
