import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { formatDateForInput } from '../../utils/dateHelpers';
import Button from '../shared/Button';
import Card from '../shared/Card';

function GoalForm({ goal, onSubmit, isLoading }) {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    title: goal?.title || '',
    description: goal?.description || '',
    goal_type: goal?.goal_type || '',
    target_date: goal?.target_date ? formatDateForInput(goal.target_date) : '',
  });

  const [errors, setErrors] = useState({});

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
    // Clear error when user types
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: '',
      }));
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.title.trim()) {
      newErrors.title = 'Title is required';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }
    
    onSubmit(formData);
  };

  return (
    <Card>
      <form onSubmit={handleSubmit}>
        <Card.Body>
          <div className="form-group">
            <label htmlFor="title">Title *</label>
            <input
              type="text"
              id="title"
              name="title"
              value={formData.title}
              onChange={handleChange}
              className={`form-input ${errors.title ? 'error' : ''}`}
              placeholder="Enter goal title"
            />
            {errors.title && (
              <span className="form-error">{errors.title}</span>
            )}
          </div>

          <div className="form-group">
            <label htmlFor="description">Description</label>
            <textarea
              id="description"
              name="description"
              value={formData.description}
              onChange={handleChange}
              className="form-textarea"
              rows={4}
              placeholder="Describe your goal..."
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label htmlFor="goal_type">Type</label>
              <select
                id="goal_type"
                name="goal_type"
                value={formData.goal_type}
                onChange={handleChange}
                className="form-select"
              >
                <option value="">Select type</option>
                <option value="habit">Habit</option>
                <option value="milestone">Milestone</option>
                <option value="project">Project</option>
              </select>
            </div>

            <div className="form-group">
              <label htmlFor="target_date">Target Date</label>
              <input
                type="date"
                id="target_date"
                name="target_date"
                value={formData.target_date}
                onChange={handleChange}
                className="form-input"
              />
            </div>
          </div>
        </Card.Body>

        <Card.Footer>
          <div className="form-actions">
            <Button
              type="button"
              variant="ghost"
              onClick={() => navigate('/goals')}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              variant="primary"
              disabled={isLoading}
            >
              {isLoading ? 'Saving...' : (goal ? 'Update Goal' : 'Create Goal')}
            </Button>
          </div>
        </Card.Footer>
      </form>
    </Card>
  );
}

export default GoalForm;