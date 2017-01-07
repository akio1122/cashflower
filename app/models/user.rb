class User < ActiveRecord::Base
  extend Enumerize

  # Required for customizing invitation_instructions
  attr_reader :raw_invitation_token

  has_one :user_detail, dependent: :destroy

  has_many :company_notifications, through: :companies, source: :notifications
  has_many :portfolio_notifications, through: :portfolios, source: :notifications

  has_many :company_roles
  has_many :companies, -> { order(name: :asc) }, through: :company_roles

  has_many :portfolios, -> { order(name: :asc) }
  has_many :portfolio_companies, through: :portfolios, source: :companies

  accepts_nested_attributes_for :companies, :user_detail

  delegate :first_name, :last_name, :phone, :company_name, to: :user_detail

  validates :email, presence: true

  enumerize :status, in: { invited: 0, active: 1, inactive: 2 }, predicates: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :confirmable, :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Own companies (owner)
  def owned_companies
    companies.where(company_roles: { role: 0, status: 1 })
  end

  # Spectator companies not beloging to a user portfolio.
  # TODO Replace with a new join model? User/Portfolio - Company
  def other_companies
    companies
      .includes(:active_burnrate)
      .where(company_roles: { role: 1, status: 1 })
      .where.not(id: portfolio_companies.ids)
  end

  def user_detail
    super || build_user_detail
  end

  # Don't send reset password if invitation is pending
  def send_reset_password_instructions
    super if invitation_token.nil?
  end

  # Workaround to find roles for user/instance
  def roles_instance(company)
    company_roles.find_by(user: self, company: company)
  end

  # Create a User - Company relationship CompanyRole
  def add_company_role(role, company, status = 'accepted')
    company_role = CompanyRole.find_or_create_by(company: company, user: self)
    company_role.update(status: status, role: role)
    company_role
  end

  # Check User - Company relationship (active)
  def company_role?(role, company)
    company_roles.with_role(role).where(company: company, status: 1).exists?
  end

  # Check User - Company relationship
  def company_role_with_any_status?(role, company)
    company_roles.with_role(role).where(company: company).exists?
  end

  # Monkey patch Devise confirm method
  # Setup initial portfolio and permissions
  def confirm
    # Change user status to active
    update(status: :active)
    # Update all pending company_roles to active
    company_roles.update_all(status: 1)
    NotifyMailer.welcome_mail(self).deliver_later
    super
  end

  def spectator_companies?
    company_roles.with_role(:spectator).exists?
  end
end
