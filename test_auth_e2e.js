const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({ 
    headless: false,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  const page = await browser.newPage();
  
  try {
    console.log('Starting E2E authentication test...');
    
    // Test registration flow
    console.log('\n1. Testing registration...');
    await page.goto('http://localhost:5173/register');
    
    // Fill registration form
    await page.type('input[name="email"]', 'testuser@example.com');
    await page.type('input[name="password"]', 'password123');
    await page.type('input[name="password-confirmation"]', 'password123');
    
    // Submit form
    await page.click('button[type="submit"]');
    
    // Wait for navigation to dashboard
    await page.waitForNavigation();
    console.log('✓ Registration successful, redirected to:', page.url());
    
    // Verify we're on the dashboard
    await page.waitForSelector('h1');
    const pageTitle = await page.$eval('h1', el => el.textContent);
    console.log('✓ Page title:', pageTitle);
    
    // Test logout
    console.log('\n2. Testing logout...');
    await page.click('button[title="Logout"]');
    await page.waitForNavigation();
    console.log('✓ Logged out, redirected to:', page.url());
    
    // Test login flow
    console.log('\n3. Testing login...');
    await page.goto('http://localhost:5173/login');
    
    // Fill login form
    await page.type('input[name="email"]', 'testuser@example.com');
    await page.type('input[name="password"]', 'password123');
    
    // Submit form
    await page.click('button[type="submit"]');
    
    // Wait for navigation to dashboard
    await page.waitForNavigation();
    console.log('✓ Login successful, redirected to:', page.url());
    
    // Test protected route access
    console.log('\n4. Testing protected routes...');
    await page.goto('http://localhost:5173/goals');
    await page.waitForSelector('.goal-list, .empty-state');
    console.log('✓ Can access goals page');
    
    await page.goto('http://localhost:5173/checkin');
    await page.waitForSelector('textarea');
    console.log('✓ Can access check-in page');
    
    await page.goto('http://localhost:5173/timeline');
    await page.waitForSelector('h1');
    console.log('✓ Can access timeline page');
    
    // Test profile and API keys
    console.log('\n5. Testing profile and API keys...');
    await page.goto('http://localhost:5173/profile');
    await page.waitForSelector('h1');
    
    // Add API keys
    await page.click('button:has-text("Add API Keys")');
    await page.type('input[id="anthropic-key"]', 'sk-ant-test-key');
    await page.type('input[id="openai-key"]', 'sk-test-key');
    await page.click('button:has-text("Save API Keys")');
    
    // Wait for success message
    await page.waitForSelector('.bg-green-50');
    console.log('✓ API keys saved successfully');
    
    console.log('\n✅ All E2E authentication tests passed!');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    await page.screenshot({ path: 'error-screenshot.png' });
    console.log('Screenshot saved as error-screenshot.png');
  } finally {
    await browser.close();
  }
})();