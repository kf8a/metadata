# frozen_string_literal: true

# Controls pages dealing with abstracts of meetings
class AbstractsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :admin?, except: %i[index show]

  # GET meeting_abstracts
  def index
    @meetings = Meeting.all.order(date: :desc)
    respond_with @meetings
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
    if abstract.save
      flash[:notice] = 'Meeting Abstract was successfully created.'
      redirect_to_abstract_or_meeting(abstract)
    else
      redirect_to 'new'
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
    if abstract.update(abstract_params)
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

  def redirect_to_abstract_or_meeting(abstract)
    logger.info abstract.meeting
    if abstract.meeting_abstract_type == MeetingAbstractType.where(name: 'Presentation').first
      redirect_to abstract_url(abstract)
    else
      redirect_to meeting_url(abstract.meeting)
    end
  end
end
