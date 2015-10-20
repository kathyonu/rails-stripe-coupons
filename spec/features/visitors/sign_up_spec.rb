require 'stripe_mock'
require 'pry'

include Warden::Test::Helpers
Warden.test_mode!

# Feature: Sign up
#   As a visitor
#   I want to sign up
#   So I can visit protected areas of the site
describe 'Sign Up', :devise, type: :feature, js: true do

  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    CreateCouponcodesService.new.call
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Administrator can verify coupons exist in database
  #   Given there are no coupons existing in the database
  #   When I run tests I can seed the database with coupons
  it 'administrator can verify coupons exist' do
    expect(Coupon.all.count).to eq 3
  end

  # Scenario: Administrator can verify coupons available for use
  #   Given there are three coupons existing in the database
  #   Then I can test their coupon_id attribute usage
  it 'administrator verifies coupon_id is available for system use' do
    first_coupon = Coupon.first
    second_coupon = Coupon.second
    third_coupon = Coupon.third
    expect(first_coupon.id).to eq 1
    expect(second_coupon.id).to eq 2
    expect(third_coupon.id).to eq 3
    expect(first_coupon.code).to eq ""
    expect(second_coupon.code).to eq "FREE"
    expect(third_coupon.code).to eq "HALFOFF"
  end

  # Scenario: Visitor can see the Sign up link in the top nav links
  #   Given I am on the home page
  #   Then I can see the Sign Up link at the top of the page
  it 'visitor can see the Sign up link at top of page' do
    visit root_path 
    expect(page).to have_link("Sign up")
   end

  # Scenario: Administrator can locate every Sign up input field with css or xpath
  #   Given I am on the home page
  #   When I click on Purchase link, the modal form becomes visible
  #   And using the right codes I can locate all of the modal form input fields
 
  it 'visitor on home page is shown sign up modal after pressing Purchase link/button' do
    visit root_path
    expect(current_path).to eq '/'
    expect(page).to have_link("Sign up")
    expect(page).to have_link("Purchase")

    click_link("Purchase")
    expect(current_path).to eq '/'
    expect(page).to have_selector("div.authform")                 # form
    expect(page).to have_selector("div.modal-content")            # modal window
    expect(page).to have_selector("#new_user")                    # form id
    expect(page).to have_selector("#user_email")
    expect(page).to have_selector("#user_password")
    expect(page).to have_selector("#user_password_confirmation")
    expect(page).to have_selector("#card_number")
    expect(page).to have_selector("#card_code")
    expect(page).to have_selector("#date_month")
    expect(page).to have_selector("#date_year")
    expect(page).to have_selector("div.authform #new_user")
    expect(page).to have_selector("div.authform #new_user #user_coupon_attributes_code")
    expect(page).to have_selector("#user_coupon_attributes_code")                                # coupon entry box
    expect(page).to have_selector("div.authform #new_user input#user_coupon_attributes_code")    # coupon entry box
    expect(page).to have_content("Coupon code")                                                  # coupon code entry
 end

  # Scenario: Visitor presses the Purchase link/button and signs up
  #   When I click Purchase link/button the modal form becomes available
  #   Then I sign up with my email, password, credit card, and coupon information
  it 'visitor can see and click on the Purchase link/button' do
    CreateCouponcodesService.new.call
    visit root_path
    expect(page).to have_link("Purchase")
    expect(click_on("Purchase")).to eq 'ok'
  end

  # Scenario: Visitor can sign up with valid email address and password, with no coupon
  #   Given I am not signed in
  #   When I sign up with a valid email address and password, and no coupon
  #   Then I see a successful sign up message
  it 'visitor can sign up on home page using Sign up button' do
    StripeMock.start
    visit new_user_registration_path
    click_link("Sign up")
    card_token = StripeMock.generate_card_token(card_number: '4242424242424242', exp_month: 2, exp_year: 2022) # => 'test_tok_1'
    sign_up_with('valid@example.com', 'please123', 'please123', '', card_token)
    txts = [I18n.t( 'devise.registrations.signed_up'), I18n.t( 'devise.registrations.signed_up_but_unconfirmed')]
    expect(page).to have_content(/.*#{txts[0]}.*|.*#{txts[1]}.*/)
    StripeMock.stop
  end


=begin
  # Scenario: Visitor can sign up with valid email address and password, and FREE coupon
  #   Given I am not signed in
  #   When I sign up with a valid email address and password, and no coupon
  #   Then I see a successful sign up message
  it 'visitor can sign up on home page using Sign up button' do
    user = FactoryGirl.build(:user, email: 'valid@example.com')
#binding.pry
#   visit new_user_registration_path
#    visit new_user_registration_path(code: 'FREE')
    visit '/'
    expect(page).to have_selector("div.modal-content")
    expect(page).to have_selector("#new_user")
    expect(page).to have_selector("#user_coupon_attributes_code")
    sign_up_with('valid@example.com', 'please123', 'please123')
    txts = [I18n.t( 'devise.registrations.signed_up'), I18n.t( 'devise.registrations.signed_up_but_unconfirmed')]
    expect(page).to have_content(/.*#{txts[0]}.*|.*#{txts[1]}.*/)
  end






  # Scenario: Visitor can sign up with valid email address and password, with no coupon
  #   Given I am not signed in
  #   When I sign up with a valid email address and password, and no coupon
  #   Then I see a successful sign up message
  it 'visitor can sign up with valid email address, password, and FREE coupon code' do
    CreateCouponcodesService.new.call
    user = FactoryGirl.build(:user, email: 'valid@example.com', coupon_id: 'FREE')
#binding.pry
#   visit new_user_registration_path
#    visit new_user_registration_path(code: 'FREE')
    visit '/'
    expect(page).to have_selector("div.modal-content")
    expect(page).to have_selector("#new_user")
    expect(page).to have_selector("#user_coupon_attributes_code")
    sign_up_with('valid@example.com', 'please123', 'please123', 1)
    txts = [I18n.t( 'devise.registrations.signed_up'), I18n.t( 'devise.registrations.signed_up_but_unconfirmed')]
    expect(page).to have_content(/.*#{txts[0]}.*|.*#{txts[1]}.*/)
  end




  it 'visitor can sign up with valid coupon' do
##### And I can know the coupon_id can be entered in visitor test sign up
    CreateCouponcodesService.new.call
    
  end












 # Scenario: Administrator can locate every input field with css or xpath
  #   Given I am on the home page
  #   When I click on Sign up link the modal form becomes visible
  #   When I fill in the modal form input fields
  #   And I press the modal submit button
  #   Then I know the Coupon code entry is available in the modal sign up form
  it 'visitor can see the Coupon code input entry box' do
    CreateCouponcodesService.new.call
   #visit new_user_registration_path # 20150528 this is needing to be further tested
    visit root_path                        # 20150528 which is right, and which is illusion
    expect(page).to have_link("Sign up")
    expect(page).to have_selector("div.modal-content")            # modal window
    expect(page).to have_selector("#new_user")                    # form id
    expect(page).to have_selector("#user_coupon_attributes_code") # coupon entry box
  end





=end


# Scenario: Visitor can sign up with valid email address and password, and a coupon code
  #   Given I am not signed in
  #   When I sign up with a valid email address and password, and coupon code
  #   Then I see a successful sign up message
  it 'visitor can sign up with valid email address, password and coupon code' do
    StripeMock.start
    visit new_user_registration_path
    card_token = StripeMock.generate_card_token(card_number: '4242424242424242', exp_month: 2, exp_year: 2022) # => 'test_tok_1'
    sign_up_with('test@example.com', 'please123', 'please123', 'HALFOFF')
    txts = [I18n.t( 'devise.registrations.signed_up'), I18n.t( 'devise.registrations.signed_up_but_unconfirmed')]
    expect(page).to have_content(/.*#{txts[0]}.*|.*#{txts[1]}.*/)
    StripeMock.stop
  end

  # Scenario: Visitor cannot sign up with invalid email address
  #   Given I am not signed in
  #   When I sign up with an invalid email address
  #   Then I see an invalid email message
  it 'visitor cannot sign up with invalid email address' do
    visit new_user_registration_path
    sign_up_with('bogus', 'please123', 'please123', '', '')
    page.accept_alert('Please enter an email address')
   #expect(page).to have_content 'Email is invalid'
#    page.script.accept_alert('Please enter an email address')
#    expect(page).to have_content 'Please enter an email address'
#    save_and_open_page
  end

  # Scenario: Visitor cannot sign up without password
  #   Given I am not signed in
  #   When I sign up without a password
  #   Then I see a missing password message
  it 'visitor cannot sign up without password' do
    visit root_path
    click_link("Purchase")
    sign_up_with('nopassword@example.com', '', '', '', '')
    expect(page).to have_content "Password can't be blank"
  end

  # Scenario: Visitor cannot sign up with a short password
  #   Given I am not signed in
  #   When I sign up with a short password
  #   Then I see a 'too short password' message
  it 'visitor cannot sign up with a short password' do
    visit root_path
    click_link("Purchase")
    sign_up_with('shortpassword@example.com', 'please', 'please', '', '')
    expect(page).to have_content "Password is too short"
  end

  # Scenario: Visitor cannot sign up without password confirmation
  #   Given I am not signed in
  #   When I sign up without a password confirmation
  #   Then I see a missing password confirmation message
  it 'visitor cannot sign up without password confirmation' do
    visit root_path
    click_link("Purchase")
    sign_up_with('nopasswordconfimation@example.com', 'please123', '', '', '')
    expect(page).to have_content "Password confirmation doesn't match"
  end

  # Scenario: Visitor cannot sign up with mismatched password and confirmation
  #   Given I am not signed in
  #   When I sign up with a mismatched password confirmation
  #   Then I should see a mismatched password message
  it 'visitor cannot sign up with mismatched password and confirmation' do
    visit root_path
    click_link("Purchase")
    sign_up_with('mismatch@example.com', 'please123', 'mismatch', '', '')
    expect(page).to have_content "Password confirmation doesn't match"
  end

end
