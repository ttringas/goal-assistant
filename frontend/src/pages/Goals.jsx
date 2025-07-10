import { useState } from 'react';
import { useGoals, useCreateGoal } from '../hooks/useGoals';
import GoalList from '../components/goals/GoalList';
import GoalForm from '../components/goals/GoalForm';
import Button from '../components/shared/Button';
import LoadingSpinner from '../components/shared/LoadingSpinner';
import Modal from '../components/shared/Modal';

function Goals() {
  const [filter, setFilter] = useState('active');
  const [showNewGoalModal, setShowNewGoalModal] = useState(false);
  const createGoal = useCreateGoal();
  
  const filters = {
    all: {},
    active: { active: true },
    completed: { completed: true },
    archived: { archived: true },
  };

  const { data: goals, isLoading, error } = useGoals(filters[filter]);

  const handleCreateGoal = (goalData) => {
    createGoal.mutate(goalData, {
      onSuccess: () => {
        setShowNewGoalModal(false);
      },
    });
  };

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
        <Button variant="primary" onClick={() => setShowNewGoalModal(true)}>
          Add New Goal
        </Button>
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

      <Modal
        isOpen={showNewGoalModal}
        onClose={() => setShowNewGoalModal(false)}
        title="Create New Goal"
      >
        <GoalForm
          onSubmit={handleCreateGoal}
          onCancel={() => setShowNewGoalModal(false)}
          isLoading={createGoal.isLoading}
        />
      </Modal>
    </div>
  );
}

export default Goals;