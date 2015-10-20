require 'pry'

include Warden::Test::Helpers
Warden.test_mode!

# Feature: Product acquisition
#   As a user
#   I want to download the product
#   So I can complete my acquisition
RSpec.describe 'Product acquisition' do

  after(:each) do
    Warden.test_reset!
  end

  it "redirects to the home page upon save", js: true do 
#binding.pry
    expect(response).to redirect_to root_url 
  end 

  # Scenario: User can download the product
  #   Given I am a signed in user
  #   When I click the 'Download PDF' button
  #   Then I should receive a PDF file
  it 'User can download the product' do
    CreateCouponcodesService.new.call
    #user = FactoryGirl.build(:user)
    user = double(:user, role: 'vip')
    login_as(user, scope: :user)
#binding.pry
    # sign_in(user, scope: :user)
    visit '/'
   #save_and_open_page
    expect(current_path).to eq '/'
#binding.pry
    expect(page).to have_content 'Download the book.'
    # expect(page).to have_selector(a[href$=".pdf"])
    # expect(page).to have_link_or_button("#success")          # user
    expect(page).to have_link_or_button("Download PDF")          # user
    click_button 'Download PDF'
    expect(page.response_headers['Content-Type']).to have_content 'application/pdf'
   end

end
