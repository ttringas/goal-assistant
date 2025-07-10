import { test, expect } from '@playwright/test';

test.describe('Check-in Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:5173/checkin');
  });

  test('displays daily check-in form', async ({ page }) => {
    await expect(page.locator('h1')).toContainText('Daily Check-in');
    await expect(page.locator('h2')).toContainText('How did today go?');
  });

  test('shows current date', async ({ page }) => {
    const today = new Date().toLocaleDateString('en-US', { 
      weekday: 'long', 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    });
    await expect(page.locator('text=' + today)).toBeVisible();
  });

  test('allows user to enter and save progress', async ({ page }) => {
    const progressText = 'Made great progress on my goals today!';
    
    // Enter progress
    await page.fill('textarea[placeholder*="Share your progress"]', progressText);
    
    // Save
    await page.click('button:has-text("Save")');
    
    // Should show the saved text
    await expect(page.locator('text=' + progressText)).toBeVisible();
    
    // Should show edit button
    await expect(page.locator('button:has-text("Edit entry")')).toBeVisible();
  });

  test('allows user to edit existing entry', async ({ page }) => {
    // First save an entry
    const initialText = 'Initial progress';
    await page.fill('textarea[placeholder*="Share your progress"]', initialText);
    await page.click('button:has-text("Save")');
    
    // Edit the entry
    await page.click('button:has-text("Edit entry")');
    
    const updatedText = 'Updated progress for today';
    await page.fill('textarea', updatedText);
    await page.click('button:has-text("Save")');
    
    // Should show updated text
    await expect(page.locator('text=' + updatedText)).toBeVisible();
  });

  test('displays AI insight when available', async ({ page }) => {
    // Check if insight section exists (it may or may not have data)
    const insightSection = page.locator('text=Today\'s Insight').first();
    const count = await insightSection.count();
    
    if (count > 0) {
      await expect(insightSection).toBeVisible();
    }
  });
});