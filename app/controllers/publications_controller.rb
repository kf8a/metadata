class PublicationsController < ApplicationController
  
  before_filter :login_required, :except => [:index, :show, :index_by_treatment]
  # GET /publications
  # GET /publications.xml
  def index
    @crumbs = []
    @pub_type = params[:type]
    publication_types  = PublicationType.find_all_by_name(@pub_type)
    if publication_types.empty?
      @pub_type = ''
      publication_types = PublicationType.find(:all)
    end
    @pub_type =  @pub_type.gsub(/_/,' ') unless @pub_type == ''
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
      treatment = Treatment.find(params[:treatment])  if params[:treatment]
      @publications = treatment.publications
      @decoration = "from #{treatment.name}: #{treatment.description}"
    else
    @publications = Publication.find(:all, :order => order, 
      :conditions => [conditions, publication_types])
    end
    
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @publications.to_xml }
    end
  end
  
  def index_by_treatment    
    @studies = Study.find(:all, :order => :id)

    #@treatments  = Treatment.find(:all, :order => 'priority')
    respond_to do |format|
      format.html #{render  :template => '/publications/index_by_treatment.erb'} 
      format.xml {render  :xml => @studies.to_xml}
    end
  end
  
  # GET /publications/1
  # GET /publications/1.xml
  def show
    @publication = Publication.find(params[:id])
    @publication.abstract.gsub!(/\n/,"\n\n")
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @publication.to_xml }
    end
  end

  # GET /publications/new
  def new
    @publications = Publication.new
    @treatments = Treatment.find(:all)
  end

  # GET /publications/1;edit
  def edit
    @publications = Publication.find(params[:id])
    @treatments =  Treatment.find(:all)
  end

  # POST /publications
  # POST /publications.xml
  def create
     @publication = Publication.new(params[:publications])
   
     respond_to do |format|
       if @publication.save
         flash[:notice] = 'Publications was successfully created.'
         format.html { redirect_to publications_url(@publications) }
         format.xml  { head :created, :location => publications_url(@publications) }
       else
         format.html { render :action => "new" }
         format.xml  { render :xml => @publication.errors.to_xml }
       end
     end
   end
 
  # PUT /publications/1
  # PUT /publications/1.xml
   def update
     @publication = Publication.find(params[:id])
   
     respond_to do |format|
       if @publication.update_attributes(params[:publications])
         flash[:notice] = 'Publications was successfully updated.'
         format.html { redirect_to publication_url(@publication) }
         format.xml  { head :ok }
       else
         format.html { render :action => "edit" }
         format.xml  { render :xml => @publication.errors.to_xml }
       end
     end
   end
 
  # DELETE /publications/1
  # DELETE /publications/1.xml
  def destroy
      @publication = Publication.find(params[:id])
      @publication.destroy
   
      respond_to do |format|
        format.html { redirect_to publications_url }
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
  end
