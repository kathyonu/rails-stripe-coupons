include Warden::Test::Helpers
Warden.test_mode!
 
describe UsersController do

  after(:each) do
    Warden.test_reset!
  end

  describe "GET #index" do

    it "renders the :index view for Admin" do
      admin = FactoryGirl.create(:user, role: 'admin')
      sign_in(admin)
      get :index
      expect(response).to render_template :index
    end

    it "renders the :index view for User" do
      user = FactoryGirl.create(:user, email: 'newuser@example.com')
      sign_in(user)
      get :index
      expect(response).to render_template :index
    end

    it "populates an array of users" do 
      admin = FactoryGirl.create(:user, role: 'admin')
      sign_in(admin)
      get :index
      expect(assigns(:users)).to eq([admin]) 
    end
  end
end
