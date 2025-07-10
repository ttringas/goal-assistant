require 'rails_helper'

RSpec.describe 'Registration Error Display', type: :system do
  before do
    # Create an existing user
    User.create!(
      email: 'existing@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  it 'displays specific validation error when email is already taken' do
    visit '/register'
    
    fill_in 'Email address', with: 'existing@example.com'
    fill_in 'Password', with: 'password123'
    fill_in 'Confirm Password', with: 'password123'
    
    click_button 'Create account'
    
    # Should show the specific error message, not generic "Registration failed"
    expect(page).to have_content("User couldn't be created successfully. Email has already been taken")
  end

  it 'displays password mismatch error' do
    visit '/register'
    
    fill_in 'Email address', with: 'newuser@example.com'
    fill_in 'Password', with: 'password123'
    fill_in 'Confirm Password', with: 'differentpassword'
    
    click_button 'Create account'
    
    # Frontend validation should catch this
    expect(page).to have_content('Passwords do not match')
  end

  it 'displays password too short error' do
    visit '/register'
    
    fill_in 'Email address', with: 'newuser@example.com'
    fill_in 'Password', with: 'short'
    fill_in 'Confirm Password', with: 'short'
    
    click_button 'Create account'
    
    # Frontend validation should catch this
    expect(page).to have_content('Password must be at least 6 characters')
  end
end