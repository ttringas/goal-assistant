import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useGoals } from '../hooks/useGoals';
import GoalList from '../components/goals/GoalList';
import Button from '../components/shared/Button';
import LoadingSpinner from '../components/shared/LoadingSpinner';

function Goals() {
  const [filter, setFilter] = useState('active');
  
  const filters = {
    all: {},
    active: { active: true },
    completed: { completed: true },
    archived: { archived: true },
  };

  const { data: goals, isLoading, error } = useGoals(filters[filter]);

  if (isLoading) {
    return (
      <div className="page-container">
        <LoadingSpinner size="large" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="page-container">
        <div className="error-message">
          Error loading goals: {error.message}
        </div>
      </div>
    );
  }

  return (
    <div className="page-container">
      <div className="page-header">
        <h1>My Goals</h1>
        <Link to="/goals/new">
          <Button variant="primary">Add New Goal</Button>
        </Link>
      </div>

      <div className="filter-tabs">
        {Object.keys(filters).map((key) => (
          <button
            key={key}
            className={`filter-tab ${filter === key ? 'active' : ''}`}
            onClick={() => setFilter(key)}
          >
            {key.charAt(0).toUpperCase() + key.slice(1)}
          </button>
        ))}
      </div>

      <GoalList goals={goals || []} />
    </div>
  );
}

export default Goals;