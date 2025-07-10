import api from './api';

const progressService = {
  // Get progress entries with optional date range
  getProgressEntries: async (startDate, endDate) => {
    const params = {};
    if (startDate) params.start_date = startDate;
    if (endDate) params.end_date = endDate;
    
    const response = await api.get('/progress_entries', { params });
    return response.data;
  },

  // Create or update progress entry for a date
  createProgressEntry: async (entryData) => {
    const response = await api.post('/progress_entries', { 
      progress_entry: entryData 
    });
    return response.data;
  },

  // Update an existing progress entry
  updateProgressEntry: async (id, entryData) => {
    const response = await api.put(`/progress_entries/${id}`, { 
      progress_entry: entryData 
    });
    return response.data;
  },
};

export default progressService;