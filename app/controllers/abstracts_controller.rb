#Controls pages dealing with abstracts of meetings
class AbstractsController < ApplicationController
  helper_method :abstract

  before_filter :admin?, :except => [:index, :show, :download]  if Rails.env == 'production'

  # GET meeting_abstracts
  # GET meeting_abstracts.xml
  def index
    @abstracts = Abstract.by_authors
    respond_with @abstracts
  end

  def download
    head(:not_found) and return unless (abstract= Abstract.find_by_id(params[:id]))
    path = abstract.pdf.path(params[:style])
    if Rails.env.production?
      redirect_to(abstract.pdf.s3_object(params[:style]).url_for(:read, :secure => true, :expires_in  => 20.seconds).to_s)
    else
      send_file  path, :type => 'application/pdf', :disposition => 'inline'
    end
  end

  # GET meeting_abstracts/new?meeting=1
  def new
    meeting  = Meeting.find(params[:meeting])
    abstract.meeting_id = meeting.id
  end


  def create
    respond_to do |format|
      if abstract.save
        flash[:notice] = 'Meeting Abstract was successfully created.'
        format.html { redirect_to meeting_url(abstract.meeting) }
        format.xml  { head :created, :location => abstracts_url(abstract.meeting) }
      else
        format.html { render "new" }
        format.xml  { render :xml => abstract.errors.to_xml }
      end
    end
  end

  # GET meeting_abstracts/1
  # GET meeting_abstracts/1.xml
  def show
    respond_with abstract
  end

  # GET /meeting_abstract/1/edit
  def edit
  end

  # PUT /meeting_abstracts/1
  # PUT /meeting_abstracts/1.xml
  def update
    if abstract.update_attributes(params[:abstract])
      flash[:notice] = 'Meeting abstract was successfully updated.'
    end
    respond_with abstract
  end

  def destroy
    abstract.destroy
    respond_to do |format|
      format.html { redirect_to meetings_url }
      format.xml  { head :ok }
      format.js do
        render :nothing => true
      end
    end
  end

  private

  def abstract
    @abstract ||= params[:id] ? Abstract.find(params[:id]) : Abstract.new(params[:abstract])
  end
end
