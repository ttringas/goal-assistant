import { Link, useLocation } from 'react-router-dom';

function Navigation() {
  const location = useLocation();
  
  const isActive = (path) => {
    return location.pathname.startsWith(path);
  };

  return (
    <nav className="navigation">
      <div className="nav-container">
        <Link to="/" className="nav-brand">
          Goal Tracker
        </Link>
        
        <div className="nav-links">
          <Link 
            to="/goals" 
            className={`nav-link ${isActive('/goals') ? 'active' : ''}`}
          >
            Goals
          </Link>
          {/* We'll add more links in future phases */}
        </div>
      </div>
    </nav>
  );
}

export default Navigation;