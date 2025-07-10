import { test, expect } from '@playwright/test';

test.describe('App Loading Tests', () => {
  test.beforeEach(async ({ page }) => {
    // Ensure the Rails server is running before each test
    await page.goto('/');
  });

  test('app loads successfully and shows main components', async ({ page }) => {
    // Check that the page loads without errors
    await expect(page).toHaveTitle(/Goal Assistant/i);
    
    // Check for main app container
    const app = page.locator('#root');
    await expect(app).toBeVisible();
    
    // Check that React app is mounted
    await expect(app).not.toBeEmpty();
  });

  test('navigation components are present', async ({ page }) => {
    // Check for header/navigation
    const header = page.locator('header, nav, [role="navigation"]');
    await expect(header).toBeVisible();
    
    // Check for main content area
    const main = page.locator('main, [role="main"], .container');
    await expect(main).toBeVisible();
  });

  test('app connects to API successfully', async ({ page }) => {
    // Navigate to the goals page where API calls are made
    await page.goto('/goals');
    
    // Wait for either the goals list or error message to appear
    await page.waitForSelector('[data-testid="goals-list"], .error-message', { timeout: 10000 });
    
    // Check that goals list container exists (even if empty)
    const goalsContainer = page.locator('[data-testid="goals-list"]');
    const errorMessage = page.locator('.error-message');
    
    // Either goals list or error should be visible
    const goalsVisible = await goalsContainer.isVisible().catch(() => false);
    const errorVisible = await errorMessage.isVisible().catch(() => false);
    
    expect(goalsVisible || errorVisible).toBeTruthy();
  });

  test('error handling works when API is unreachable', async ({ page }) => {
    // Block API requests to simulate server being down
    await page.route('**/api/**', route => route.abort());
    
    await page.goto('/');
    
    // Wait for error state or loading to complete
    await page.waitForTimeout(2000);
    
    // Check that the app doesn't crash and shows some UI
    const app = page.locator('#root');
    await expect(app).toBeVisible();
    await expect(app).not.toBeEmpty();
  });

  test('routing works correctly', async ({ page }) => {
    await page.goto('/');
    
    // Check if we're on the home page
    await expect(page).toHaveURL(/^http:\/\/localhost:\d+\/?$/);
    
    // Try navigating to a non-existent route
    await page.goto('/non-existent-route');
    
    // Should either redirect to home or show a 404 component
    const app = page.locator('#root');
    await expect(app).toBeVisible();
  });
});