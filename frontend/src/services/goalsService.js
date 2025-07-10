import api from './api';

const goalsService = {
  // Get all goals with optional filters
  getGoals: async (filters = {}) => {
    const params = new URLSearchParams();
    Object.keys(filters).forEach(key => {
      if (filters[key] !== undefined) {
        params.append(key, filters[key]);
      }
    });
    
    const response = await api.get('/goals', { params });
    return response.data;
  },

  // Get a single goal
  getGoal: async (id) => {
    const response = await api.get(`/goals/${id}`);
    return response.data;
  },

  // Create a new goal
  createGoal: async (goalData) => {
    const response = await api.post('/goals', { goal: goalData });
    return response.data;
  },

  // Update a goal
  updateGoal: async (id, goalData) => {
    const response = await api.put(`/goals/${id}`, { goal: goalData });
    return response.data;
  },

  // Delete a goal
  deleteGoal: async (id) => {
    await api.delete(`/goals/${id}`);
  },

  // Mark goal as complete
  completeGoal: async (id) => {
    const response = await api.patch(`/goals/${id}/complete`);
    return response.data;
  },

  // Archive a goal
  archiveGoal: async (id) => {
    const response = await api.patch(`/goals/${id}/archive`);
    return response.data;
  },
};

export default goalsService;