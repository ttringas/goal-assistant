# Goal Tracker App - Development Scope

## Project Overview
An AI-powered goal tracking application that helps users set goals, track daily progress, and receive AI-generated summaries and nudges. Built with Rails 8 backend and React/Vite frontend, designed to be self-hostable and educational.

## Technical Stack
- **Backend**: Rails 8 API
- **Database**: PostgreSQL
- **Background Jobs**: GoodJob
- **Frontend**: React with Vite
- **Email**: Mailgun (for sending nudges and receiving replies)
- **AI Integration**: ruby_llm gem (supporting OpenAI and Anthropic)
- **Authentication**: Devise (email/password only) - added in Phase 6
- **Deployment Target**: Render or Railway ($5-10/month)

## Development Phases

### Phase 1: Foundation and Core Models
**Goal**: Set up Rails application and build fundamental data models

1. Initialize Rails 8 API application with PostgreSQL
2. Set up CORS for React frontend communication
3. Create Goal model
   - Fields: title, description, target_date, goal_type, completed_at, archived_at
   - Basic validations
4. Create ProgressEntry model
   - Fields: content, entry_date
   - One entry per day constraint (will add user constraint later)
5. Build RESTful controllers for Goals
   - Index (with filtering for active/archived)
   - Create, Read, Update, Delete
   - Complete/Archive actions
6. Build RESTful controller for ProgressEntries
   - Create/Update (upsert pattern for daily entries)
   - Index by date range
7. Create seeds for development data

**Key Learning Points**: Rails API setup, RESTful design, data modeling

### Phase 2: React Frontend Foundation
**Goal**: Set up React and build basic goal management UI

1. Initialize React app with Vite
2. Set up routing with React Router
3. Configure API client (no auth needed yet)
4. Create basic layout components
   - Navigation
   - Dashboard shell
5. Build Goal management UI
   - Goal list view
   - Add/Edit goal form
   - Goal detail view
   - Complete/Archive functionality
6. Style with modern CSS/Tailwind

**Key Learning Points**: React setup, component architecture, API integration

### Phase 3: Progress Tracking UI
**Goal**: Build the daily progress journaling interface

1. Create progress entry form component
2. Build calendar view showing which days have entries
3. Implement entry viewing/editing for past dates
4. Add streak counter display
5. Create a "today" focused dashboard view
6. Build progress entry history view
7. Add pagination for progress entries

**Key Learning Points**: React state management, date handling, UX patterns

### Phase 4: AI Integration Foundation
**Goal**: Integrate AI for goal type inference and suggestions

1. Install and configure ruby_llm gem
2. Set up API keys management (environment variables)
3. Create AI service class for LLM interactions
4. Implement goal type inference
   - When user creates goal, AI determines if it's habit/milestone/project
   - Add endpoint to suggest goal type
5. Add AI-powered goal clarification
   - Suggest improvements to goal descriptions
6. Create prompt templates system
7. Update frontend to show AI suggestions

**Key Learning Points**: AI integration patterns, prompt engineering, service objects

### Phase 5: AI-Generated Summaries
**Goal**: Implement AI-generated summaries with background processing

1. Install and configure GoodJob
2. Create Summary model
   - Fields: summary_type (daily/weekly/monthly), content, start_date, end_date
3. Build summary generation jobs
   - DailySummaryJob (runs at end of day)
   - WeeklySummaryJob (runs Sunday night)
   - MonthlySummaryJob (runs last day of month)
4. Implement AI summary generation
   - Gather relevant progress entries
   - Generate contextual summaries using AI
5. Add manual summary regeneration endpoints
6. Build summary viewing UI with timeline
   - Expandable daily/weekly/monthly views
   - Beautiful timeline visualization

**Key Learning Points**: Background jobs, scheduled tasks, AI content generation

### Phase 6: User Authentication
**Goal**: Add multi-user support with authentication

1. Install and configure Devise for API authentication
2. Create User model with Devise
3. Add user associations to existing models
   - Goal belongs_to :user
   - ProgressEntry belongs_to :user  
   - Summary belongs_to :user
4. Create migration to assign existing data to a default user
5. Update all controllers with authentication
   - Add before_action :authenticate_user!
   - Scope all queries to current_user
6. Build authentication endpoints (login, logout, registration)
7. Update React frontend
   - Login/Register forms
   - Protected routes
   - Auth context/hooks
   - Update API client with auth tokens
