# Control the display of datatables
class DatatablesController < ApplicationController
  helper_method :datatable

  before_action :require_login, except: %i[index show suggest search qc]
  before_action :admin?, except: %i[index show suggest search qc]
  before_action :can_download?, only: :show, if: proc { |controller| controller.request.format.csv? || controller.request.format.fasta? } # run before filter to prevent non-members from downloading
  # before_filter :reject_robots

  helper_method :datatable
  protect_from_forgery except: %i[index show search]

  # GET /datatables
  # GET /datatables.xml
  def index
    @website = website
    @area = params[:area]
    store_location
    retrieve_datatables('')

    respond_with @datatables do |format|
      format.rss { render rss: @datatables }
    end
  end

  def search
    @website = website
    query = params['keyword_list']
    redirect_to datatables_url if query.blank?

    retrieve_datatables(query)
  end

  # GET /datatables/1
  # GET /datatables/1.xml
  # GET /datatables/1.csv
  def show
    @website = website

    store_location # in case we have to log in and come back here
    if valid_dataset_request?(@subdomain_request)
      respond_to do |format|
        format.html
        format.fasta
        format.csv do
          unless csv_ok
            render text: 'You do not have permission to download this datatable'
          end

          if current_user.try(:role) == 'admin'
            render_admin_csv
          else
            render_csv
          end
        end
        format.climdb do
          unless csv_ok
            redirect_to datatable_url(datatable)
          end
        end
      end
    else
      redirect_to datatables_url
    end
  end

  def qc; end

  # PUT publish
  def publish
    datatable.publish
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

    if datatable.update_attributes(datatable_params)
      flash[:notice] = 'Datatable was successfully updated.'
    end

    respond_with datatable
  end

  # DELETE /datatables/1
  def destroy
    datatable.destroy
    respond_with datatable
  end

  # TODO: only return the ones for the right website
  def suggest
    term = params[:term]
    return unless term
    term.downcase!

    list = ActsAsTaggableOn::Tag.where('lower(name) like ?', term + '%')
                                .select('DISTINCT tags.name')
    list += Person.where('lower(sur_name) like ?', term + '%')
                  .select('DISTINCT sur_name as name')
    list += Theme.where('lower(name) like ?', term + '%')
                 .select('DISTINCT name')
    list += CoreArea.where('lower(name) like ?', term + '%')
                    .select('DISTINCT name')

    keywords = list.collect { |x| x.name.downcase }.sort.uniq
    respond_to do |format|
      format.json { render json: keywords }
    end
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
    @title = if @subdomain_request == 'lter'
               'LTER Data Catalog'
             else
               'GLBRC Sustainability Data Catalog'
             end
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

    if datatable.study
      study = datatable.study
      # crumb.url = study_path(study)
      crumb.name = study.name
      @crumbs << crumb
    end
  end

  def retrieve_datatables(query)
    @default_value = 'Search for... '
    @themes = Theme.roots

    logger.info "query: #{query}"
    @keyword_list = SearchInputSanitizer.sanitize(query)
    @keyword_list = nil if @keyword_list.empty? || @keyword_list == @default_value

    @datatables =
      if @keyword_list
        Datatable.search @keyword_list, with: { website: website.id }
      else
        Datatable.where(on_web: true)
                 .includes(:dataset).references(:dataset)
                 .where('is_secondary is false and website_id = ?', website.id)
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
    unless csv_ok
      head :forbidden
      false
    end
  end

  def datatable_params
    params.require(:datatable).permit(:name, :title, :comments, :dataset_id, :data_url,
                                      :is_restricted, :is_secondary,
                                      :description, :begin_date, :end_date, :on_web, :keyword_list,
                                      :theme_id, :weight, :study_id, :deprecation_notice,
                                      :update_frequency_days, :is_secondary, { core_area_ids: [] },
                                      { variates_attributes: [
                                        [:name, :weight, :description,
                                         :unit_id, :measurement_scale, :data_type, :max_valid,
                                         :min_valid, :date_format, :precision,
                                         :missing_value_indicator,
                                         :_destroy, :id]
                                      ] },
                                      data_contributions_attributes:
                                        [[:person_id, :role_id, :_destroy, :id]])
  end

  def render_csv
    set_file_headers
    set_streaming_headers

    response.status = 200
    self.response_body = csv_data
  end

  def render_admin_csv
    set_file_headers
    set_streaming_headers

    response.status = 200
    self.response_body = csv_data(@datatable.object)
  end

  def set_file_headers
    file_name = "#{@datatable.id}-#{@datatable.title.downcase.strip.gsub(/\W/, '+').squeeze('+')}.csv"
    headers['Content-Type'] = 'text/csv'
    headers['Content-disposition'] = "attachment; filename=\"#{file_name}\""
  end

  def set_streaming_headers
    # nginx doc: Setting this to "no" will allow unbuffered responses
    # suitable for Comet and HTTP streaming applications
    headers['X-Accel-Buffering'] = 'no'

    headers['Cache-Control'] ||= 'no-cache'
    headers.delete('Content-Length')
  end

  def csv_data(query = @datatable.approved_data_query)
    Enumerator.new do |line|
      line << @datatable.csv_headers.to_s

      DataQuery.find_in_batches_as_csv(query) do |data|
        line << data.to_s
      end
    end
  end

  # def reject_robots
  #   if params[:id] == 'robots'
  #     render :status => 404
  #   end
  # end

  def initialize_instance_variables
    @core_areas = CoreArea.by_name.collect { |area| [area.name, area.id] }
    @studies = Study.all.collect { |study| [study.name, study.id] }
    @people = Person.all
    @units = Unit.all
  end

  def valid_dataset_request?(subdomain)
    datatable.dataset.valid_request?(subdomain)
  end
end
