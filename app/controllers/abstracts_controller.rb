#Controls pages dealing with abstracts of meetings
class AbstractsController < ApplicationController

  before_filter :admin?, :except => [:index, :show]  if ENV["RAILS_ENV"] == 'production'
  before_filter :get_abstract, :only => [:show, :edit, :update, :destroy]
  
  # GET meeting_abstracts
  # GET meeting_abstracts.xml
  def index
    @abstracts = Abstract.by_authors
    respond_to do |format|
      format.html # index.erb
      format.xml { render :xml => @abstracts.to_xml}
    end
  end
  
  # GET meeting_abstracts/new?meeting=1
  def new
    @abstract = Abstract.new
    meeting  = Meeting.find(params[:meeting])
    @abstract.meeting_id = meeting.id
  end
  
  
  def create
    @abstract = Abstract.new(params[:abstract])
    respond_to do |format|
      if @abstract.save
        flash[:notice] = 'Meeting Abstract was successfully created.'
        format.html { redirect_to meeting_url(@abstract.meeting) }
        format.xml  { head :created, :location => abstracts_url(@meeting) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @abstract.errors.to_xml }
      end
    end
  end

  # GET meeting_abstracts/1
  # GET meeting_abstracts/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @abstract.to_xml }
    end
  end
  
  # GET /meeting_abstract/1/edit
  def edit
  end

  # PUT /meeting_abstracts/1
  # PUT /meeting_abstracts/1.xml
  def update
    respond_to do |format|
      if @abstract.update_attributes(params[:abstract])
        flash[:notice] = 'Meeting abstract was successfully updated.'
        format.html { redirect_to abstract_url(@abstract) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @abstract.errors.to_xml }
      end
    end
  end
  
  def destroy
    abstract_id = "abstract_#{@abstract.id}"
    @abstract.destroy
     respond_to do |format|
       format.html { redirect_to meetings_url }
       format.xml  { head :ok }
       format.js do 
         render :update do |page|
           page.visual_effect :fade, abstract_id
         end
       end
     end
  end
  
  private
  
  def get_abstract
    @abstract = Abstract.find(params[:id])  
  end
end