8. Add user profile management

**Key Learning Points**: Authentication patterns, data migration, API security

### Phase 7: Email Nudges System
**Goal**: Build the email nudge system with Mailgun

1. Configure Mailgun for sending emails
2. Create Nudge model
   - Fields: schedule (cron), tone_description, enabled
   - Belongs to User
3. Build nudge management API
4. Create nudge email templates
5. Implement scheduled nudge sending job
6. Add AI-powered nudge content generation
   - Use tone_description and recent progress
   - Include relevant goal reminders
7. Build nudge configuration UI
   - Schedule setup
   - Tone customization
   - Enable/disable toggles

**Key Learning Points**: Email integration, cron scheduling, transactional emails

### Phase 8: Email Reply Processing
**Goal**: Enable progress tracking via email replies

1. Configure Mailgun inbound email webhook
2. Create email processing controller
3. Implement reply parsing logic
   - Extract content from email body
   - Match email to user
   - Append to current day's progress entry
4. Add reply-to headers to nudge emails
5. Build email activity log for debugging
6. Test full email round-trip flow
7. Add UI indicators for email-added entries

**Key Learning Points**: Webhook handling, email parsing, system integration

### Phase 9: Enhanced UI and Polish
**Goal**: Polish the frontend with advanced features

1. Add search and filtering
   - Search goals by title/description
   - Filter by goal type
   - Search progress entries
2. Create data visualizations
   - Progress heat map
   - Goal completion trends
   - Streak achievements
3. Implement responsive design
4. Add loading states and error handling
5. Build comprehensive settings page
   - AI provider selection
   - Nudge preferences
   - Account management
6. Add keyboard shortcuts
7. Implement auto-save for progress entries

**Key Learning Points**: Advanced React patterns, data visualization, UX polish

### Phase 10: Deployment and Self-Hosting
**Goal**: Make the app production-ready and easily deployable

1. Create production configuration
   - Environment variable management
   - Production database settings
   - Asset compilation setup
2. Write Dockerfile for containerization
3. Create deployment scripts
4. Set up GitHub Actions for CI/CD
5. Document deployment process for:
   - Render.com
   - Railway.app
6. Create setup wizard for first-run configuration
7. Write self-hosting documentation
8. Add backup/restore functionality
9. Performance optimizations
   - Database indexing
   - Query optimization
   - Frontend bundling

**Key Learning Points**: DevOps basics, containerization, deployment strategies

## Data Models Summary

```ruby
# Phase 1 Models (no user association yet)
Goal
- title
- description  
- target_date
- goal_type (inferred by AI)
- completed_at
- archived_at

ProgressEntry
- content (text)
- entry_date
- unique index on entry_date (will become [user_id, entry_date])

# Phase 5 Models
Summary
- summary_type (daily/weekly/monthly)
- content
- start_date
- end_date

# Phase 6 Models (user associations added)
User
- email
- password (via Devise)
- has_many :goals
- has_many :progress_entries
- has_many :summaries
- has_many :nudges

# Phase 7 Models
Nudge
- schedule (cron format)
- tone_description
- enabled
- belongs_to :user
```

## Key Features Checklist
- [ ] Goal CRUD with AI-inferred types
- [ ] Daily progress journaling
- [ ] AI-generated summaries (daily/weekly/monthly)
- [ ] User authentication (added mid-development)
- [ ] Email nudges with customizable tone
- [ ] Reply-to-email progress tracking
- [ ] Timeline view for summaries
- [ ] Streak tracking
- [ ] Self-hostable with minimal cost

## Environment Variables
```
DATABASE_URL=postgresql://...
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
MAILGUN_API_KEY=...
MAILGUN_DOMAIN=...
FRONTEND_URL=http://localhost:5173
```

## Course Considerations
- **Hook students early** with visible features before authentication
- Each phase builds on the previous one
- Can be completed independently for testing
- Shows how to retrofit authentication into an existing app
- Teaches both "rapid prototyping" and "production-ready" approaches
- Demonstrates real-world development patterns
- Results in a fully functional, deployable app

## Teaching Notes
- Phases 1-5: Build in "single user mode" for rapid development
- Phase 6: Show how to properly add authentication to an existing app
- Emphasize that this mirrors real-world MVP development
- Explain why deferring auth can speed up initial development
- Show how Rails makes it easy to add user scoping later