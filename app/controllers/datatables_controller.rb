# frozen_string_literal: true

# Control the display of datatables
class DatatablesController < ApplicationController
  include StreamFile
  helper_method :datatable

  before_action :authenticate_user!, except: %i[index show suggest search qc]
  before_action :admin?, except: %i[index show suggest search qc]
  # run before filter to prevent non-members from downloading
  before_action :can_download?,
                only: :show,
                if: proc { |controller| controller.request.format.csv? || controller.request.format.fasta? }

  helper_method :datatable
  # protect_from_forgery except: %i[index show search]

  # GET /datatables
  # GET /datatables?public=true
  def index
    @website = website
    @area = params[:area]
    store_location_for(:user, datatables_path)
    params[:public] ? retrieve_public_datatables('') : retrieve_datatables('')

    respond_with @datatables do |format|
      format.rss { render rss: @datatables }
    end
  end

  def search
    @website = website
    query = params['keyword_list']
    redirect_to datatables_url if query.blank?

    params[:public] ? retrieve_public_datatables(query) : retrieve_datatables(query)
  end

  # GET /datatables/1
  # GET /datatables/1.xml
  # GET /datatables/1.csv
  def show
    @website = website

    store_location_for(:user, "/datatables/#{params[:id].to_i}")

    if valid_dataset_request?(@subdomain_request)
      respond_to do |format|
        format.html
        format.fasta
        format.csv do
          render text: 'You do not have permission to download this datatable' unless csv_ok

          if current_user.try(:role) == 'admin'
            render_admin_csv
          elsif @datatable.csv_file.attached?
            redirect_to url_for(@datatable.csv_file), allow_other_hosts: true
          else
            render_csv
          end
        end
      end
    else
      redirect_to datatables_url, allow_other_hosts: true
    end
  end

  def qc; end

  # PUT publish
  def publish
    initialize_instance_variables
    datatable.publish
    render nothing: true
  end

  def retract
    initialize_instance_variables
    datatable.retract
    render nothing: true
  end

  # GET /datatables/new
  def new
    initialize_instance_variables
    @datatable = Datatable.new
  end

  # GET /datatables/1;edit
  def edit
    initialize_instance_variables
  end

  # POST /datatables
  def create
    initialize_instance_variables

    flash[:notice] = 'Datatable was successfully created.' if datatable.save

    respond_with datatable
  end

  # PUT /datatables/1
  def update
    initialize_instance_variables

    flash[:notice] = 'Datatable was successfully updated.' if datatable.update(datatable_params)

    respond_with datatable
  end

  # DELETE /datatables/1
  def destroy
    datatable.destroy
    redirect_to datatables_url
  end

  # TODO: only return the ones for the right website
  def suggest
    term = params[:term]
    return unless term

    term.downcase!

    list = ActsAsTaggableOn::Tag.where('lower(name) like ?', term + '%').select('DISTINCT tags.name')
    list += Person.where('lower(sur_name) like ?', term + '%').select('DISTINCT sur_name as name')
    list += Theme.where('lower(name) like ?', term + '%').select('DISTINCT name')
    list += CoreArea.where('lower(name) like ?', term + '%').select('DISTINCT name')

    keywords = list.collect { |x| x.name.downcase }.sort.uniq
    respond_to { |format| format.json { render json: keywords } }
  end

  def update_temporal_extent
    datatable.update_temporal_extent
    datatable.save
    # TODO: write test to make sure the js fragment get's rendered
    respond_to do |format|
      format.json
      format.html { render nothing: true }
    end
  end

  def approve_records
    datatable.approve_data
    datatable.save
    redirect_to edit_datatable_path(datatable)
  end

  private

  def set_title
    @title = @subdomain_request == 'lter' ? 'LTER Data Catalog' : 'GLBRC Sustainability Data Catalog'
  end

  def set_crumbs
    crumb = Struct::Crumb.new
    @crumbs = []

    crumb.url = '/datatables/'
    crumb.name = 'Data Catalog'
    @crumbs << crumb
    crumb = Struct::Crumb.new

    return unless params[:id]

    # TODO: this next line might not be needed
    datatable = Datatable.find(params[:id])

    return unless datatable.study

    study = datatable.study
    # crumb.url = study_path(study)
    crumb.name = study.name
    @crumbs << crumb
  end

  def retrieve_datatables(query)
    @themes = Theme.roots

    logger.info "query: #{query}"
    @keyword_list = SearchInputSanitizer.sanitize(query)
    @keyword_list = nil if @keyword_list.empty? || @keyword_list == ''

    @datatables =
      if @keyword_list
        Datatable.search @keyword_list, with: { website: website.id }
      else
        Datatable.where(on_web: true).joins(:dataset).where('is_secondary is false and website_id = ?', website.id)
      end

    @studies = Study.find_all_roots_with_datatables(@datatables)
  end

  def retrieve_public_datatables(query)
    @default_value = 'Search for... '
    @themes = Theme.roots

    logger.info "query: #{query}"
    @keyword_list = SearchInputSanitizer.sanitize(query)
    @keyword_list = nil if @keyword_list.empty? || @keyword_list == @default_value

    @datatables =
      if @keyword_list
        Datatable.search @keyword_list, with: { website: website.id }
      else
        Datatable.where(on_web: true).joins(dataset: :sponsor).where(
          'is_secondary is false and website_id = ?',
          website.id
        ).where('sponsors.data_restricted is false')
      end

    @studies = Study.find_all_roots_with_datatables(@datatables)
  end

  def datatable
    @datatable ||= params[:id] ? Datatable.find(params[:id]) : Datatable.new(datatable_params)
  end

  def csv_ok
    datatable.can_be_downloaded_by?(current_user)
  end

  def can_download?
    return true if csv_ok

    head :forbidden
    false
  end

  def datatable_params
    params.require(:datatable).permit(
      :name,
      :title,
      :comments,
      :dataset_id,
      :data_url,
      :is_restricted,
      :is_secondary,
      :description,
      :begin_date,
      :end_date,
      :on_web,
      :keyword_list,
      :theme_id,
      :weight,
      :study_id,
      :deprecation_notice,
      :update_frequency_days,
      { protocol_ids: []},
      :is_secondary,
      { core_area_ids: [] },
      {
        variates_attributes: [
          %i[
            name
            weight
            description
            unit_id
            measurement_scale
            data_type
            max_valid
            min_valid
            date_format
            precision
            missing_value_indicator
            _destroy
            id
          ]
        ]
      },
      data_contributions_attributes: [%i[person_id role_id _destroy id]]
    )
  end

  # TODO: grab approved sql from model
  def render_csv
    stream_file(file_name, "csv") do |stream|
      stream.write @datatable.csv_headers
      Datatable.stream_query_rows(@datatable.approved_data_query) do |row_from_db|
        stream.write row_from_db
      end
    end
  end

  def render_admin_csv
    stream_file(file_name, "csv") do |stream|
      stream.write @datatable.csv_headers
      Datatable.stream_query_rows(@datatable.object) do |row_from_db|
        stream.write row_from_db
      end
    end
  end

  def set_file_headers
    headers['Content-Type'] = 'text/csv'
    headers['Content-disposition'] = "attachment; filename=\"#{file_name}.csv\""
  end

  def file_name
    "#{@datatable.id}-#{@datatable.title.downcase.strip.gsub(/\W/, '+').squeeze('+')}"
  end

  def initialize_instance_variables
    @core_areas = CoreArea.by_name.collect { |area| [area.name, area.id] }
    @studies = Study.all.collect { |study| [study.name, study.id] }
    @people = Person.all
    @units = Unit.all
    @protocols = Protocol.all
  end

  def valid_dataset_request?(subdomain)
    datatable.dataset.valid_request?(subdomain)
  end
end
