import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { Toaster } from 'react-hot-toast';

import { AuthProvider } from './contexts/AuthContext';
import ProtectedRoute from './components/auth/ProtectedRoute';
import Layout from './components/layout/Layout';
import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';
import Goals from './pages/Goals';
import GoalDetails from './pages/GoalDetails';
import NewGoal from './pages/NewGoal';
import EditGoal from './pages/EditGoal';
import CheckIn from './pages/CheckIn';
import Timeline from './pages/Timeline';
import Profile from './pages/Profile';
import NotFound from './pages/NotFound';

import './App.css';

// Create a client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      refetchOnWindowFocus: false,
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <Router>
          <Toaster 
            position="top-right"
            toastOptions={{
              duration: 4000,
              style: {
                background: '#363636',
                color: '#fff',
              },
              success: {
                style: {
                  background: '#4ade80',
                  color: '#000',
                },
              },
              error: {
                style: {
                  background: '#ef4444',
                  color: '#fff',
                },
              },
            }}
          />
          <Routes>
            {/* Public routes */}
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            
            {/* Protected routes */}
            <Route path="/" element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }>
              <Route index element={<Navigate to="/dashboard" replace />} />
              <Route path="dashboard" element={<Dashboard />} />
              <Route path="goals" element={<Goals />} />
              <Route path="goals/new" element={<NewGoal />} />
              <Route path="goals/:id" element={<GoalDetails />} />
              <Route path="goals/:id/edit" element={<EditGoal />} />
              <Route path="checkin" element={<CheckIn />} />
              <Route path="timeline" element={<Timeline />} />
              <Route path="profile" element={<Profile />} />
              <Route path="*" element={<NotFound />} />
            </Route>
          </Routes>
        </Router>
        <ReactQueryDevtools initialIsOpen={false} />
      </AuthProvider>
    </QueryClientProvider>
  );
}

export default App;