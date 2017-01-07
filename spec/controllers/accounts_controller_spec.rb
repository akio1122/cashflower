RSpec.describe AccountsController do
  let(:company) { create(:company) }
  let(:burnrate) { create(:burnrate, company: company) }

  describe 'GET new' do
    login_user

    it 'assignes an account service object' do
      xhr :get, :new, burnrate_id: burnrate.id, format: :js
      expect(assigns(:account)).to be_kind_of(CreateAccount)
    end
  end

  describe 'POST create' do

  end
end
