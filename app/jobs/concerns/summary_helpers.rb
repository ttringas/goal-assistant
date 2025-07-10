module SummaryHelpers
  extend ActiveSupport::Concern
  
  private
  
  def extract_goal_mentions(entries, goals)
    mentioned_goal_ids = []
    entries_text = entries.map(&:content).join(' ').downcase
    
    goals.each do |goal|
      # Check for exact title match
      if entries_text.include?(goal.title.downcase)
        mentioned_goal_ids << goal.id
        next
      end
      
      # Check for individual words from the goal title
      # This helps match "5k" in entries when goal is "Run 5K"
      goal_words = goal.title.downcase.split(/\s+/)
      
      # Skip common words that might cause false positives
      # Allow 2-character words if they contain numbers (like "5k")
      significant_words = goal_words.reject do |word| 
        (word.length < 2) || 
        (word.length < 3 && !word.match?(/\d/)) || 
        %w[the and for with to of in on at by a an].include?(word)
      end
      
      # If any significant word from the goal appears in entries, consider it mentioned
      # Also check if the word is a substring of words in entries (for stems like meditate/meditation)
      if significant_words.any? { |word|
        # Check exact word match in text
        entries_text.include?(word) || 
        # Check word stems (e.g., "meditate" matches "meditation", "meditating", etc.)
        entries_text.split(/\s+/).any? { |entry_word| 
          # Remove punctuation for better matching
          clean_entry_word = entry_word.gsub(/[^\w]/, '')
          # For longer words (4+ chars), check if they share a common stem
          if word.length >= 4 && clean_entry_word.length >= 4
            # Check if entry word starts with goal word (meditation starts with meditate)
            # or if they share a common root (at least 4 chars)
            clean_entry_word.start_with?(word) || 
            (word.length > 4 && clean_entry_word.start_with?(word[0...-2])) ||
            (clean_entry_word.length > 4 && word.start_with?(clean_entry_word[0...-2]))
          else
            # For shorter words, require exact match
            clean_entry_word == word
          end
        }
      }
        mentioned_goal_ids << goal.id
      end
    end
    
    mentioned_goal_ids.uniq
  end
  
  def format_entries_for_prompt(entries)
    entries.map { |e| "- #{e.content}" }.join("\n")
  end
  
  def format_goals_for_prompt(goals)
    goals.map { |g| "- #{g.title} (#{g.goal_type || 'unspecified'})" }.join("\n")
  end
end