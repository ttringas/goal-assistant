import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../services/api';
import { useDebounce } from '../hooks/useDebounce';

function CheckIn() {
  const [content, setContent] = useState('');
  const [saveStatus, setSaveStatus] = useState('idle'); // 'idle', 'saving', 'saved', 'error'
  const queryClient = useQueryClient();
  const debouncedContent = useDebounce(content, 1500);

  // Get today's progress entry
  const { data: todayEntry } = useQuery({
    queryKey: ['progressEntry', 'today'],
    queryFn: async () => {
      const response = await api.get('/progress_entries/today');
      return response.data;
    }
  });

  // Get today's AI insight
  const { data: todayInsight } = useQuery({
    queryKey: ['aiSummary', 'today'],
    queryFn: async () => {
      try {
        const response = await api.get('/ai_summaries/today');
        return response.data;
      } catch (error) {
        if (error.response?.status === 404) {
          return null;
        }
        throw error;
      }
    }
  });

  // Set initial content when data loads
  useEffect(() => {
    if (todayEntry?.content) {
      setContent(todayEntry.content);
    }
  }, [todayEntry]);

  const saveEntry = useMutation({
    mutationFn: async (data) => {
      return api.post('/progress_entries', {
        progress_entry: data
      });
    },
    onSuccess: () => {
      queryClient.invalidateQueries(['progressEntry', 'today']);
      setSaveStatus('saved');
      setTimeout(() => setSaveStatus('idle'), 2000);
    },
    onError: () => {
      setSaveStatus('error');
      setTimeout(() => setSaveStatus('idle'), 3000);
    }
  });

  // Auto-save effect
  useEffect(() => {
    if (debouncedContent && debouncedContent !== todayEntry?.content) {
      setSaveStatus('saving');
      saveEntry.mutate({
        content: debouncedContent,
        entry_date: new Date().toISOString().split('T')[0]
      });
    }
  }, [debouncedContent]);

  const today = new Date().toLocaleDateString('en-US', { 
    weekday: 'long', 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  });

  const renderSaveStatus = () => {
    switch (saveStatus) {
      case 'saving':
        return (
          <span className="text-sm text-gray-500 flex items-center gap-1">
            <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
            </svg>
            Saving...
          </span>
        );
      case 'saved':
        return (
          <span className="text-sm text-green-600 flex items-center gap-1">
            <svg className="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
            </svg>
            Saved
          </span>
        );
      case 'error':
        return (
          <span className="text-sm text-red-600 flex items-center gap-1">
            <svg className="h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
            </svg>
            Failed to save
          </span>
        );
      default:
        return null;
    }
  };

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <h1 className="text-2xl font-light mb-8 text-gray-800">Daily Check-in</h1>
      
      <div className="mb-8">
        <p className="text-sm text-gray-500 mb-4">{today}</p>
        
        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-medium text-gray-800">How did today go?</h2>
            {renderSaveStatus()}
          </div>
          
          <textarea
            value={content}
            onChange={(e) => setContent(e.target.value)}
            placeholder="Share your progress, challenges, and wins from today..."
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-1 focus:ring-blue-400 min-h-[150px] resize-none"
          />
        </div>
      </div>

      {todayInsight && (
        <div className="bg-blue-50 rounded-lg border border-blue-100 p-6">
          <h2 className="text-lg font-medium mb-3 text-gray-800">Today's Insight</h2>
          <p className="text-gray-700">{todayInsight.content}</p>
        </div>
      )}
    </div>
  );
}

export default CheckIn;