class OwnershipsController < ApplicationController

  before_filter :admin? unless Rails.env == 'development'

  def index
    @datatables = Datatable.by_name
  end

  def show
    get_datatable
  end

  def new
    @datatable = Datatable.find(params[:datatable]) if params[:datatable]
    @datatables = Datatable.by_name unless @datatable
    @users = User.by_email
    @ownership = Ownership.new
    @user_count = 1
    @datatable_count = 1 unless @datatable
  end

  def create
    users = params[:users]
    @datatable = Datatable.find(params[:datatable]) if params[:datatable]
    datatables = @datatable ? [@datatable.id] : params[:datatables]
    if users.present? && datatables.present?
      Ownership.create_ownerships(users, datatables)
      redirect_to ownerships_path
    else
      render 'new'
    end
  end

  def revoke
    user = User.find(params[:user])
    datatable = Datatable.find(params[:datatable])
    ownerships = Ownership.find_all_by_user_id_and_datatable_id(user, datatable)
    ownerships.each do |ownership|
      ownership.destroy
    end

    respond_to do |format|
      flash[:notice] = 'Ownership has been revoked from ' + user.email
      format.html { redirect_to ownership_path(datatable) }
      format.xml  { head :ok }
    end
  end

  private

  def get_datatable
    @datatable = Datatable.find_by_id(params[:id]) if params[:id]
    @datatable = Datatable.find_by_id(params[:datatable]) if params[:datatable]
    unless @datatable
      flash[:notice] = "You must select a valid datatable to grant ownerships"
      redirect_to :action => :index
      return false
    end
  end
end
