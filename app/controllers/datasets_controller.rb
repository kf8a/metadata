class DatasetsController < ApplicationController
      
  before_filter :set_title, :allow_on_web
  before_filter :login_required, :except => [:index, :show, :auto_complete_for_keyword_list] if ENV["RAILS_ENV"] == 'production'
  
  layout proc {|controller| controller.request.format == :eml ? false : 'application'}
  
  # POST /dataset
  def upload
    file = params[:file]
    @dataset = Dataset.new
  end
  
  # GET /datasets
  # GET /datasets.xml
  def index
    if params[:Dataset] 
      request.format = :eml
    end
    query =  {'theme' => {'id' => nil}, 'person' => {'id' => nil}, 'study' => {'id' => nil}, 
      'keywords' => '', 'date' => {'syear' => '1988', 'eyear' => Date.today.year.to_s}}
    query.merge!(params)
    
    theme_id = query['theme']['id']
    person_id = query['person']['id']
    study_id = query['study']['id']
    keyword_list = query['keyword_list']
    date = query['date']
        
    @people = Person.find_all_with_dataset(:order => 'sur_name')
    @themes = Theme.find(:all, :order => :priority)

    if theme_id && !theme_id.empty?
      @theme = Theme.find(theme_id)
    end
    
    if person_id && !person_id.empty?
      @person = Person.find(person_id)
    end
    
    if study_id && !study_id.empty?
      @study = Study.find(study_id)
    end
    
    if keyword_list
      @keyword_list = keyword_list
    end
            
   @datasets = Dataset.find_by_params({:theme => {:id => theme_id}, :person => {:id => person_id},
          :study => {:id => study_id}, :date => {:syear => date['syear'], :eyear => date['eyear']},
          :keywords => keyword_list})

   @signature_datasets = @datasets.collect do |dataset|  
     dataset if dataset.core_dataset?
   end
   @signature_datasets.compact!
   @signature_datasets.sort!{|a,b| a.title <=> b.title} if @signature_datasets
   
   
   @studies = @datasets.collect do |dataset|
     dataset.studies.flatten
   end
   @studies.flatten!
   @studies.compact!
   @studies.uniq!
   @studies.sort! {|a,b| a.seniority <=> b.seniority}
   
   @studies = [@study] if @study
                                     
    @crumbs = []
    # respond_to do |format|
    #   format.html # index.rhtml
    #   format.xml  { render :xml => @datasets.to_xml }
    #   format.eml { render :xml => eml_harvester_list }
    # end
  end

  # GET /datasets/1
  # GET /datasets/1.xml
  # GET /dataset/1.eml
  def show
    @dataset = Dataset.find(params[:id])
    @title = @dataset.title
    @roles = @dataset.roles

    respond_to do |format|
      format.html # show.rhtml
      format.eml { render :xml => @dataset.to_eml }
      format.xml  { render :xml => @dataset.to_xml }
    end
  end

  # GET /datasets/new
  def new
    @dataset = Dataset.new
  end

  # GET /datasets/1;edit
  def edit
    @dataset = Dataset.find(params[:id])
    @people = Person.all(:order => 'sur_name')
    @studies = Study.all(:order => 'seniority')
    @themes = Theme.all(:order => 'priority')
    @roles = Role.find(:all, :conditions => ['role_type_id = ?', RoleType.find_by_name('dataset')])
  end
  
  # POST /dataset/new_affiliation 
  def set_affiliation_for
    @affiliation = Affiliation.new
    people = Person.find(:all, :order => 'sur_name ASC')
    roles = Role.find(:all, :conditions => ['role_type_id = ?', RoleType.find_by_name('dataset')])
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.insert_html :bottom, 'affiliations', :partial => "affiliation", 
            :locals => {:roles => roles, :people => people, :affiliation => @affiliation}
        end
      end
    end
    
  end

  # POST /datasets
  # POST /datasets.xml
  def create
    @dataset = Dataset.new(params[:dataset])

    respond_to do |format|
      if @dataset.save
        flash[:notice] = 'Dataset was successfully created.'
        format.html { redirect_to dataset_url(@dataset) }
        format.xml  { head :created, :location => dataset_url(@dataset) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dataset.errors.to_xml }
      end
    end
  end

  # PUT /datasets/1
  # PUT /datasets/1.xml
  def update
    @dataset = Dataset.find(params[:id])

    respond_to do |format|
      if @dataset.update_attributes(params[:dataset])
        flash[:notice] = 'Dataset was successfully updated.'
        format.html { redirect_to dataset_url(@dataset) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dataset.errors.to_xml }
      end
    end
  end

  # DELETE /datasets/1
  # DELETE /datasets/1.xml
  def destroy
    @dataset = Dataset.find(params[:id])
    @dataset.destroy

    respond_to do |format|
      format.html { redirect_to datasets_url }
      format.xml  { head :ok }
    end
  end
  
  def auto_complete_for_keyword_list
    @tags = Tag.find(:all, :conditions => [ 'name LIKE ?',
        '%' + params[:keyword_list] + '%' ], 
        :order => 'name ASC')
    render :partial => 'tags'
  end
  
  
  
  private
    
  def set_title
    @title  = 'LTER Datasets'
  end

  def set_crumbs
    crumb = Struct::Crumb.new
    @crumbs = []
    crumb.url = datasets_path
    crumb.name = 'Data Catalog: Datasets'
    @crumbs << crumb
  end
  
  def allow_on_web
    return unless params[:id]
    if params[:id] =~ /KBS\d\d\d/
      params[:id] = Dataset.find_by_dataset(params[:id])
    end
    dataset = Dataset.find(params[:id])
    dataset.on_web
  end
end
