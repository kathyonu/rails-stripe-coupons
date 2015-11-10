require 'stripe_mock'
include Warden::Test::Helpers
Warden.test_mode!
# Feature: Product acquisition
#   As an Admin user
#   I want to download the product and view products list
#   So I can monitor products
feature 'Product acquisition' do
  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Download the product
  #   Given I am a signed in Admin user
  #   Then I should see the Products List and Download button
  #   When I click the 'Download' button
  #   Then I should receive a PDF file
  scenario 'Admin can download the product and view Products List' do
    user = FactoryGirl.build(:user)
    user.role = 'admin'
    user.save!
    login_as(user, scope: :user)
    visit root_path
    expect(page.response_headers['Content-Type']).to have_content 'text/html; charset=utf-8'
    expect(page).to have_content 'User count'
    expect(page).to have_content 'Products list:'
    expect(page).to have_link('Download PDF')

    # a little further admin testing while we are here
    visit user_path(id: '1')
    expect(current_path).to eq '/users/1'
    expect(page).to have_content 'User Email:'
    expect(page).to have_content user.email
    expect(page).to have_link('Download PDF')
    click_link_or_button 'Download PDF'
    expect(page.response_headers['Content-Type']).to have_content 'application/pdf'
  end
end
