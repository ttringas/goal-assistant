import { useState } from 'react';
import { useUpdateGoal, useCompleteGoal, useArchiveGoal } from '../../hooks/useGoals';
import { formatDate, isOverdue } from '../../utils/dateHelpers';
import Card from '../shared/Card';
import Button from '../shared/Button';
import InlineEdit from '../shared/InlineEdit';

function GoalCard({ goal }) {
  const [isArchiving, setIsArchiving] = useState(false);
  const updateGoal = useUpdateGoal();
  const completeGoal = useCompleteGoal();
  const archiveGoal = useArchiveGoal();

  const handleUpdateField = (field, value) => {
    updateGoal.mutate({
      id: goal.id,
      data: { [field]: value }
    });
  };

  const handleComplete = () => {
    if (window.confirm('Mark this goal as complete?')) {
      completeGoal.mutate(goal.id);
    }
  };

  const handleArchive = () => {
    setIsArchiving(true);
    setTimeout(() => {
      archiveGoal.mutate(goal.id);
    }, 300);
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
    <Card className={`goal-card ${isArchiving ? 'archiving' : ''}`}>
      <Card.Header>
        <div className="goal-card-header">
          <h3>
            <InlineEdit
              value={goal.title}
              onSave={(value) => handleUpdateField('title', value)}
              placeholder="Goal title"
            />
          </h3>
          {goal.goal_type && (
            <span className={`goal-type ${getGoalTypeClass(goal.goal_type)}`}>
              {goal.goal_type}
            </span>
          )}
        </div>
      </Card.Header>
      
      <Card.Body>
        <div className="goal-description">
          <InlineEdit
            value={goal.description}
            onSave={(value) => handleUpdateField('description', value)}
            type="textarea"
            placeholder="Add a description..."
          />
        </div>
        
        <div className="goal-meta">
          <div className={`goal-date ${isGoalOverdue ? 'overdue' : ''}`}>
            <span>Target: </span>
            <InlineEdit
              value={goal.target_date}
              onSave={(value) => handleUpdateField('target_date', value)}
              type="date"
              placeholder="Set target date"
            />
            {isGoalOverdue && <span className="overdue-label">Overdue</span>}
          </div>
          
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
      
      <Card.Footer>
        <div className="goal-actions">
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
        </div>
      </Card.Footer>
    </Card>
  );
}

export default GoalCard;