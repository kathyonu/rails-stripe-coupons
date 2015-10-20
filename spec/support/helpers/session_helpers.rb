module Features
  module SessionHelpers
    def sign_up_with(email, password, password_confirmation, coupon_code, card_token)
      if current_path == root_path
        fill_in 'Email', with: email
        fill_in 'user_password', with: password
        fill_in 'user_password_confirmation', with: password_confirmation
        fill_in 'card_number', with: '4242424242424242'
        fill_in 'card_code', with: '123'
        select 12, from: 'date_month'
        select 2025, from: 'date_year'
        fill_in "user_coupon_attributes_code", with: coupon_code
        click_button 'Sign up'
      elsif
        current_path == new_user_registration_path
        fill_in 'Email', with: email
        fill_in 'user_password', with: password
        fill_in 'user_password_confirmation', with: password_confirmation
        fill_in 'card_number', with: '4242424242424242'
        fill_in 'card_code', with: '123'
        select 12, from: 'date_month'
        select 2025, from: 'date_year'
        fill_in "user_coupon_attributes_code", with: coupon_code
        click_button 'Sign up'
      end
    end

    def signin(email, password)
      visit new_user_session_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end
  end
end
