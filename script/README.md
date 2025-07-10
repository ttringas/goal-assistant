# AI API Testing Script

This script tests the AI integration in the Goal Assistant app, verifying that both Anthropic and OpenAI APIs are working correctly.

## Usage

First, ensure you have API keys set in your `.env` file:
```
ANTHROPIC_API_KEY=your_anthropic_api_key_here
OPENAI_API_KEY=your_openai_api_key_here
```

Then run the script:
```bash
rails runner script/test_ai_apis.rb
```

Or if you're in the Rails console:
```ruby
load 'script/test_ai_apis.rb'
```

## What It Tests

1. **Environment Variables** - Checks that API keys are properly configured
2. **Goal Type Inference** - Tests AI's ability to categorize goals as habit/milestone/project
3. **Goal Improvement Suggestions** - Tests AI's ability to provide actionable improvements
4. **Provider Fallback** - Tests automatic fallback from Anthropic to OpenAI
5. **Direct API Calls** - Tests raw API calls to both providers
6. **API Endpoints** - Tests the Rails API endpoints (requires server to be running)

## Expected Output

When successful, you should see:
- ✅ Green checkmarks for successful tests
- AI responses for goal categorization
- Improvement suggestions for sample goals
- Confirmation that both APIs are responding

## Troubleshooting

- If you see "API key is not set" errors, check your `.env` file
- If endpoint tests fail, ensure your Rails server is running on port 3000
- Rate limit errors indicate you've exceeded API quotas
- 529 errors from Anthropic will automatically trigger OpenAI fallback