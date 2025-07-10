import { createContext, useContext, useState, useEffect } from 'react';
import api from '../services/api';

const AuthContext = createContext({});

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Check if user is logged in on mount
  useEffect(() => {
    checkAuth();
  }, []);

  const checkAuth = async () => {
    const token = localStorage.getItem('authToken');
    if (!token) {
      setLoading(false);
      return;
    }

    try {
      api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      const response = await api.get('/user/current');
      setUser(response.data);
    } catch (err) {
      console.error('Auth check failed:', err);
      localStorage.removeItem('authToken');
      delete api.defaults.headers.common['Authorization'];
    } finally {
      setLoading(false);
    }
  };

  const login = async (email, password) => {
    try {
      setError(null);
      const response = await api.post('/users/sign_in', {
        user: { email, password }
      });

      // Check both lowercase and uppercase for the authorization header
      const authHeader = response.headers['authorization'] || response.headers['Authorization'];
      const token = authHeader?.split(' ')[1];
      
      if (token) {
        localStorage.setItem('authToken', token);
        api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      }

      setUser(response.data.data);
      return { success: true };
    } catch (err) {
      const message = err.response?.data?.status?.message || err.response?.data?.error || 'Login failed';
      setError(message);
      return { success: false, error: message };
    }
  };

  const register = async (email, password, passwordConfirmation) => {
    try {
      setError(null);
      const response = await api.post('/users', {
        user: { 
          email, 
          password,
          password_confirmation: passwordConfirmation 
        }
      });

      // Check both lowercase and uppercase for the authorization header
      const authHeader = response.headers['authorization'] || response.headers['Authorization'];
      const token = authHeader?.split(' ')[1];
      
      if (token) {
        localStorage.setItem('authToken', token);
        api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      }

      setUser(response.data.data);
      return { success: true };
    } catch (err) {
      const message = err.response?.data?.status?.message || 'Registration failed';
      setError(message);
      return { success: false, error: message };
    }
  };

  const logout = async () => {
    try {
      await api.delete('/users/sign_out');
    } catch (err) {
      console.error('Logout error:', err);
    } finally {
      localStorage.removeItem('authToken');
      delete api.defaults.headers.common['Authorization'];
      setUser(null);
    }
  };

  const updateApiKeys = async (anthropicApiKey, openaiApiKey) => {
    try {
      const response = await api.patch('/user/update_api_keys', {
        user: {
          anthropic_api_key: anthropicApiKey,
          openai_api_key: openaiApiKey
        }
      });
      
      // Refresh user data
      await checkAuth();
      
      return { success: true };
    } catch (err) {
      const message = err.response?.data?.errors?.join(', ') || 'Failed to update API keys';
      return { success: false, error: message };
    }
  };

  const value = {
    user,
    loading,
    error,
    login,
    register,
    logout,
    updateApiKeys,
    checkAuth
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};