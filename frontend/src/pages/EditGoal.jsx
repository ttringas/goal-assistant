import { useParams, useNavigate } from 'react-router-dom';
import { useGoal, useUpdateGoal } from '../hooks/useGoals';
import GoalForm from '../components/goals/GoalForm';
import LoadingSpinner from '../components/shared/LoadingSpinner';

function EditGoal() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { data: goal, isLoading } = useGoal(id);
  const updateGoal = useUpdateGoal();

  const handleSubmit = async (formData) => {
    try {
      await updateGoal.mutateAsync({ id, data: formData });
      navigate(`/goals/${id}`);
    } catch (error) {
      // Error is handled by the mutation hook
    }
  };

  if (isLoading) {
    return (
      <div className="page-container">
        <LoadingSpinner size="large" />
      </div>
    );
  }

  if (!goal) {
    return (
      <div className="page-container">
        <div className="error-message">Goal not found</div>
      </div>
    );
  }

  return (
    <div className="page-container">
      <div className="page-header">
        <h1>Edit Goal</h1>
      </div>
      
      <div className="form-container">
        <GoalForm
          goal={goal}
          onSubmit={handleSubmit}
          isLoading={updateGoal.isLoading}
        />
      </div>
    </div>
  );
}

export default EditGoal;