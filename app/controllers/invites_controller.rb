class InvitesController < ApplicationController
  
  before_filter :admin? unless Rails.env == 'development'
  before_filter :get_invite, :only => [:show, :edit, :update, :destroy, :send_invitation]
  
  # GET /invites
  # GET /invites.xml
  def index
    @invites = Invite.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invites }
    end
  end

  # GET /invites/1
  # GET /invites/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @invite }
    end
  end

  # GET /invites/new
  # GET /invites/new.xml
  def new
    @invite = Invite.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @invite }
    end
  end

  # GET /invites/1/edit
  def edit
  end

  # POST /invites
  # POST /invites.xml
  def create
    @invite = Invite.new(params[:invite])

    respond_to do |format|
      if @invite.save
        format.html { redirect_to(@invite, :notice => 'Invite was successfully created.') }
        format.xml  { render :xml => @invite, :status => :created, :location => @invite }
      else
        format.html { render "new" }
        format.xml  { render :xml => @invite.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /invites/1
  # PUT /invites/1.xml
  def update
    respond_to do |format|
      if @invite.update_attributes(params[:invite])
        format.html { redirect_to(@invite, :notice => 'Invite was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render "edit" }
        format.xml  { render :xml => @invite.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /invites/1
  # DELETE /invites/1.xml
  def destroy
    @invite.destroy

    respond_to do |format|
      format.html { redirect_to(invites_url) }
      format.xml  { head :ok }
    end
  end
  
  def send_invitation
    @invite.invite!
    InviteMailer.invitation(@invite).deliver
    flash[:notice] = "Invite sent to #{@invite.email}"
    redirect_to(invites_url)
  end

  private#########################
  
  def get_invite
    @invite = Invite.find(params[:id])
  end

end
