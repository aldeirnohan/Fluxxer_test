<template>
    <div class="task-list">
      <h2>Gerenciador de Tasks</h2>
      
      <!-- Formulário para criar nova task -->
      <div class="task-form">
        <h3>Criar Nova Task</h3>
        <form @submit.prevent="createTask" class="form">
          <div class="form-group">
            <label for="taskTitle">Título da Task:</label>
            <input 
              id="taskTitle"
              v-model="newTaskTitle" 
              type="text" 
              placeholder="Digite o título da task"
              required
              class="form-input"
            />
          </div>
          <button type="submit" class="btn-create" :disabled="creating">
            {{ creating ? 'Criando...' : 'Criar Task' }}
          </button>
        </form>
      </div>
  
      <!-- Lista de Tasks -->
      <div class="tasks-section">
        <h3>Lista de Tasks</h3>
        
        <!-- Auto-refresh indicator -->
        <div class="auto-refresh-info">
          <span class="refresh-indicator">
            🔄 Atualização automática a cada 5 segundos
          </span>
          <button @click="toggleAutoRefresh" class="btn-toggle-refresh">
            {{ autoRefreshEnabled ? '⏸️ Pausar' : '▶️ Retomar' }}
          </button>
        </div>
        
        <!-- Loading state -->
        <div v-if="loading" class="loading">
          <p>Carregando tasks...</p>
        </div>
        
        <!-- Error state -->
        <div v-else-if="error" class="error">
          <p>Erro ao carregar tasks: {{ error }}</p>
          <button @click="fetchTasks" class="btn-retry">Tentar novamente</button>
        </div>
        
        <!-- Tasks list -->
        <div v-else class="tasks-container">
          <!-- Empty state -->
          <div v-if="tasks.length === 0" class="empty-state">
            <p>Nenhuma task encontrada.</p>
          </div>
          
          <!-- Tasks -->
          <div v-else class="tasks">
            <div 
              v-for="task in tasks" 
              :key="task.id" 
              class="task-item"
              :class="getStatusClass(task.status)"
            >
              <div class="task-header">
                <h4 class="task-title">{{ task.title }}</h4>
                <span class="task-status" :class="getStatusClass(task.status)">
                  {{ getStatusLabel(task.status) }}
                </span>
              </div>
              
              <div class="task-details">
                <p class="task-date">
                  Criada em: {{ formatDate(task.created_at) }}
                </p>
                <p class="task-date" v-if="task.updated_at !== task.created_at">
                  Atualizada em: {{ formatDate(task.updated_at) }}
                </p>
              </div>
            </div>
          </div>
          
          <!-- Manual refresh button -->
          <button @click="fetchTasks" class="btn-refresh">
            🔄 Atualizar Agora
          </button>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  import { ref, onMounted, onUnmounted } from 'vue'
  import axios from 'axios'
  
  export default {
    name: 'TaskList',
    setup() {
      const tasks = ref([])
      const loading = ref(true)
      const error = ref(null)
      const creating = ref(false)
      const newTaskTitle = ref('')
      const autoRefreshEnabled = ref(true)
      const autoRefreshInterval = ref(null)
  
      // API base URL
      const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'
  
      // Fetch tasks from API
      const fetchTasks = async () => {
        try {
          loading.value = true
          error.value = null
          
          const response = await axios.get(`${API_BASE_URL}/api/tasks`)
          
          if (response.data.success) {
            tasks.value = response.data.data
          } else {
            error.value = response.data.message || 'Erro ao carregar tasks'
          }
        } catch (err) {
          console.error('Erro ao buscar tasks:', err)
          error.value = err.response?.data?.message || 'Erro de conexão com a API'
        } finally {
          loading.value = false
        }
      }
  
      // Create new task
      const createTask = async () => {
        if (!newTaskTitle.value.trim()) return
  
        try {
          creating.value = true
          
          const response = await axios.post(`${API_BASE_URL}/api/tasks`, {
            title: newTaskTitle.value.trim()
          })
          
          if (response.data.success) {
            // Limpar formulário
            newTaskTitle.value = ''
            
            // Atualizar lista imediatamente
            await fetchTasks()
            
            // Mostrar mensagem de sucesso (opcional)
            console.log('Task criada com sucesso!')
          } else {
            error.value = response.data.message || 'Erro ao criar task'
          }
        } catch (err) {
          console.error('Erro ao criar task:', err)
          error.value = err.response?.data?.message || 'Erro de conexão com a API'
        } finally {
          creating.value = false
        }
      }
  
      // Toggle auto-refresh
      const toggleAutoRefresh = () => {
        if (autoRefreshEnabled.value) {
          stopAutoRefresh()
        } else {
          startAutoRefresh()
        }
      }
  
      // Start auto-refresh
      const startAutoRefresh = () => {
        if (autoRefreshInterval.value) return
        
        autoRefreshEnabled.value = true
        autoRefreshInterval.value = setInterval(() => {
          if (!loading.value) {
            fetchTasks()
          }
        }, 5000) // 5 segundos
        
        console.log('Auto-refresh iniciado')
      }
  
      // Stop auto-refresh
      const stopAutoRefresh = () => {
        if (autoRefreshInterval.value) {
          clearInterval(autoRefreshInterval.value)
          autoRefreshInterval.value = null
        }
        
        autoRefreshEnabled.value = false
        console.log('Auto-refresh pausado')
      }
  
      // Get status class for styling
      const getStatusClass = (status) => {
        switch (status) {
          case 'pending':
            return 'status-pending'
          case 'processing':
            return 'status-processing'
          case 'done':
            return 'status-done'
          default:
            return 'status-unknown'
        }
      }
  
      // Get status label in Portuguese
      const getStatusLabel = (status) => {
        switch (status) {
          case 'pending':
            return 'Pendente'
          case 'processing':
            return 'Processando'
          case 'done':
            return 'Concluída'
          default:
            return 'Desconhecido'
        }
      }
  
      // Format date
      const formatDate = (dateString) => {
        if (!dateString) return ''
        
        const date = new Date(dateString)
        return date.toLocaleString('pt-BR', {
          day: '2-digit',
          month: '2-digit',
          year: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        })
      }
  
      // Fetch tasks on component mount
      onMounted(() => {
        fetchTasks()
        startAutoRefresh()
      })
  
      // Cleanup on component unmount
      onUnmounted(() => {
        stopAutoRefresh()
      })
  
      return {
        tasks,
        loading,
        error,
        creating,
        newTaskTitle,
        autoRefreshEnabled,
        fetchTasks,
        createTask,
        toggleAutoRefresh,
        getStatusClass,
        getStatusLabel,
        formatDate
      }
    }
  }
  </script>
  
  <style scoped>
  .task-list {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
  }
  
  h2 {
    text-align: center;
    color: #333;
    margin-bottom: 30px;
  }
  
  h3 {
    color: #555;
    margin-bottom: 20px;
    border-bottom: 2px solid #e0e0e0;
    padding-bottom: 10px;
  }
  
  /* Auto-refresh info */
  .auto-refresh-info {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background-color: #f8f9fa;
    padding: 15px;
    border-radius: 6px;
    margin-bottom: 20px;
    border: 1px solid #e9ecef;
  }
  
  .refresh-indicator {
    color: #6c757d;
    font-size: 14px;
    font-weight: 500;
  }
  
  .btn-toggle-refresh {
    background-color: #6c757d;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    transition: background-color 0.3s ease;
  }
  
  .btn-toggle-refresh:hover {
    background-color: #5a6268;
  }
  
  /* Formulário */
  .task-form {
    background: white;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    padding: 25px;
    margin-bottom: 30px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }
  
  .form {
    display: flex;
    gap: 15px;
    align-items: end;
  }
  
  .form-group {
    flex: 1;
  }
  
  .form-group label {
    display: block;
    margin-bottom: 8px;
    color: #555;
    font-weight: 500;
  }
  
  .form-input {
    width: 100%;
    padding: 12px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 16px;
    transition: border-color 0.3s ease;
  }
  
  .form-input:focus {
    outline: none;
    border-color: #1976d2;
    box-shadow: 0 0 0 2px rgba(25, 118, 210, 0.2);
  }
  
  .btn-create {
    background-color: #4caf50;
    color: white;
    border: none;
    padding: 12px 24px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 16px;
    font-weight: 500;
    transition: background-color 0.3s ease;
  }
  
  .btn-create:hover:not(:disabled) {
    background-color: #45a049;
  }
  
  .btn-create:disabled {
    background-color: #ccc;
    cursor: not-allowed;
  }
  
  /* Tasks Section */
  .tasks-section {
    background: white;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    padding: 25px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }
  
  .loading, .error, .empty-state {
    text-align: center;
    padding: 40px;
    color: #666;
  }
  
  .error {
    color: #d32f2f;
  }
  
  .btn-retry, .btn-refresh {
    background-color: #1976d2;
    color: white;
    border: none;
    padding: 10px 20px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    margin-top: 10px;
    transition: background-color 0.3s ease;
  }
  
  .btn-retry:hover, .btn-refresh:hover {
    background-color: #1565c0;
  }
  
  .tasks-container {
    margin-top: 20px;
  }
  
  .task-item {
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 15px;
    transition: all 0.3s ease;
  }
  
  .task-item:hover {
    box-shadow: 0 4px 8px rgba(0,0,0,0.15);
    transform: translateY(-2px);
  }
  
  .task-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
  }
  
  .task-title {
    margin: 0;
    color: #333;
    font-size: 18px;
    font-weight: 500;
  }
  
  .task-status {
    padding: 6px 16px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: bold;
    text-transform: uppercase;
  }
  
  .status-pending {
    background-color: #fff3e0;
    color: #f57c00;
  }
  
  .status-processing {
    background-color: #e3f2fd;
    color: #1976d2;
  }
  
  .status-done {
    background-color: #e8f5e8;
    color: #388e3c;
  }
  
  .status-unknown {
    background-color: #f5f5f5;
    color: #666;
  }
  
  .task-details {
    color: #666;
    font-size: 14px;
  }
  
  .task-date {
    margin: 5px 0;
  }
  
  .btn-refresh {
    display: block;
    margin: 30px auto 0;
  }
  
  /* Responsivo */
  @media (max-width: 768px) {
    .form {
      flex-direction: column;
      align-items: stretch;
    }
    
    .btn-create {
      width: 100%;
    }
    
    .task-header {
      flex-direction: column;
      align-items: flex-start;
      gap: 10px;
    }
    
    .auto-refresh-info {
      flex-direction: column;
      gap: 10px;
      text-align: center;
    }
  }
  </style>