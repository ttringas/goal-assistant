# Goal Assistant

An AI-powered goal tracking application that helps users set goals, track daily progress, and receive AI-generated summaries and nudges. Built with Rails 8 backend and React/Vite frontend.

## Features

- **Goal Management**: Create and manage different types of goals (habits, milestones, projects)
- **Daily Check-ins**: Track progress with daily journal entries
- **AI-Powered Features**:
  - Automatic goal type inference
  - Goal improvement suggestions
  - Daily, weekly, and monthly AI-generated summaries
- **User Authentication**: Secure multi-user support with JWT authentication
- **Email Nudges**: Customizable reminder emails (coming soon)
- **Self-Hosted**: Complete control over your data

## Tech Stack

- **Backend**: Rails 8.0.2 (API-only mode)
- **Frontend**: React 18 with Vite
- **Database**: PostgreSQL
- **Authentication**: Devise with JWT tokens
- **AI Integration**: OpenAI and Anthropic Claude support
- **Background Jobs**: GoodJob
- **Email**: Action Mailer with Mailgun (configurable)
- **Styling**: Tailwind CSS

## Prerequisites

- Ruby 3.4.1 (managed with mise/rbenv/rvm)
- Node.js 22+ (managed with mise/nvm)
- PostgreSQL 14+
- Redis (optional, for Action Cable)

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/goal-assistant.git
cd goal-assistant
```

### 2. Backend Setup

```bash
# Install Ruby dependencies
bundle install

# Setup environment variables
cp .env.example .env
# Edit .env and add your API keys and configuration
```

Required environment variables:
```bash
# Database
DATABASE_URL=postgresql://localhost/goal_assistant_development

# AI Provider Keys (at least one required)
ANTHROPIC_API_KEY=your_anthropic_api_key
OPENAI_API_KEY=your_openai_api_key

# AI Configuration
DEFAULT_AI_PROVIDER=anthropic # or 'openai'
AI_MODEL_ANTHROPIC=claude-3-5-sonnet-20241022
AI_MODEL_OPENAI=gpt-4o

# Authentication
DEVISE_JWT_SECRET_KEY=your_secret_key_here

# Encryption keys (generate with: rails db:encryption:init)
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=your_primary_key
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=your_deterministic_key
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=your_salt

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:5173
```

```bash
# Setup database
rails db:create
rails db:migrate

# (Optional) Seed with sample data
rails db:seed

# Generate encryption keys if not already set
rails db:encryption:init

# Start the Rails server
rails server
```

### 3. Frontend Setup

```bash
# Navigate to frontend directory
cd frontend

# Install Node dependencies
npm install

# Start the development server
npm run dev
```

The frontend will be available at `http://localhost:5173`

### 4. Background Jobs (for AI summaries)

In a separate terminal:
```bash
bundle exec good_job start
```

## Usage

### First Time Setup

1. Visit `http://localhost:5173/register` to create an account
2. Log in with your credentials
3. (Optional) Add your own API keys in the Profile section for AI features

### Daily Workflow

1. **Check-in**: Start your day with the Check-in page to journal your progress
2. **Goals**: Create and manage your goals with AI assistance
3. **Timeline**: View your progress history and AI-generated insights
4. **Dashboard**: Get an overview of your active goals and recent progress

### Goal Types

- **Habit**: Recurring activities (e.g., "Daily meditation")
- **Milestone**: One-time achievements (e.g., "Run a 5K")
- **Project**: Multi-step endeavors (e.g., "Launch side business")

## Development

### Running Tests

```bash
# Backend tests
bundle exec rspec

# Frontend tests
cd frontend
npm test

# E2E tests with Playwright
cd frontend
npm run test:e2e
```

### Code Quality

```bash
# Ruby linting
bundle exec rubocop

# JavaScript linting
cd frontend
npm run lint
```

### Database Management

```bash
# Run migrations
rails db:migrate

# Rollback migrations
rails db:rollback

# Reset database (caution: deletes all data)
rails db:reset
```

## Architecture Notes

### Authentication Flow

1. User signs in via `/api/v1/users/sign_in`
2. Server returns JWT token in Authorization header
3. Frontend stores token and includes it in all API requests
4. Token expires after 24 hours

### Data Model

- **User**: Central model, all data is scoped to users
- **Goal**: User's goals with type, description, and target date
- **ProgressEntry**: Daily journal entries linked to goals
- **Summary**: AI-generated summaries (daily/weekly/monthly)
- **AiSummary**: Legacy model, migrated to Summary

### API Endpoints

All API endpoints are prefixed with `/api/v1/` and require authentication (except auth endpoints):

- **Authentication**: POST `/users/sign_in`, POST `/users` (register)
- **Goals**: Full CRUD + `/goals/:id/complete`, `/goals/:id/archive`
- **Progress**: GET/POST `/progress_entries`, GET `/progress_entries/today`
- **Summaries**: GET `/summaries`, POST `/summaries/regenerate_all`
- **AI**: POST `/ai/infer_goal_type`, POST `/ai/improve_goal`
- **User**: GET `/user/current`, PATCH `/user/update_api_keys`

### Frontend Structure

```
frontend/
├── src/
│   ├── components/     # Reusable React components
│   ├── contexts/       # React contexts (Auth)
│   ├── hooks/          # Custom React hooks
│   ├── pages/          # Page components
│   ├── services/       # API client and services
│   └── App.jsx         # Main app component with routing
```

## Deployment

### Environment Variables for Production

Additional variables needed for production:

```bash
RAILS_ENV=production
SECRET_KEY_BASE=your_production_secret
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Email configuration (for nudges)
SMTP_ADDRESS=smtp.mailgun.org
SMTP_PORT=587
SMTP_DOMAIN=your-domain.com
SMTP_USERNAME=your-mailgun-username
SMTP_PASSWORD=your-mailgun-password
```

### Database Setup

```bash
RAILS_ENV=production rails db:create
RAILS_ENV=production rails db:migrate
```

### Asset Compilation

```bash
# Frontend build
cd frontend
npm run build

# The built files will be in frontend/dist/
```

## Troubleshooting

### Common Issues

1. **JWT Token errors**: Ensure `DEVISE_JWT_SECRET_KEY` is set
2. **CORS errors**: Check `FRONTEND_URL` matches your frontend address
3. **AI features not working**: Verify API keys are set correctly
4. **Database connection failed**: Check `DATABASE_URL` format
5. **Encryption errors**: Run `rails db:encryption:init` and update .env

### Development Tips

- Use `rails c` for interactive console
- Check logs with `tail -f log/development.log`
- Frontend uses Vite's HMR for fast development
- API requests can be tested with `curl` or Postman

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgments

- Built as an educational project to demonstrate Rails + React integration
- AI features powered by Anthropic Claude and OpenAI
- Inspired by personal productivity methodologies