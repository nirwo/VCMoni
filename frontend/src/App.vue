<template>
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
    <div class="container-fluid">
      <a class="navbar-brand" href="#">VCMoni</a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="nav">
        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
          <li class="nav-item"><router-link class="nav-link" to="/overview">Overview</router-link></li>
          <li class="nav-item"><router-link class="nav-link" to="/clusters">Clusters</router-link></li>
          <li class="nav-item"><router-link class="nav-link" to="/hosts">Hosts</router-link></li>
          <li class="nav-item"><router-link class="nav-link" to="/vms">VMs</router-link></li>
          <li class="nav-item"><router-link class="nav-link" to="/datastores">Datastores</router-link></li>
          <li class="nav-item"><router-link class="nav-link" to="/networks">Networks</router-link></li>
          <li class="nav-item"><router-link class="nav-link" to="/capacity">Capacity</router-link></li>
        </ul>
      </div>
    </div>
  </nav>
  <router-view />
</template>

