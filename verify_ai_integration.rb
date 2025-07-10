#!/usr/bin/env ruby
# Script to verify AI summaries are created through real API calls

require_relative 'config/environment'

puts "=== AI Summary Integration Verification ==="
puts

# Create test data
puts "1. Creating test progress entries..."
date = Date.current.beginning_of_month
5.times do |i|
  entry = ProgressEntry.create!(
    content: "Day #{i+1}: Made progress on meditation practice and ran 2 miles",
    entry_date: date + i.days
  )
  puts "   Created entry for #{entry.entry_date}"
end

# Enable detailed logging
Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::DEBUG

puts "\n2. Running monthly summary job with detailed logging..."
puts "-" * 50

# Run the job
job = MonthlySummaryJob.new
job.perform(Date.current)

puts "-" * 50

# Fetch and display the summary
summary = Summary.find_by(
  summary_type: 'monthly',
  start_date: Date.current.beginning_of_month,
  end_date: Date.current.end_of_month
)

if summary
  puts "\n3. Summary successfully created!"
  puts "   Summary ID: #{summary.id}"
  puts "   Created at: #{summary.created_at}"
  puts "   Content length: #{summary.content.length} characters"
  puts "\n   First 200 characters of AI-generated content:"
  puts "   #{summary.content[0..200]}..."
  puts "\n   Metadata:"
  puts "   #{summary.metadata.to_json}"
else
  puts "\n3. ERROR: No summary found!"
end

puts "\n=== Verification Complete ==="