require 'rails_helper'

RSpec.describe 'Authentication E2E Flow', type: :system do
  # Clean up test user after each test
  after do
    User.where(email: 'e2e_test@example.com').destroy_all
  end

  it 'allows user to register, login, and access protected pages' do
    # 1. Test Registration
    visit '/register'
    
    fill_in 'Email address', with: 'e2e_test@example.com'
    fill_in 'Password', with: 'password123'
    fill_in 'Confirm Password', with: 'password123'
    
    click_button 'Create account'
    
    # Should redirect to dashboard
    expect(page).to have_current_path('/dashboard')
    expect(page).to have_content('Dashboard')
    
    # 2. Test Logout
    find('button[title="Logout"]').click
    
    # Should redirect to login
    expect(page).to have_current_path('/login')
    
    # 3. Test Login
    fill_in 'Email address', with: 'e2e_test@example.com'
    fill_in 'Password', with: 'password123'
    
    click_button 'Sign in'
    
    # Should redirect to dashboard
    expect(page).to have_current_path('/dashboard')
    
    # 4. Test Access to Protected Routes
    visit '/goals'
    expect(page).to have_content('Goals')
    expect(page).not_to have_current_path('/login')
    
    visit '/checkin'
    expect(page).to have_content('Daily Check-in')
    expect(page).not_to have_current_path('/login')
    
    visit '/timeline'
    expect(page).to have_content('Timeline')
    expect(page).not_to have_current_path('/login')
    
    # 5. Test Profile and API Keys
    visit '/profile'
    expect(page).to have_content('Profile Settings')
    expect(page).to have_content('e2e_test@example.com')
    
    # Add API keys
    click_button 'Add API Keys'
    
    fill_in 'Anthropic API Key', with: 'sk-ant-test-key'
    fill_in 'OpenAI API Key', with: 'sk-test-key'
    
    click_button 'Save API Keys'
    
    # Check for success
    expect(page).to have_content('API keys updated successfully!')
    expect(page).to have_content('Custom keys active')
  end

  it 'prevents access to protected routes when not logged in' do
    # Try to access protected routes
    visit '/dashboard'
    expect(page).to have_current_path('/login')
    
    visit '/goals'
    expect(page).to have_current_path('/login')
    
    visit '/checkin'
    expect(page).to have_current_path('/login')
    
    visit '/timeline'
    expect(page).to have_current_path('/login')
    
    visit '/profile'
    expect(page).to have_current_path('/login')
  end

  it 'shows validation errors for invalid registration' do
    visit '/register'
    
    # Try to register with invalid data
    fill_in 'Email address', with: 'invalid-email'
    fill_in 'Password', with: 'short'
    fill_in 'Confirm Password', with: 'different'
    
    click_button 'Create account'
    
    # Should show error messages
    expect(page).to have_content('Passwords do not match')
  end

  it 'shows error for invalid login credentials' do
    # Create a user first
    User.create!(
      email: 'existing@example.com',
      password: 'correctpassword'
    )
    
    visit '/login'
    
    fill_in 'Email address', with: 'existing@example.com'
    fill_in 'Password', with: 'wrongpassword'
    
    click_button 'Sign in'
    
    # Should show error message
    expect(page).to have_content('Invalid Email or password')
  end
end