import { Link } from 'react-router-dom';
import Button from '../components/shared/Button';

function NotFound() {
  return (
    <div className="page-container">
      <div className="not-found">
        <h1>404</h1>
        <h2>Page Not Found</h2>
        <p>The page you're looking for doesn't exist.</p>
        <Link to="/">
          <Button variant="primary">Go to Home</Button>
        </Link>
      </div>
    </div>
  );
}

export default NotFound;