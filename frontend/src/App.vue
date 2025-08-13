<template>
  <div id="app">
    <header class="app-header">
      <h1>Fluxxer - Gerenciador de Tasks</h1>
    </header>
    
    <main class="app-main">
      <TaskList />
    </main>
  </div>
</template>

<script>
import TaskList from './components/TaskList.vue'

export default {
  name: 'App',
  components: {
    TaskList
  }
}
</script>

<style>
#app {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.app-header {
  background-color: #1976d2;
  color: white;
  padding: 20px;
  text-align: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.app-header h1 {
  margin: 0;
  font-size: 28px;
  font-weight: 300;
}

.app-main {
  padding: 20px;
}
</style>