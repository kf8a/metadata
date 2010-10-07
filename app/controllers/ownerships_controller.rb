class OwnershipsController < ApplicationController

  layout :site_layout
  
  before_filter :admin? unless ENV["RAILS_ENV"] == 'development'

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
  
  def add_another_user
    @users = User.all
    @user_count = params['user_count'].to_i
    @user_count += 1
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.insert_html :bottom, 'user_boxes', 
            :partial  => "userbox",
            :locals   => {:users => @users, :user_count => @user_count}
          
          page.replace_html 'user_counter', 
            :partial => "usercounter", 
            :locals => {:user_count => @user_count}
        end
      end
    end
  end
  
  def add_another_datatable
    @datatables = Datatable.all
    @datatable_count = params['datatable_count'].to_i
    @datatable_count += 1
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.insert_html :bottom, 'datatable_boxes', 
            :partial  => "datatablebox",
            :locals   => {:datatables => @datatables, :datatable_count => @datatable_count}
          
          page.replace_html 'datatable_counter', 
            :partial => "datatablecounter", 
            :locals => {:datatable_count => @datatable_count}
        end
      end
    end
  end

  def create
    users = []
    user_count = params[:user_count].to_i
    user_count.times do |count|
      user_number = count + 1
      user_name = "user_" + user_number.to_s
      user = User.find(params[user_name])
      users << user
    end
    @datatable = Datatable.find(params[:datatable]) if params[:datatable]
    unless @datatable
      datatables = []
      datatable_count = params[:datatable_count].to_i
      datatable_count.times do |count|
        datatable_number = count + 1
        datatable_name = "datatable_" + datatable_number.to_s
        datatable = Datatable.find(params[datatable_name])
        datatables << datatable
      end
    end
    users.each do |user|
      if @datatable
        ownership = Ownership.new(:user => user, :datatable => @datatable)
        ownership.save
      else
        datatables.each do |table|
          ownership = Ownership.new(:user => user, :datatable => table)
          ownership.save
        end
      end
    end

    redirect_to ownerships_path
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
