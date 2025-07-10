import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import goalsService from '../services/goalsService';
import toast from 'react-hot-toast';

export const useGoals = (filters = {}) => {
  return useQuery({
    queryKey: ['goals', filters],
    queryFn: () => goalsService.getGoals(filters),
  });
};

export const useGoal = (id) => {
  return useQuery({
    queryKey: ['goals', id],
    queryFn: () => goalsService.getGoal(id),
    enabled: !!id,
  });
};

export const useCreateGoal = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: goalsService.createGoal,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['goals'] });
      toast.success('Goal created successfully!');
    },
  });
};

export const useUpdateGoal = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ id, data }) => goalsService.updateGoal(id, data),
    onSuccess: (data, variables) => {
      queryClient.invalidateQueries({ queryKey: ['goals'] });
      queryClient.invalidateQueries({ queryKey: ['goals', variables.id] });
      toast.success('Goal updated successfully!');
    },
  });
};

export const useDeleteGoal = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: goalsService.deleteGoal,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['goals'] });
      toast.success('Goal deleted successfully!');
    },
  });
};

export const useCompleteGoal = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: goalsService.completeGoal,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['goals'] });
      toast.success('Goal marked as complete!');
    },
  });
};

export const useArchiveGoal = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: goalsService.archiveGoal,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['goals'] });
      toast.success('Goal archived!');
    },
  });
};