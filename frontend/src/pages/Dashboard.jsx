import { Navigate } from 'react-router-dom';

function Dashboard() {
  // For now, redirect to goals page
  // We'll expand this in future phases
  return <Navigate to="/goals" replace />;
}

export default Dashboard;