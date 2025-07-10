import { Link, useLocation } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { User, LogOut } from 'lucide-react';

function Navigation() {
  const location = useLocation();
  const { user, logout } = useAuth();
  
  const isActive = (path) => {
    return location.pathname.startsWith(path);
  };

  const handleLogout = async () => {
    await logout();
  };

  return (
    <nav className="navigation">
      <div className="nav-container">
        <Link to="/" className="nav-brand">
          Goal Tracker
        </Link>
        
        <div className="nav-links">
          <Link 
            to="/dashboard" 
            className={`nav-link ${isActive('/dashboard') ? 'active' : ''}`}
          >
            Dashboard
          </Link>
          <Link 
            to="/goals" 
            className={`nav-link ${isActive('/goals') ? 'active' : ''}`}
          >
            Goals
          </Link>
          <Link 
            to="/checkin" 
            className={`nav-link ${isActive('/checkin') ? 'active' : ''}`}
          >
            Check-in
          </Link>
          <Link 
            to="/timeline" 
            className={`nav-link ${isActive('/timeline') ? 'active' : ''}`}
          >
            Timeline
          </Link>
          
          <div className="nav-spacer" />
          
          {user && (
            <>
              <Link 
                to="/profile" 
                className={`nav-link ${isActive('/profile') ? 'active' : ''}`}
                title={user.email}
              >
                <User className="w-4 h-4" />
              </Link>
              <button
                onClick={handleLogout}
                className="nav-link"
                title="Logout"
              >
                <LogOut className="w-4 h-4" />
              </button>
            </>
          )}
        </div>
      </div>
    </nav>
  );
}

export default Navigation;