# Controls pages dealing with abstracts of meetings
class AbstractsController < ApplicationController
  include FileSource

  before_action :admin?, except: [:index, :show, :download] if Rails.env == 'production'

  # GET meeting_abstracts
  def index
    @abstracts = Abstract.by_authors
    respond_with @abstracts
  end

  def download
    abstract = Abstract.find(params[:id])
    head(:not_found) && return unless abstract
    if Rails.env.production?
      pdf_from_s3(abstract)
    else
      pdf_from_filesystem(abstract)
    end
  end

  # GET meeting_abstracts/new?meeting=1
  def new
    meeting = Meeting.find(params[:meeting_id])
    @abstract = Abstract.new
    @abstract.meeting_id = meeting.id
    @abstract_types = MeetingAbstractType.pluck(:name, :id)
  end

  def create
    @abstract_types = MeetingAbstractType.pluck(:name, :id)
    abstract = Abstract.new(abstract_params)
    respond_to do |format|
      if abstract.save
        flash[:notice] = 'Meeting Abstract was successfully created.'
        if abstract.meeting_abstract_type == MeetingAbstractType.where(name: 'Presentation').first
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
  def show
    @abstract = Abstract.find(params[:id])
    respond_with @abstract
  end

  # GET /meeting_abstract/1/edit
  def edit
    @abstract_types = MeetingAbstractType.all.collect { |type| [type.name, type.id] }
    @abstract = Abstract.find(params[:id])
  end

  # PUT /meeting_abstracts/1
  def update
    abstract = Abstract.find(params[:id])
    logger.info abstract
    logger.info abstract_params
    if abstract.update_attributes(abstract_params)
      flash[:notice] = 'Meeting abstract was successfully updated.'
    end
    respond_with abstract
  end

  def destroy
    abstract = Abstract.find(params[:id])
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

  def abstract_params
    params.require(:abstract).permit(:title, :authors, :abstract, :meeting_abstract_type_id,
                                     :author_affiliations, :meeting_id, :pdf)
  end
end
