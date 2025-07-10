import { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { ChevronDown, ChevronRight, RefreshCw } from 'lucide-react';
import api from '../services/api';

function Timeline() {
  const [expandedMonths, setExpandedMonths] = useState({});
  const [expandedWeeks, setExpandedWeeks] = useState({});
  const [monthsToShow, setMonthsToShow] = useState(2); // Start with 2 months
  const [regenerating, setRegenerating] = useState(false);
  const queryClient = useQueryClient();

  // Get progress entries
  const { data: entries = [] } = useQuery({
    queryKey: ['progressEntries'],
    queryFn: async () => {
      const response = await api.get('/progress_entries');
      return response.data;
    }
  });

  // Get summaries
  const { data: summaries = [], refetch: refetchSummaries } = useQuery({
    queryKey: ['summaries'],
    queryFn: async () => {
      const response = await api.get('/summaries');
      return response.data;
    }
  });

  // Regenerate summaries mutation
  const regenerateSummaries = useMutation({
    mutationFn: async () => {
      const response = await api.post('/summaries/regenerate_all');
      return response.data;
    },
    onSuccess: (data) => {
      alert(`Regeneration started!\n\nQueued jobs:\n- Daily: ${data.jobs_queued.daily}\n- Weekly: ${data.jobs_queued.weekly}\n- Monthly: ${data.jobs_queued.monthly}\n\n${data.note}`);
      // Poll for updates every 5 seconds for 2 minutes
      const pollInterval = setInterval(() => {
        refetchSummaries();
      }, 5000);
      
      setTimeout(() => {
        clearInterval(pollInterval);
        setRegenerating(false);
      }, 120000); // Stop after 2 minutes
    },
    onError: (error) => {
      alert('Failed to regenerate summaries. Please try again.');
      setRegenerating(false);
    }
  });

  // Group all data by month, week, and day
  const groupedData = useMemo(() => {
    const data = {};
    
    // Add progress entries
    entries.forEach(entry => {
      const date = new Date(entry.entry_date);
      const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
      const weekKey = getWeekKey(date);
      const dayKey = entry.entry_date;

      if (!data[monthKey]) data[monthKey] = { weeks: {}, summary: null };
      if (!data[monthKey].weeks[weekKey]) data[monthKey].weeks[weekKey] = { days: {}, summary: null };
      if (!data[monthKey].weeks[weekKey].days[dayKey]) data[monthKey].weeks[weekKey].days[dayKey] = { entries: [], summary: null };
      
      data[monthKey].weeks[weekKey].days[dayKey].entries.push(entry);
    });

    // Add summaries
    summaries.forEach(summary => {
      const startDate = new Date(summary.start_date);
      const monthKey = `${startDate.getFullYear()}-${String(startDate.getMonth() + 1).padStart(2, '0')}`;

      if (summary.summary_type === 'monthly') {
        if (!data[monthKey]) data[monthKey] = { weeks: {}, summary: null };
        data[monthKey].summary = summary;
      } else if (summary.summary_type === 'weekly') {
        const weekKey = getWeekKey(startDate);
        if (!data[monthKey]) data[monthKey] = { weeks: {}, summary: null };
        if (!data[monthKey].weeks[weekKey]) data[monthKey].weeks[weekKey] = { days: {}, summary: null };
        data[monthKey].weeks[weekKey].summary = summary;
      } else if (summary.summary_type === 'daily') {
        const weekKey = getWeekKey(startDate);
        const dayKey = summary.start_date;
        if (!data[monthKey]) data[monthKey] = { weeks: {}, summary: null };
        if (!data[monthKey].weeks[weekKey]) data[monthKey].weeks[weekKey] = { days: {}, summary: null };
        if (!data[monthKey].weeks[weekKey].days[dayKey]) data[monthKey].weeks[weekKey].days[dayKey] = { entries: [], summary: null };
        data[monthKey].weeks[weekKey].days[dayKey].summary = summary;
      }
    });

    return data;
  }, [entries, summaries]);

  // Helper function to get week key
  function getWeekKey(date) {
    const tempDate = new Date(date);
    const dayOfWeek = tempDate.getDay();
    const startOfWeek = new Date(tempDate);
    startOfWeek.setDate(tempDate.getDate() - dayOfWeek);
    return startOfWeek.toISOString().split('T')[0];
  }

  // Helper function to format month header
  function formatMonthHeader(monthKey) {
    const [year, month] = monthKey.split('-');
    const date = new Date(year, parseInt(month) - 1);
    return date.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });
  }

  // Helper function to format week range
  function formatWeekRange(weekKey) {
    const startDate = new Date(weekKey);
    const endDate = new Date(startDate);
    endDate.setDate(startDate.getDate() + 6);
    
    const startFormat = startDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    const endFormat = endDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    
    return `Week of ${startFormat}-${endFormat.split(' ')[1]}`;
  }

  // Helper function to format day
  function formatDay(dayKey) {
    const date = new Date(dayKey);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  }

  // Toggle month expansion
  const toggleMonth = (monthKey) => {
    setExpandedMonths(prev => ({
      ...prev,
      [monthKey]: !prev[monthKey]
    }));
  };

  // Toggle week expansion
  const toggleWeek = (weekKey) => {
    setExpandedWeeks(prev => ({
      ...prev,
      [weekKey]: !prev[weekKey]
    }));
  };

  // Auto-expand current month and week
  useMemo(() => {
    const today = new Date();
    const currentMonth = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}`;
    const currentWeek = getWeekKey(today);
    
    setExpandedMonths(prev => ({ ...prev, [currentMonth]: true }));
    setExpandedWeeks(prev => ({ ...prev, [currentWeek]: true }));
  }, []);

  // Sort months in descending order and limit to monthsToShow
  const allSortedMonths = Object.keys(groupedData).sort().reverse();
  const displayedMonths = allSortedMonths.slice(0, monthsToShow);
  const hasMoreMonths = allSortedMonths.length > monthsToShow;

  // Load more months
  const loadEarlierMessages = () => {
    setMonthsToShow(prev => prev + 2);
  };

  const handleRegenerate = () => {
    if (confirm('This will regenerate all summaries for the past 3 months. This may take a few minutes. Continue?')) {
      setRegenerating(true);
      regenerateSummaries.mutate();
    }
  };

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-2xl font-light text-gray-800">Timeline</h1>
        <button
          onClick={handleRegenerate}
          disabled={regenerating}
          className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          <RefreshCw className={`w-4 h-4 ${regenerating ? 'animate-spin' : ''}`} />
          {regenerating ? 'Regenerating...' : 'Regenerate all summaries'}
        </button>
      </div>
      
      <div className="space-y-6">
        {displayedMonths.map(monthKey => {
          const monthData = groupedData[monthKey];
          const isMonthExpanded = expandedMonths[monthKey];
          const sortedWeeks = Object.keys(monthData.weeks).sort().reverse();

          return (
            <div key={monthKey}>
              {/* Month Header */}
              <div className="flex items-start gap-3">
                <div className="mt-1">
                  <div className="w-3 h-3 bg-blue-500 rounded-full"></div>
                </div>
                <div className="flex-1">
                  <button
                    onClick={() => toggleMonth(monthKey)}
                    className="flex items-center gap-2 text-lg font-medium text-gray-800 hover:text-gray-600 mb-1"
                  >
                    {formatMonthHeader(monthKey)}
                    {isMonthExpanded ? (
                      <ChevronDown className="w-4 h-4" />
                    ) : (
                      <ChevronRight className="w-4 h-4" />
                    )}
                  </button>
                  
                  {monthData.summary && (
                    <div className="text-sm text-gray-600 mb-2">Monthly Summary</div>
                  )}
                  
                  {monthData.summary && (
                    <div className="bg-blue-50 rounded-lg p-4 mb-4 border-l-4 border-blue-400">
                      <p className="text-gray-700">{monthData.summary.content}</p>
                    </div>
                  )}
                </div>
              </div>

              {/* Weeks */}
              {isMonthExpanded && (
                <div className="ml-6 space-y-4 mt-4">
                  {sortedWeeks.map(weekKey => {
                    const weekData = monthData.weeks[weekKey];
                    const isWeekExpanded = expandedWeeks[weekKey];
                    const sortedDays = Object.keys(weekData.days).sort().reverse();

                    return (
                      <div key={weekKey}>
                        {/* Week Header */}
                        <div className="flex items-start gap-3">
                          <div className="mt-1">
                            <div className="w-3 h-3 bg-green-500 rounded-full"></div>
                          </div>
                          <div className="flex-1">
                            <button
                              onClick={() => toggleWeek(weekKey)}
                              className="flex items-center gap-2 text-base font-medium text-gray-700 hover:text-gray-600"
                            >
                              {formatWeekRange(weekKey)}
                              {isWeekExpanded ? (
                                <ChevronDown className="w-4 h-4" />
                              ) : (
                                <ChevronRight className="w-4 h-4" />
                              )}
                            </button>
                            
                            {weekData.summary && (
                              <div className="text-sm text-gray-500 mb-1">Weekly Summary</div>
                            )}
                            
                            {weekData.summary && (
                              <div className="bg-green-50 rounded-lg p-4 mt-2 border-l-4 border-green-400">
                                <p className="text-gray-700">{weekData.summary.content}</p>
                              </div>
                            )}
                          </div>
                        </div>

                        {/* Days */}
                        {isWeekExpanded && (
                          <div className="ml-6 space-y-3 mt-3">
                            {sortedDays.map(dayKey => {
                              const dayData = weekData.days[dayKey];

                              return (
                                <div key={dayKey} className="flex items-start gap-3">
                                  <div className="mt-1">
                                    <div className="w-3 h-3 bg-gray-400 rounded-full"></div>
                                  </div>
                                  <div className="flex-1">
                                    <div className="text-base font-medium text-gray-700 mb-1">
                                      {formatDay(dayKey)}
                                      {dayData.summary && (
                                        <span className="text-sm text-gray-500 ml-2">daily</span>
                                      )}
                                    </div>
                                    
                                    {/* Daily Summary */}
                                    {dayData.summary && (
                                      <div className="bg-blue-50 rounded-lg p-3 mb-2 text-sm">
                                        <p className="text-gray-700">{dayData.summary.content}</p>
                                      </div>
                                    )}
                                    
                                    {/* Progress Entries */}
                                    {dayData.entries.length > 0 && (
                                      <div className="space-y-2">
                                        {dayData.entries.map(entry => (
                                          <div key={entry.id} className="bg-white rounded-lg p-3 border border-gray-200">
                                            <p className="text-gray-700 text-sm whitespace-pre-wrap">{entry.content}</p>
                                            {entry.goal && (
                                              <div className="mt-2 text-xs text-gray-500">
                                                Related to: {entry.goal.title}
                                              </div>
                                            )}
                                          </div>
                                        ))}
                                      </div>
                                    )}
                                  </div>
                                </div>
                              );
                            })}
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}
      </div>

      {/* Load Earlier Messages Button */}
      {hasMoreMonths && (
        <div className="mt-8 text-center">
          <button
            onClick={loadEarlierMessages}
            className="text-gray-600 hover:text-gray-800 font-medium transition-colors"
          >
            Load Earlier Entries
          </button>
        </div>
      )}

      {displayedMonths.length === 0 && (
        <div className="text-center py-12 text-gray-500">
          No entries or insights to display yet.
        </div>
      )}
    </div>
  );
}

export default Timeline;