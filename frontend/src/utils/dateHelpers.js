import { format, parseISO, isValid } from 'date-fns';

export const formatDate = (date) => {
  if (!date) return '';
  
  const parsedDate = typeof date === 'string' ? parseISO(date) : date;
  if (!isValid(parsedDate)) return '';
  
  return format(parsedDate, 'MMM d, yyyy');
};

export const formatDateForInput = (date) => {
  if (!date) return '';
  
  const parsedDate = typeof date === 'string' ? parseISO(date) : date;
  if (!isValid(parsedDate)) return '';
  
  return format(parsedDate, 'yyyy-MM-dd');
};

export const isOverdue = (targetDate) => {
  if (!targetDate) return false;
  
  const parsedDate = typeof targetDate === 'string' ? parseISO(targetDate) : targetDate;
  return isValid(parsedDate) && parsedDate < new Date();
};