import GoalCard from './GoalCard';

function GoalList({ goals }) {
  if (goals.length === 0) {
    return (
      <div className="empty-state" data-testid="goals-list">
        <p>No goals found. Create your first goal to get started!</p>
      </div>
    );
  }

  return (
    <div className="goal-list" data-testid="goals-list">
      {goals.map((goal) => (
        <GoalCard key={goal.id} goal={goal} />
      ))}
    </div>
  );
}

export default GoalList;