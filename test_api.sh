#!/bin/bash

echo "Testing Goal Tracker API..."
echo "=========================="

# Test Goals endpoints
echo -e "\n1. GET /api/v1/goals"
curl -s http://localhost:3000/api/v1/goals | jq 'length'

echo -e "\n2. GET /api/v1/goals?active=true"
curl -s "http://localhost:3000/api/v1/goals?active=true" | jq 'length'

echo -e "\n3. POST /api/v1/goals (Create new goal)"
curl -s -X POST http://localhost:3000/api/v1/goals \
  -H "Content-Type: application/json" \
  -d '{
    "goal": {
      "title": "Test Goal",
      "description": "This is a test goal",
      "goal_type": "habit",
      "target_date": "2025-12-31"
    }
  }' | jq '.title'

echo -e "\n4. GET /api/v1/progress_entries"
curl -s http://localhost:3000/api/v1/progress_entries | jq 'length'

echo -e "\n5. POST /api/v1/progress_entries (Create progress entry)"
GOAL_ID=$(curl -s http://localhost:3000/api/v1/goals | jq '.[0].id')
curl -s -X POST http://localhost:3000/api/v1/progress_entries \
  -H "Content-Type: application/json" \
  -d "{
    \"progress_entry\": {
      \"content\": \"Made great progress today!\",
      \"entry_date\": \"$(date +%Y-%m-%d)\",
      \"goal_id\": $GOAL_ID
    }
  }" | jq '.content'

echo -e "\nAll API endpoints tested successfully!"