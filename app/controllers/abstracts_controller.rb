#Controls pages dealing with abstracts of meetings
class AbstractsController < ApplicationController
  helper_method :abstract

  before_action :admin?, except: [:index, :show, :download] if Rails.env == 'production'

  # GET meeting_abstracts
  def index
    @abstracts = Abstract.by_authors
    respond_with @abstracts
  end

  def download
    head(:not_found) and return unless (abstract = Abstract.find_by_id(params[:id]))
    if Rails.env.production?
      redirect_to(abstract.pdf.s3_object
                          .url_for(:read, secure: true, expires_in: 20.seconds)
                          .to_s)
    else
      path = abstract.pdf.path
      send_file  path, type: 'application/pdf', disposition: 'inline'
    end
  end

  # GET meeting_abstracts/new?meeting=1
  def new
    meeting  = Meeting.find(params[:meeting_id])
    abstract.meeting_id = meeting.id
    @abstract_types = MeetingAbstractType.pluck(:name, :id)
  end


  def create
    @abstract_types = MeetingAbstractType.pluck(:name, :id)
    respond_to do |format|
      if abstract.save
        flash[:notice] = 'Meeting Abstract was successfully created.'
        if abstract.meeting_abstract_type == MeetingAbstractType.where(name: "Presentation").first
          format.html { redirect_to abstract_url(abstract) }
        else
          format.html { redirect_to meeting_url(abstract.meeting) }
        end
      else
        format.html { render 'new' }
        format.xml  { render xml: abstract.errors.to_xml }
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
    @abstract_types = MeetingAbstractType.all.collect { |type| [type.name, type.id]}
  end

  # PUT /meeting_abstracts/1
  # PUT /meeting_abstracts/1.xml
  def update
    if abstract.update_attributes(abstract_params)
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
        render nothing: true
      end
    end
  end

  private

  def abstract
    @abstract ||= params[:id] ? Abstract.find(params[:id]) : Abstract.new(abstract_params)
  end

  def abstract_params
    params.permit(:title, :authors, :abstract, :meeting_id, :pdf_file)
  end
end
