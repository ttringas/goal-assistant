import { useParams, Link, useNavigate } from 'react-router-dom';
import { useGoal, useCompleteGoal, useArchiveGoal, useDeleteGoal } from '../hooks/useGoals';
import { formatDate, isOverdue } from '../utils/dateHelpers';
import Button from '../components/shared/Button';
import Card from '../components/shared/Card';
import LoadingSpinner from '../components/shared/LoadingSpinner';

function GoalDetails() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { data: goal, isLoading } = useGoal(id);
  const completeGoal = useCompleteGoal();
  const archiveGoal = useArchiveGoal();
  const deleteGoal = useDeleteGoal();

  const handleComplete = async () => {
    if (window.confirm('Mark this goal as complete?')) {
      await completeGoal.mutateAsync(id);
    }
  };

  const handleArchive = async () => {
    if (window.confirm('Archive this goal?')) {
      await archiveGoal.mutateAsync(id);
    }
  };

  const handleDelete = async () => {
    if (window.confirm('Delete this goal? This action cannot be undone.')) {
      await deleteGoal.mutateAsync(id);
      navigate('/goals');
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

  const isGoalOverdue = !goal.completed_at && isOverdue(goal.target_date);

  return (
    <div className="page-container">
      <div className="page-header">
        <Link to="/goals" className="back-link">
          ← Back to Goals
        </Link>
      </div>

      <Card className="goal-details">
        <Card.Header>
          <div className="goal-details-header">
            <h1>{goal.title}</h1>
            {goal.goal_type && (
              <span className={`goal-type goal-type-${goal.goal_type}`}>
                {goal.goal_type}
              </span>
            )}
          </div>
        </Card.Header>

        <Card.Body>
          {goal.description && (
            <div className="goal-section">
              <h3>Description</h3>
              <p>{goal.description}</p>
            </div>
          )}

          <div className="goal-info">
            <div className="info-item">
              <span className="info-label">Created:</span>
              <span className="info-value">{formatDate(goal.created_at)}</span>
            </div>

            {goal.target_date && (
              <div className="info-item">
                <span className="info-label">Target Date:</span>
                <span className={`info-value ${isGoalOverdue ? 'text-danger' : ''}`}>
                  {formatDate(goal.target_date)}
                  {isGoalOverdue && ' (Overdue)'}
                </span>
              </div>
            )}

            {goal.completed_at && (
              <div className="info-item">
                <span className="info-label">Completed:</span>
                <span className="info-value text-success">
                  {formatDate(goal.completed_at)}
                </span>
              </div>
            )}

            {goal.archived_at && (
              <div className="info-item">
                <span className="info-label">Archived:</span>
                <span className="info-value">{formatDate(goal.archived_at)}</span>
              </div>
            )}
          </div>

          {/* Progress entries will be added in Phase 3 */}
          <div className="goal-section">
            <h3>Progress Tracking</h3>
            <p className="text-muted">Progress tracking will be available in the next phase.</p>
          </div>
        </Card.Body>

        <Card.Footer>
          <div className="goal-actions">
            <Button
              variant="ghost"
              onClick={() => navigate(`/goals/${id}/edit`)}
            >
              Edit
            </Button>

            {!goal.completed_at && !goal.archived_at && (
              <Button
                variant="primary"
                onClick={handleComplete}
                disabled={completeGoal.isLoading}
              >
                Mark Complete
              </Button>
            )}

            {!goal.archived_at && (
              <Button
                variant="secondary"
                onClick={handleArchive}
                disabled={archiveGoal.isLoading}
              >
                Archive
              </Button>
            )}

            <Button
              variant="danger"
              onClick={handleDelete}
              disabled={deleteGoal.isLoading}
            >
              Delete
            </Button>
          </div>
        </Card.Footer>
      </Card>
    </div>
  );
}

export default GoalDetails;