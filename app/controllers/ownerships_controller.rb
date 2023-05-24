# frozen_string_literal: true

# Controller for Ownership interface
class OwnershipsController < ApplicationController
  before_action :admin?

  def index
    @datatables = Datatable.by_name
  end

  def show
    @datatable = datatable(params) if params[:id]
    # @datatable = Datatable.find_by(id: params[:datatable]) if params[:datatable]
    return if @datatable

    flash[:notice] = 'You must select a valid datatable to grant ownerships'
    redirect_to action: :index
    false
  end

  def new
    @datatable = datatable if params[:datatable]
    @datatables = Datatable.by_name unless @datatable
    @users = User.by_email
    @ownership = Ownership.new
    @user_count = 1
    @datatable_count = 1 unless @datatable
  end

  def create
    users = params[:users]
    @datatable = datatable if params[:datatable]
    overwrite = @datatable.present?
    datatables = @datatable ? [@datatable.id] : params[:datatables]
    if users.present? && datatables.present?
      Ownership.create_ownerships(users, datatables, overwrite)
      if @datatable
        redirect_to ownership_path(id: @datatable.id)
      else
        redirect_to ownerships_path
      end
    else
      new_ownership_form
    end
  end

  def revoke
    user = User.find(params[:user])
    datatable = Datatable.find(params[:datatable])
    ownerships = Ownership.where(user_id: user, datatable_id: datatable)
    ownerships.each(&:destroy)

    respond_to do |format|
      flash[:notice] = "Ownership has been revoked from #{user.email}"
      format.html { redirect_to ownership_path(datatable) }
      format.xml { head :ok }
    end
  end

  private

  def datatable(params)
    @datatable = Datatable.find(params[:id])
  end

  def new_ownership_form
    @datatables = Datatable.by_name unless @datatable
    @users = User.by_email
    @ownership = Ownership.new
    @user_count = 1
    @datatable_count = 1 unless @datatable
    render 'new'
  end
end
