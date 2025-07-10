import { useNavigate } from 'react-router-dom';
import { useCreateGoal } from '../hooks/useGoals';
import GoalForm from '../components/goals/GoalForm';

function NewGoal() {
  const navigate = useNavigate();
  const createGoal = useCreateGoal();

  const handleSubmit = async (formData) => {
    try {
      await createGoal.mutateAsync(formData);
      navigate('/goals');
    } catch (error) {
      // Error is handled by the mutation hook
    }
  };

  return (
    <div className="page-container">
      <div className="page-header">
        <h1>Create New Goal</h1>
      </div>
      
      <div className="form-container">
        <GoalForm
          onSubmit={handleSubmit}
          isLoading={createGoal.isLoading}
        />
      </div>
    </div>
  );
}

export default NewGoal;