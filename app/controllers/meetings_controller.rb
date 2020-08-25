# frozen_string_literal: true

# Meetings are local and national ASM's usually
class MeetingsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :admin?, except: %i[index show]
  before_action :meeting, only: %i[show edit update destroy]
  helper_method :venues

  def index
    # venue = 1 # KBS
    # venue = 2 if params[:location] == 'national'

    @local_venue = VenueType.find(1)
    @local_meetings = @local_venue.meetings

    @national_venue = VenueType.find(2)
    @national_meetings = @national_venue.meetings

    respond_to(&:html)
  end

  # GET /meeting/1
  def show; end

  def new
    @meeting = Meeting.new
  end

  def edit; end

  def create
    @meeting = Meeting.new(meeting_params)
    respond_to do |format|
      if @meeting.save
        flash[:notice] = 'Meeting was successfully created.'
        format.html { redirect_to meetings_url }
      else
        format.html { render 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @meeting.update(meeting_params)
        flash[:notice] = 'Meetings was successfully updated.'
        format.html { redirect_to meeting_url(@meeting) }
      else
        @venues = VenueType.find(:all).collect { |type| [type.name, type.id] }
        format.html { render 'edit' }
      end
    end
  end

  def destroy
    @meeting.destroy
    respond_to do |format|
      format.html { redirect_to meetings_url }
      format.js { render nothing: true }
    end
  end

  private

  def set_crumbs
    crumb = Struct::Crumb.new
    @crumbs = []
    return unless params[:id]

    meeting = Meeting.find(params[:id])
    venue = meeting.venue_type

    crumb.url = "/meetings/?location=#{venue.name}"

    crumb.name = "#{venue.name.capitalize}  Meeting"
    @crumbs << crumb
  end

  def meeting
    @meeting = Meeting.find(params[:id])
  end

  def venues
    VenueType.pluck(:name, :id)
  end

  def meeting_params
    params.require(:meeting).permit(:date, :title, :announcement, :venue_type_id, :date_to)
  end
end
