require 'stripe_mock'
include Warden::Test::Helpers
Warden.test_mode!

# Feature: Product acquisition
#   As a user
#   I want to download the product
#   So I can complete my acquisition
feature 'Product acquisition' do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Download the product
  #   Given I am a user
  #   When I click the 'Download' button
  #   Then I should receive a PDF file
  scenario 'Admin can download the product and view Products List' do
    CreateCouponcodesService.new.call
    user = FactoryGirl.create(:user)
    login_as(user, scope: :user)
    visit root_path
    expect(page.response_headers['Content-Type']).to have_content 'text/html; charset=utf-8'
    expect(page).to have_content 'User count'
    expect(page).to have_content 'Products list:'
    expect(page).to have_link('Download PDF')

    # a little further admin testing while we are here
    visit user_path({ id: '1' })
    expect(current_path).to eq '/users/1'
    expect(page).to have_content 'User Email:'
    expect(page).to have_content user.email
    expect(page).to have_link('Download PDF')
    click_link_or_button 'Download PDF'
    expect(page.response_headers['Content-Type']).to have_content 'application/pdf'
  end

  # Scenario: User can download the product using a coupon
  #   Given I am a signed in user with a coupon
  #   When I click the 'Download PDF' button
  #   Then I should receive a PDF file
  scenario 'User can download the product using coupon' do
    CreateCouponcodesService.new.call

    stripe_helper = StripeMock.create_test_helper

    card_token = stripe_helper.generate_card_token
    expect(card_token).to match(/^tok_/)

    user = FactoryGirl.build(:user, email: 'new@example.com')
    user.role = 0
    user.coupon_id = 3
    user.save # Given I am a user is now valid

    customer = Stripe::Customer.create(email: 'new@example.com')
    expect(customer.email).to eq 'new@example.com'

    charge = Stripe::Charge.create(
      amount: 995,
      currency: 'usd',
      source: card_token,
      description: 'new charge'
      )
    customer = Stripe::Customer.retrieve(customer.id)
    expect(customer.id).to match(/^cus_/)
    user.role = 1
    user.coupon_id = 3
    # user.save
    expect(user.role).to eq 'vip'

    login_as(user, scope: :user)
    visit root_path
    expect(current_path).to eq '/'
    expect(page).to have_content 'Download the book'

    click_link_or_button('Download PDF')
    expect(page.response_headers['Content-Type']).to have_content 'application/pdf'
   end
end
