include EmailSpec::Helpers
include EmailSpec::Matchers
include ActionDispatch::Routing::UrlFor
# include ActionController::PolymorphicRoutes
include Rails.application.routes.url_helpers

require "rails_helper"
require 'rspec/rails'
#require 'uri'
#require 'email_spec/deliveries'
require 'pry'

RSpec.describe PaymentFailureMailer, type: :mailer do

  default_url_options[:host] = 'example.com'

  before(:all) do

  # valid address must be used for tests to pass.
  # @user = FactoryGirl.create(:user, email: "example@example.com")
  user = FactoryGirl.create(:user, email: "coupons_payment_failure_mailer_spec-rb-28-20150530@goodworksonearth.org")

##
###
#### @email = UserMailer.welcome_email(user).deliver_later
###
##
   #@user = FactoryGirl.create(:user, email: "prelaunch_user_mailer_spec-rb-20-20150425@goodworksonearth.org")
   #@user = FactoryGirl.build(:user, email: "201504211727visitor@goodworksonearth.org")
   #@email = UserMailer.sign_up("example@example.com", "Example Email")
   #@user = FactoryGirl.create(:user, email: "example@example.com")
   #@email = UserMailer.welcome_email(@user).deliver_later
  end

  it "should be set to be delivered to the email passed in" do
    expect(@email).to deliver_to("example@example.com")
#binding.pry
  end

  it "should contain the user's message in the mail body" do
    expect(@email).to have_body_text(/Example Email/)
  end

  it "should contain a link to the confirmation link" do
    expect(@email).to have_body_text(/#{confirm_account_url}/)
  end

  it "should have the correct subject" do
    expect(@email).to have_subject(/Account confirmation/)
  end

  it "should be delivered to the email address provided" do
   #expect(@email).to deliver_to("example@example.com")
   #expect(@email).to deliver_to("201504211727visitor@goodworksonearth.org")
    expect(@email).to deliver_to("coupons_payment_failure_mailer_spec-rb-28-20150530@goodworksonearth.org")
  end

  it "should contain the correct message in the mail body" do
    expect(@email).to have_body_text(/Welcome/)
  end

  it "should have the correct subject" do
    expect(@email).to have_subject(/Request Received/)
  end

end
