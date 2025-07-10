import { Link, useNavigate } from 'react-router-dom';
import { useCompleteGoal, useArchiveGoal, useDeleteGoal } from '../../hooks/useGoals';
import { formatDate, isOverdue } from '../../utils/dateHelpers';
import Card from '../shared/Card';
import Button from '../shared/Button';

function GoalCard({ goal }) {
  const navigate = useNavigate();
  const completeGoal = useCompleteGoal();
  const archiveGoal = useArchiveGoal();
  const deleteGoal = useDeleteGoal();

  const handleComplete = (e) => {
    e.preventDefault();
    if (window.confirm('Mark this goal as complete?')) {
      completeGoal.mutate(goal.id);
    }
  };

  const handleArchive = (e) => {
    e.preventDefault();
    if (window.confirm('Archive this goal?')) {
      archiveGoal.mutate(goal.id);
    }
  };

  const handleDelete = (e) => {
    e.preventDefault();
    if (window.confirm('Delete this goal? This action cannot be undone.')) {
      deleteGoal.mutate(goal.id);
    }
  };

  const getGoalTypeClass = (type) => {
    const classes = {
      habit: 'goal-type-habit',
      milestone: 'goal-type-milestone',
      project: 'goal-type-project',
    };
    return classes[type] || '';
  };

  const isGoalOverdue = !goal.completed_at && isOverdue(goal.target_date);

  return (
    <Card className="goal-card">
      <Link to={`/goals/${goal.id}`} className="goal-card-link">
        <Card.Header>
          <div className="goal-card-header">
            <h3>{goal.title}</h3>
            {goal.goal_type && (
              <span className={`goal-type ${getGoalTypeClass(goal.goal_type)}`}>
                {goal.goal_type}
              </span>
            )}
          </div>
        </Card.Header>
        
        <Card.Body>
          {goal.description && (
            <p className="goal-description">{goal.description}</p>
          )}
          
          <div className="goal-meta">
            {goal.target_date && (
              <div className={`goal-date ${isGoalOverdue ? 'overdue' : ''}`}>
                <span>Target: {formatDate(goal.target_date)}</span>
                {isGoalOverdue && <span className="overdue-label">Overdue</span>}
              </div>
            )}
            
            {goal.completed_at && (
              <div className="goal-status completed">
                ✓ Completed {formatDate(goal.completed_at)}
              </div>
            )}
            
            {goal.archived_at && (
              <div className="goal-status archived">
                📁 Archived {formatDate(goal.archived_at)}
              </div>
            )}
          </div>
        </Card.Body>
      </Link>
      
      <Card.Footer>
        <div className="goal-actions">
          <Button
            variant="ghost"
            size="small"
            onClick={(e) => {
              e.preventDefault();
              navigate(`/goals/${goal.id}/edit`);
            }}
          >
            Edit
          </Button>
          
          {!goal.completed_at && !goal.archived_at && (
            <Button
              variant="primary"
              size="small"
              onClick={handleComplete}
              disabled={completeGoal.isLoading}
            >
              Complete
            </Button>
          )}
          
          {!goal.archived_at && (
            <Button
              variant="secondary"
              size="small"
              onClick={handleArchive}
              disabled={archiveGoal.isLoading}
            >
              Archive
            </Button>
          )}
          
          <Button
            variant="danger"
            size="small"
            onClick={handleDelete}
            disabled={deleteGoal.isLoading}
          >
            Delete
          </Button>
        </div>
      </Card.Footer>
    </Card>
  );
}

export default GoalCard;