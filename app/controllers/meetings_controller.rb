class MeetingsController < ApplicationController

  before_filter :admin?, :except => [:index, :show]  if Rails.env == 'production'
  before_filter :get_meeting, :only => [:show, :edit, :update, :destroy]

  def index
    venue = 1 # KBS
    venue = 2 if params[:location] == 'national'
    
    @venue = VenueType.find(venue)
    @meetings = @venue.meetings
    @title = @venue.name.humanize + "  Meetings"
    respond_to do |format|
      format.html #index.html
      format.xml { render :xml => @meetings.to_xml}
    end
  end

  # GET /meeting/1
  # GET /meeting/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @person.to_xml }
    end
  end

  def new
    @meeting = Meeting.new
    @venues = VenueType.find(:all).collect {|x| [x.name, x.id]}
  end
  
  def edit
    @venues = VenueType.find(:all).collect {|x| [x.name, x.id]}
  end
  
  def create
    @meeting = Meeting.new(params[:meeting])
    respond_to do |format|
      if @meeting.save
        flash[:notice] = 'Meeting was successfully created.'
        format.html { redirect_to meetings_url }
        format.xml  { head :created, :location => meeting_url(@meeting) }
      else
        @venues = VenueType.find(:all).collect {|x| [x.name, x.id]}
        format.html { render :action => "new" }
        format.xml  { render :xml => @meeting.errors.to_xml }
      end
    end
  end
  
  def update
    respond_to do |format|
       if @meeting.update_attributes(params[:meeting])
         flash[:notice] = 'Meetings was successfully updated.'
         format.html { redirect_to meeting_url(@meeting) }
         format.xml  { head :ok }
       else
         @venues = VenueType.find(:all).collect {|x| [x.name, x.id]}
         format.html { render :action => "edit" }
         format.xml  { render :xml => @meeting.errors.to_xml }
       end
     end
  end
  
  def destroy
    meeting_id = "meeting_#{@meeting.id}"
    @meeting.destroy
     respond_to do |format|
       format.html { redirect_to meetings_url }
       format.xml  { head :ok }
       format.js do 
         render :update do |page|
           page.visual_effect :fade, meeting_id
         end
       end
     end
  end
  
  private
  def set_crumbs
    crumb = Struct::Crumb.new
    @crumbs = []
    return unless params[:id]
    meeting = Meeting.find(params[:id])
    venue = meeting.venue_type
    
    crumb.url = url_for(:controller => 'meetings', :location  => venue.name)
  #  crumb.url = "/meetings/?location=#{venue.name}"
  
    crumb.name = venue.name.capitalize + ' Meeting'
    @crumbs << crumb
  end
  
  def get_meeting
    @meeting = Meeting.find(params[:id])
  end
end
