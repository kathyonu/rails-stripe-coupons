require 'pry'
include Warden::Test::Helpers
Warden.test_mode!

# Feature: User profile page
#   As a user
#   I want to visit my user profile page
#   So I can see my personal account data
feature 'User profile page', :devise, js: true do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User sees own profile
  #   Given I am signed in
  #   When I visit the user profile page
  #   Then I see my own email address
  scenario 'user sees own profile' do
    user = FactoryGirl.build(:user)
    user.role = 'admin'
    user.save!
    login_as(user, scope: :user)
    visit user_path(user)
    expect(page).to have_content 'User'
    expect(page).to have_content user.email
  end

  # Scenario: User cannot see another user's profile
  #   Given I am signed in
  #   When I visit another user's profile
  #   Then I see an 'access denied' message
  scenario "user cannot see another user's profile" do
    admin_one = FactoryGirl.build(:user)
    admin_one.role = 'admin'
    admin_one.save!
    login_as(admin_one, scope: :admin_one)
    expect(page).to have_content 'Success'

    admin_two = FactoryGirl.build(:user, email: 'other@example.com')
    admin_two.role = 'admin'
    admin_two.save!
    login_as(admin_two, scope: :user)
    expect(admin_one.current_sign_in_ip).to eq "127.0.0.1"
    expect(page).to have_content 'Success'
    visit user_path(admin_one, scope: :admin_two)
    expect(page).to have_content 'Access denied.'    
#    Capybara.current_session.driver.open_new_window  # => ""
 #   current_path
  #  Capybara.current_session.driver.options # => {:browser=>:firefox}

    #response_headers method returns a Hash{String => String}
    # Returns a hash of response headers.
    # Not supported by all drivers (e.g. Selenium)

#    Capybara.current_session.driver.header 'Referer', root_path
 #   Capybara.current_session.driver.header_name 'Referer', root_path
  #  Capybara.current_session.driver.headers 'Referer', root_path

  end

end
