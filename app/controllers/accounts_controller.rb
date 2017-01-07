class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_burnrate

  def new
    @account = CreateAccount.new
  end

  def create
    # authorize @burnrate.source
    outcome = CreateAccount.run(params[:account].merge(burnrate: @burnrate.source))
    if outcome.valid?
      @burnrate = outcome.result.decorate
      flash[:notice] = "#{outcome.title} account created"
      render 'shared/dashboard_update'
    else
      @account = outcome
      render :new
    end
  end

  def edit
    @account = Account.find(params[:id])
    # authorize @account
  end

  def update
    @account = Account.find(params[:id])
    # authorize @account
    if @account.update(account_params)
      @burnrate.reload
      flash[:notice] = "#{@account.title} account updated"
      render 'shared/dashboard_update' unless params[:refresh].present? && params[:refresh]
    else
      render :new
    end
  end

  def destroy
    @account = Account.find(params[:id]).decorate
    # authorize @account
    @account.destroy
    @burnrate.update_balance
    @burnrate.update_net_burn
    @burnrate.reload
    flash[:notice] = "#{@account.title} account deleted. #{@account.undo_link}"
    render 'shared/dashboard_update'
  end

  def undo_delete
    account = Account.restore(params[:id], recursive: true).try(:first)
    if account
      @burnrate.update_balance
      @burnrate.update_net_burn
      @burnrate.touch
      @burnrate.reload
      flash[:notice] = "#{account.title} restored"
      render 'shared/dashboard_update'
    else
      flash[:notice] = "Unable to restore #{account.title}"
    end
  end

  protected

  def account_params
    params.require(:account).permit(:title, :sub_type_of, :visible_for_spectator, :position)
  end
end
