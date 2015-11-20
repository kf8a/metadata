class DatatablesController < ApplicationController
  helper_method :datatable

  before_filter :admin?, :except => [:index, :show, :suggest, :search, :qc] unless Rails.env == 'development'
  before_filter :can_download?, :only=>[:show], :if => Proc.new { |controller| controller.request.format.csv? || controller.request.format.fasta? } # run before filter to prevent non-members from downloading
  # before_filter :reject_robots

  helper_method :datatable
  protect_from_forgery :except => [:index, :show, :search]

  # GET /datatables
  # GET /datatables.xml
  def index
    @website = website
    @area = params[:area]
    store_location
    retrieve_datatables('keyword_list' =>'')

    if Rails.env == 'production' #and stale? etag: @datatables
      respond_with @datatables do |format|
        format.rss {render :rss => @datatables}
      end
    end
  end

  def search
    @website = website
    query =  {'keyword_list' => ''}
    query.merge!(params)
    if query['keyword_list'].empty?
      redirect_to datatables_url
    else
      retrieve_datatables(query)
    end
  end

  # GET /datatables/1
  # GET /datatables/1.xml
  # GET /datatables/1.csv
  def show
    #expires_in 5.minutes
    @website = website

    store_location #in case we have to log in and come back here
    if datatable.dataset.valid_request?(@subdomain_request)
      respond_to do |format|
        format.html
        format.xml
        format.fasta
        format.csv do
          unless csv_ok
            render :text => "You do not have permission to download this datatable"
          end
          # unless current_user.try(:role) == 'admin'
          #   if datatable.csv_cache.exists?
          #     if Rails.env.production?
          #       redirect_to(datatable.csv_cache.s3_object(params[:style]).url_for(:read ,:secure => true, :expires_in => 60.seconds).to_s)
          #     else
          #       path = datatable.csv_cache.path(params[:style])
          #       send_file  path, :type => 'text/csv', :disposition => 'inline'
          #     end
          #   end
          # end
          # render show.csv.erb

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

  def qc
  end

  # PUT publish
  def publish
    datatable.publish
    render :nothing => true
  end


  # GET /datatables/new
  def new
    @core_areas = CoreArea.by_name.collect { |area| [area.name, area.id] }
    @studies = Study.all.collect{ |study| [study.name, study.id] }
    @people = Person.all
    @units = Unit.all
    @datatable = Datatable.new
  end

  # GET /datatables/1;edit
  def edit
    @core_areas = CoreArea.by_name.collect { |area| [area.name, area.id] }
    @studies = Study.all.collect{ |study| [study.name, study.id] }
    @people = Person.all
    # @units = Unit.order(:name).all
  end

  # POST /datatables
  # POST /datatables.xml
  def create
    @core_areas = CoreArea.by_name.collect { |area| [area.name, area.id] }
    @studies = Study.all.collect{ |study| [study.name, study.id] }
    @people = Person.all
    @units = Unit.all

    if datatable.save
      flash[:notice] = 'Datatable was successfully created.'
    end

    respond_with datatable
  end

  # PUT /datatables/1
  # PUT /datatables/1.xml
  def update
    @core_areas = CoreArea.by_name.collect { |area| [area.name, area.id] }
    @studies = Study.all.collect{ |study| [study.name, study.id]}
    @people = Person.all
    @units = Unit.all

    if datatable.update_attributes(datatable_params)
      flash[:notice] = 'Datatable was successfully updated.'
    end

    respond_with datatable
  end

  # DELETE /datatables/1
  # DELETE /datatables/1.xml
  def destroy
    datatable.destroy
    respond_with datatable
  end

  #TODO only return the ones for the right website.
  def suggest
    term = params[:term]

    list = ActsAsTaggableOn::Tag.where("lower(name) like ?", term.downcase + '%').select("DISTINCT tags.name")
    list = list + Person.where('lower(sur_name) like ?', term.downcase + '%').select('DISTINCT sur_name as name')
    list = list + Theme.where('lower(name) like ?', term.downcase + '%').select('DISTINCT name')
    list = list + CoreArea.where('lower(name) like ?', term.downcase + '%').select('DISTINCT name')

    keywords = list.collect {|x| x.name.downcase }.sort.uniq
    respond_to do |format|
      format.json {render :json => keywords}
    end
  end

  def update_temporal_extent
    datatable.update_temporal_extent
    datatable.save
    #TODO write test to make sure the js fragment get's rendered
    respond_to do |format|
      format.json 
      format.html {render :nothing => true}
    end
  end

  def approve_records
    datatable.approve_data
    datatable.save
    redirect_to edit_datatable_path(datatable)
  end

  private

  def set_title
    if @subdomain_request == 'lter'
      @title  = 'LTER Data Catalog'
    else
      @title = 'GLBRC Sustainability Data Catalog'
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

    #TODO this next line might not be needed
    datatable  = Datatable.find(params[:id])

    if datatable.study
      study = datatable.study
      #crumb.url = study_path(study)
      crumb.name = study.name
      @crumbs << crumb
    end

  end

  def retrieve_datatables(query)
    @default_value = 'Search for... '
    @themes = Theme.roots

    @keyword_list = query['keyword_list'].sub(/\*|@|(?:=>)/, "")
    @keyword_list = nil if @keyword_list.empty? || @keyword_list == @default_value

    @datatables =
      if @keyword_list
        Datatable.search @keyword_list, :with => {:website => website.id}
      else
        Datatable.where(:on_web => true).
          includes(:dataset).references(:dataset).
            where('is_secondary is false and website_id = ?', website.id)
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
      return false
    end
  end

  def datatable_params
    params.require(:datatable).permit(:name, :title, :comments, :dataset_id, :data_url, :is_restricted, :is_secondary,
                                      :description, :begin_date, :end_date, :on_web, :keyword_list,
                                     :theme_id, :weight, :study_id, :deprecation_notice, :update_frequency_days,
                                     :is_secondary, {core_area_ids:[]}, 
                                     {variates_attributes: [ [:name, :weight, :description, :unit_id, :measurement_scale, :data_type, :max_valid, 
                                         :min_valid, :date_format, :precision, :missing_value_indicator, :_destroy, :id] ]} , 
                                         {data_contributions_attributes: [[:person_id, :role_id, :_destroy, :id] ]})
  end

  private

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
    self.response_body = csv_admin_data
  end

  def set_file_headers
    file_name = "#{@datatable.id}-#{@datatable.title.strip.gsub(/\W/,'+').squeeze('+')}.csv"
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=\"#{file_name}\""
  end

  def set_streaming_headers
    #nginx doc: Setting this to "no" will allow unbuffered responses suitable for Comet and HTTP streaming applications
    headers['X-Accel-Buffering'] = 'no'

    headers["Cache-Control"] ||= "no-cache"
    headers.delete("Content-Length")
  end

  def csv_data
    Enumerator.new do |line|
      line << @datatable.csv_headers.to_s

      DataQuery.find_in_batches_as_csv(@datatable.approved_data_query) do |data|
        line << data.to_s
      end
    end
  end

  def csv_admin_data
    Enumerator.new do |line|
      line << @datatable.csv_headers.to_s

      DataQuery.find_in_batches_as_csv(@datatable.object) do |data|
        line << data.to_s
      end
    end
  end

  # def reject_robots
  #   if params[:id] == 'robots'
  #     render :status => 404
  #   end
  # end

end
