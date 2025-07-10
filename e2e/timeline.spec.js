import { test, expect } from '@playwright/test';

test.describe('Timeline Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:5173/timeline');
  });

  test('displays timeline page with filters', async ({ page }) => {
    await expect(page.locator('h1')).toContainText('Timeline');
    
    // Check filter buttons exist
    await expect(page.locator('button:has-text("All")')).toBeVisible();
    await expect(page.locator('button:has-text("Daily Insights")')).toBeVisible();
    await expect(page.locator('button:has-text("Weekly Summaries")')).toBeVisible();
    await expect(page.locator('button:has-text("Monthly Reviews")')).toBeVisible();
  });

  test('filters timeline by type', async ({ page }) => {
    // Click weekly filter
    await page.click('button:has-text("Weekly Summaries")');
    
    // Weekly button should be active (blue background)
    await expect(page.locator('button:has-text("Weekly Summaries")')).toHaveClass(/bg-blue-500/);
    
    // Click monthly filter
    await page.click('button:has-text("Monthly Reviews")');
    
    // Monthly button should be active
    await expect(page.locator('button:has-text("Monthly Reviews")')).toHaveClass(/bg-blue-500/);
    await expect(page.locator('button:has-text("Weekly Summaries")')).not.toHaveClass(/bg-blue-500/);
  });

  test('displays timeline entries', async ({ page }) => {
    // Check if there are any timeline items
    const timelineItems = page.locator('[class*="rounded-lg border"]');
    const count = await timelineItems.count();
    
    if (count === 0) {
      // Should show empty state
      await expect(page.locator('text=No entries or insights to display yet.')).toBeVisible();
    } else {
      // Should have at least one item visible
      expect(count).toBeGreaterThan(0);
      
      // First item should have a date
      const firstItem = timelineItems.first();
      await expect(firstItem).toBeVisible();
    }
  });

  test('navigation between pages works', async ({ page }) => {
    // Navigate to Goals
    await page.click('a:has-text("Goals")');
    await expect(page).toHaveURL(/\/goals$/);
    
    // Navigate to Check-in
    await page.click('a:has-text("Check-in")');
    await expect(page).toHaveURL(/\/checkin$/);
    
    // Navigate back to Timeline
    await page.click('a:has-text("Timeline")');
    await expect(page).toHaveURL(/\/timeline$/);
  });
});