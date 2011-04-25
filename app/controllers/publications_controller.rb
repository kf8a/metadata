class PublicationsController < ApplicationController

  before_filter :admin?, :except => [:index, :show, :index_by_treatment]  if Rails.env == 'production'
  before_filter :get_publication, :only => [:show, :edit, :update, :destroy]
  #caches_action :index

  # GET /publications
  # GET /publications.xml
  def index
    @crumbs = []
    @pub_type = params[:type]
    @word = params[:word]

    publication_types  = PublicationType.find_all_by_name(@pub_type)
    if publication_types.empty?
      @pub_type = ''
      publication_types = PublicationType.all
    end
    @pub_type =  @pub_type.gsub(/_/,' ') unless @pub_type.blank?
    conditions = 'publication_type_id in (?) and publication_type_id < 6 '
    order = 'year desc, citation'
    @decoration = 'by year'
    if params[:alphabetical]
      @alphabetical = true
      order = 'citation'
      @decoration = 'by Author'
    end

    if params[:treatment]
      @alphabetical = true
      treatment = Treatment.find(params[:treatment])
      @publications = treatment.publications
      @decoration = "from #{treatment.name}: #{treatment.description}"
    else
      @publications = Publication.order(order).where(conditions, publication_types)
    end

    if @word
      @publications = Publication.find_by_word(@word)
    end


    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @publications.to_xml }
    end
  end

  def index_by_treatment
    @studies = Study.by_id

    #@treatments  = Treatment.find(:all, :order => 'priority')
    respond_to do |format|
      format.html #{render  :template => '/publications/index_by_treatment.erb'}
      format.xml {render  :xml => @studies.to_xml}
    end
  end

  # GET /publications/1
  # GET /publications/1.xml
  def show
    @publication.abstract ||= '' # Make sure we have an abstract
    @publication.abstract.gsub!(/\n/,"\n\n")
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @publication.to_xml }
    end
  end

  # GET /publications/new
  def new
    @publication = Publication.new
    get_form_data
  end

  # GET /publications/1;edit
  def edit
    get_form_data
  end

  # POST /publications
  # POST /publications.xml
  def create
    get_form_data
    publication = params[:publication]
    publication[:publication_type_id] = 1
    @publication = Publication.new(publication)
    if @publication.save
      expire_action :action => :index
      flash[:notice] = 'Publication was successfully created.'
    end
    respond_with @publication
  end

  # PUT /publications/1
  # PUT /publications/1.xml
  def update
    if @publication.update_attributes(params[:publication])
      expire_action :action => :index
      flash[:notice] = 'Publication was successfully updated.'
    else
      get_form_data
    end
    respond_with @publication
  end

  # DELETE /publications/1
  # DELETE /publications/1.xml
  def destroy
    @publication.destroy

    expire_action :action => :index

    respond_to do |format|
      format.html { redirect_to publications_url }
      format.js  do
        render :update do |page|
          page.visual_effect :fade, @publication
        end
      end
      format.xml  { head :ok }
    end
  end

  private

  def set_title
    @title = 'Publications'
  end

  def set_crumbs
    crumb = Struct::Crumb.new
    @crumbs = []
    crumb.url = publications_path
    crumb.name = 'Publications'
    @crumbs << crumb
  end

  def get_form_data
    @publication_types = PublicationType.all.collect {|x| [x.name, x.id]}
    @treatments = Treatment.all
  end

  def get_publication
    @publication = Publication.find(params[:id])
  end
end
