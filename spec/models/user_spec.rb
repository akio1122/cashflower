describe User do
  let(:user) { create(:user, email: 'user@example.com') }
  let(:company) { create(:company) }
  subject { user }

  it { is_expected.to be_valid }
  it { should respond_to(:email) }

  it "#email returns a string" do
    expect(user.email).to match 'user@example.com'
  end

  it 'always returns an user_detail' do
    expect(user.user_detail).to be_an_instance_of(UserDetail)
  end

  it 'only send reset password if invitation token nil' do
  end

  describe '#spectator_companies?' do
    let(:user) { create(:user) }

    context 'has spectator companies' do
      let!(:company_role) { create(:company_role, company: company, user: user, role: :spectator) }
      it 'returns true' do
        expect(user.spectator_companies?).to be true
      end
    end

    context 'no spectator companies' do
      it 'returns false' do
        expect(user.spectator_companies?).to be false
      end

    end
  end

  context 'roles' do
    let(:company) { create(:company) }

    it '#roles_instance no roles' do
      expect(user.roles_instance(company)).to be_nil
    end

    it '#roles_instance returns correct roles' do
      user.add_company_role('owner', company, :accepted)
      expect(user.roles_instance(company)).to be_a(CompanyRole)
    end

    it '#add_company_role' do
      user.add_company_role('spectator', company)
      expect(CompanyRole.first.role).to eq('spectator')
    end

    describe '#company_role?' do
      it 'returns false when no role' do
        expect(user.company_role?(:spectator, company)).to be false
      end

      it 'returns false when incorrect role' do
        user.add_company_role('spectator', company)
        expect(user.company_role?('owner', company)).to be false
      end

      it 'returns true when correct role' do
        user.add_company_role('owner', company)
        expect(user.company_role?('owner', company)).to be true
      end
    end

    describe '#company_role_with_any_status?' do
      it 'returns false when no company_roles found' do
        expect(user.company_role_with_any_status?(:owner, company)).to be false
      end

      it 'returns true if invited role found' do
        user.add_company_role(:owner, company, :invited)
        expect(user.company_role_with_any_status?(:owner, company)).to be true
      end
    end

    describe '#add_company_role' do
      it 'creates a new company_role' do
        user.add_company_role(:owner, company)
        expect(CompanyRole.last.user).to eq(user)
        expect(CompanyRole.last.role).to eq('owner')
      end

      it 'updated existing company role' do
        CompanyRole.create(user: user, company: company, role: :spectator)
        user.add_company_role(:owner, company)
        expect(CompanyRole.last.user).to eq(user)
        expect(CompanyRole.last.role).to eq('owner')
      end
    end

    context 'reset password' do
      let(:user) { create(:user, email: 'invitation@email.com') }
      let(:invited_user) { create(:user, invitation_token: 'token') }

      it 'send a reset password to regular user' do
        user.send_reset_password_instructions
        expect(user.reset_password_sent_at).to_not be(nil)
      end

      it 'doesnt send a password reset to invited, non-accepted users' do
        invited_user.send_reset_password_instructions
        expect(user.reset_password_sent_at).to be(nil)
      end
    end
  end
end
