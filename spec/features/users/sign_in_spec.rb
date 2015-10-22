require 'pry'
require 'stripe_mock'
# Feature: Sign in
#   As a user
#   I want to sign in
#   So I can visit protected areas of the site
feature 'Sign in', :devise, live: true do
  # setup do
  #  @request.env['HTTP_REFERER'] = 'http://localhost:3000/sessions/new'
  #  post :create, { :user => { :email => 'invalid@abc' } }, {}
  # end

  before(:each) do
    StripeMock.start
    FactoryGirl.reload
    # @request.env["HTTP_REFERER"] = "where_i_came_from" unless @request.nil?
    # @request.env['HTTP_REFERER'] = '/' unless @request.nil?
    # env['HTTP_REFERER'] = '/' unless @request.nil?
    # env['HTTP_REFERER'] = '/'
    
    # @request.env will not work for integration tests because the @request variable doesn't exist.
    # According to RailsGuides, you can pass headers to the helpers in this manner:
    # test "blah" do
    #   get root_path, {}, {'HTTP_REFERER' => 'http://foo.com'}
    #   ...
    # end
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  # Scenario: User can sign in with valid credentials
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  scenario 'user can sign in with valid credentials' do
    stripe_helper = StripeMock.create_test_helper

    # plan = stripe_helper.create_plan(id: 'gold', amount: 1900)
    # expect(plan.id).to eq 'gold'

    # Stripe::Plan.retrieve(plan.id)
    # expect(plan.amount).to eq 1900

    card_token = StripeMock.generate_card_token(number: '4242424242424242', exp_month: 9, exp_year: 2016)
    customer = Stripe::Customer.create(
      email: 'test@example.com',
      source: card_token,
      description: 'a customer description'
    )
    charge = Stripe::Charge.create({
      amount: 1900,
      currency: 'usd',
      customer: customer.id,
      description: 'Charge for test@example.com'
    }, {
      idempotency_key: '95ea4310438306ch'
    })
    customer = Stripe::Customer.retrieve(customer.id)
    user = FactoryGirl.create(:user, email: 'test@example.com')
    user.stripe_token = card_token
    user.save!

    # be aware, user.role freezes the user hash, so must be assigned last before save
    user.role = 1
    user.save!

    visit '/users/sign_in'
    expect(current_path).to eq '/users/sign_in'

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'please123'
    click_link_or_button 'Sign in'
    expect(current_path).to eq '/'
    expect(page).to have_content 'Signed in successfully.'
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
  end

  # from kathy_onu_forks/new_devise
  # Scenario: User can sign in with valid credentials
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  scenario 'can sign in with valid credentials' do
    stripe_helper = StripeMock.create_test_helper

    # plan = stripe_helper.create_plan(id: 'gold', amount: 1900)
    # expect(plan.id).to eq 'gold'

    # Stripe::Plan.retrieve(plan.id)
    # expect(plan.amount).to eq 1900

    card_token = StripeMock.generate_card_token(
      number: '4242424242424242',
      exp_month: 9,
      exp_year: 2016
    )
    stripe_token = card_token.to_s
    customer = Stripe::Customer.create(
      email: 'test@example.com',
      source: card_token,
      description: 'a customer description'
    )
    charge = Stripe::Charge.create({
      amount: 1900,
      currency: 'usd',
      # interval: 'month',
      customer: customer.id,
      description: 'Charge for test@example.com'
    }, {
      idempotency_key: '95ea4310438306ch'
    })
    customer = Stripe::Customer.retrieve(customer.id)
    user = FactoryGirl.build(:user, email: 'test@example.com')
    user.stripe_token = stripe_token
    user.save!

    user.role = 1
    user.save!
    expect(user.role).to eq 'vip'

    visit '/users/sign_in'
    expect(current_path).to eq '/users/sign_in'

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'please123'
    click_link_or_button 'Sign in'
    expect(current_path).to eq '/'
    expect(page).to have_content 'Signed in successfully.'
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
  end

  scenario 'signed in user cannot visit /users/index page' do
    stripe_helper = StripeMock.create_test_helper

    card_token = StripeMock.generate_card_token(
      number: '4242424242424242',
      exp_month: 9,
      exp_year: 2016
    )
    stripe_token = card_token.to_s

    customer = Stripe::Customer.create(
      email: 'test@example.com',
      source: card_token,
      description: 'a customer description'
    )
    charge = Stripe::Charge.create({
      amount: 1900,
      currency: 'usd',
      customer: customer.id,
      description: 'Charge for test@example.com'
    }, {
      idempotency_key: '95ea4310438306ch'
    })
    customer = Stripe::Customer.retrieve(customer.id)
    user = FactoryGirl.build(:user, email: 'test@example.com')
    user.stripe_token = stripe_token
    user.save!

    # be aware, user.role freezes the user hash, so must be assigned after user save
    user.role = 1
    user.save!
    expect(user.role).to eq 'vip'

    visit '/users/sign_in'
    expect(current_path).to eq '/users/sign_in'

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'please123'
    click_link_or_button 'Sign in'
    expect(current_path).to eq '/'
    expect(page).to have_content 'Signed in successfully.'
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'

    # visit '/users'
    # expect(response).to redirect_to 'where_i_came_from'
    visit users_path, {}, {'HTTP_REFERER' => 'http://test.com/session/new'}
    expect(page).to have_content('This page is restricted to administrators')
    expect(current_path).not_to eq '/users'
    expect(current_path).to eq '/home'
  end

  # Scenario: User cannot sign in if not registered
  #   Given I do not exist as a user
  #   When I sign in with valid credentials
  #   Then I see an invalid credentials message
  scenario 'user cannot sign in if not registered' do # pass
    sign_in('unknown@example.com', 'changeme')
    expect(current_path).to eq '/users/sign_in'
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.invalid', authentication_keys: 'email'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  # Scenario: User cannot sign in with wrong email
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong email
  #   Then I see an invalid email message
  scenario 'user cannot sign in with wrong email' do # pass
    user = FactoryGirl.build(:user)
    user.role = 'admin'
    user.save!
    sign_in('invalid@email.com', user.password)
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.invalid', authentication_keys: 'email'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  # Scenario: User cannot sign in with wrong password
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong password
  #   Then I see an invalid password message
  scenario 'user cannot sign in with wrong password' do # pass
    user = FactoryGirl.build(:user)
    user.role = 'admin'
    user.save!
    visit new_user_session_path
    sign_in(user.email, 'invalidpass')
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.invalid', authentication_keys: 'email'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  scenario 'signed in user cannot sign in twice' do
    card_token = StripeMock.generate_card_token(
      number: '4242424242424242',
      exp_month: 10,
      exp_year: 2020
    )
    stripe_token = card_token.to_s
    customer = Stripe::Customer.create(
      email: 'chargeitem@example.com',
      description: 'customer creation with card token'
    )
    charge = Stripe::Charge.create({
      amount: 900,
      currency: 'usd',
      source: card_token,
      description: 'a charge with a specific card'
    }, {
      idempotency_key: '95ea4310438306ch'
    })
    expect(charge.id).to match(/^test_ch/)
    expect(charge.source.object).to eq 'card'
    # expect(charge.source.last4).to eq '4242'
    expect(charge.source.brand).to eq 'Visa'
    # TODO: next test (commented out) is a stripe-ruby-mock bug : 20150828
    # our card_token expires on 10, yet the test fails because
    # stripe-ruby-mock is blindkly grabbing is own charge data,
    # not the charge's customer.id's source, the card_token
    # expect(charge.source.exp_month).to eq 10

    # the data for this next hacked-test is from
    # lib/stripe_mock/data.rb self.mock_charge
    expect(charge.source.exp_month).to eq 10
    expect(charge.source.exp_year).to eq 2020
    expect(charge.source.name).to eq 'Johnny App'
    expect(charge.source.cvc_check).to eq nil
    expect(charge.description).to eq 'a charge with a specific card'
    user = FactoryGirl.build(:user, email: 'chargeitem@example.com')
    user.stripe_token = 'test_tok_1'
    user.save!
    # be aware, user.role freezes the user hash, so must be assigned after user is persisted/saved
    user.role = 1
    user.save!
    # expect(customer.id).to eq @user.customer_id
    # expect(@user.customer_id).to match(/^test_cus/)

    visit '/users/sign_in'
    expect(current_path).to eq '/users/sign_in'

    fill_in 'Email', with: 'chargeit@example.com'
    fill_in 'Password', with: 'please123'
    click_link_or_button 'Sign in'
    expect(current_path).to eq '/'

    # visit new_user_session_path
    # sign_in(user.email, user.password)
    expect(current_path).to eq '/'
    expect(page).to have_content 'Signed in successfully.'

    visit '/users/sign_in'
    expect(current_path).to eq '/'
    expect(page).to have_content 'You are already signed in.'
    expect(page).to have_content I18n.t 'devise.failure.already_authenticated', authentication_keys: 'email'
  end
end
