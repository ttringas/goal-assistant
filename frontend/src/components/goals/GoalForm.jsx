import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { formatDateForInput } from '../../utils/dateHelpers';
import Button from '../shared/Button';
import Card from '../shared/Card';
import api from '../../services/api';

function GoalForm({ goal, onSubmit, isLoading }) {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    title: goal?.title || '',
    description: goal?.description || '',
    goal_type: goal?.goal_type || '',
    target_date: goal?.target_date ? formatDateForInput(goal.target_date) : '',
  });

  const [errors, setErrors] = useState({});
  const [aiSuggestions, setAiSuggestions] = useState(null);
  const [inferringType, setInferringType] = useState(false);
  const [loadingImprovements, setLoadingImprovements] = useState(false);

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

  const handleInferType = async () => {
    if (!formData.title.trim()) {
      setErrors({ title: 'Please enter a title first' });
      return;
    }

    setInferringType(true);
    try {
      const response = await api.post('/ai/infer_goal_type', {
        title: formData.title,
        description: formData.description
      });

      if (response.data.goal_type) {
        setFormData(prev => ({
          ...prev,
          goal_type: response.data.goal_type
        }));
      }
    } catch (error) {
      console.error('Failed to infer goal type:', error);
    } finally {
      setInferringType(false);
    }
  };

  const handleGetImprovements = async () => {
    if (!formData.title.trim()) {
      setErrors({ title: 'Please enter a title first' });
      return;
    }

    setLoadingImprovements(true);
    try {
      const response = await api.post('/ai/improve_goal', {
        title: formData.title,
        description: formData.description,
        goal_type: formData.goal_type
      });

      if (response.data.formatted_suggestions) {
        setAiSuggestions(response.data.formatted_suggestions);
      }
    } catch (error) {
      console.error('Failed to get improvements:', error);
    } finally {
      setLoadingImprovements(false);
    }
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
              <label htmlFor="goal_type">
                Type
                <button
                  type="button"
                  onClick={handleInferType}
                  disabled={inferringType}
                  className="ml-2 text-sm text-blue-500 hover:text-blue-600 disabled:text-gray-400"
                >
                  {inferringType ? '...' : 'AI Suggest'}
                </button>
              </label>
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

          {/* AI Suggestions Section */}
          <div className="mt-6">
            <button
              type="button"
              onClick={handleGetImprovements}
              disabled={loadingImprovements}
              className="text-sm bg-gray-100 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-200 disabled:opacity-50"
            >
              {loadingImprovements ? 'Getting AI suggestions...' : 'Get AI suggestions to improve this goal'}
            </button>

            {aiSuggestions && (
              <div className="mt-4 p-4 bg-blue-50 rounded-lg border border-blue-200">
                <h3 className="text-sm font-medium text-gray-800 mb-2">AI Suggestions:</h3>
                <ul className="space-y-2">
                  {aiSuggestions.map((suggestion, index) => (
                    <li key={index} className="text-sm text-gray-700 flex items-start">
                      <span className="text-blue-500 mr-2">•</span>
                      <span>{suggestion}</span>
                    </li>
                  ))}
                </ul>
              </div>
            )}
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