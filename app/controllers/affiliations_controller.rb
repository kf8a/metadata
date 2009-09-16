class AffiliationsController < ApplicationController
  # GET /affiliations
  # GET /affiliations.xml
  def index
    @affiliations = Affiliation.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @affiliations.to_xml }
    end
  end

  # GET /affiliations/1
  # GET /affiliations/1.xml
  def show
    @affiliation = Affiliation.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @affiliation.to_xml }
    end
  end

  # GET /affiliations/new
  def new
    @affiliation = Affiliation.new
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.insert_html :bottom, 'affiliations', :partial => "new"
        end
      end
    end
  end

  # GET /affiliations/1;edit
  def edit
    @affiliation = Affiliation.find(params[:id])
  end

  # POST /affiliations
  # POST /affiliations.xml
  def create
    @affiliation = Affiliation.new(params[:affiliation])

    respond_to do |format|
      if @affiliation.save
        flash[:notice] = 'Affiliation was successfully created.'
        format.html { redirect_to affiliation_url(@affiliation) }
        format.xml  { head :created, :location => affiliation_url(@affiliation) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @affiliation.errors.to_xml }
      end
    end
  end

  # PUT /affiliations/1
  # PUT /affiliations/1.xml
  def update
    @affiliation = Affiliation.find(params[:id])

    respond_to do |format|
      if @affiliation.update_attributes(params[:affiliation])
        flash[:notice] = 'Affiliation was successfully updated.'
        format.html { redirect_to affiliation_url(@affiliation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @affiliation.errors.to_xml }
      end
    end
  end

  # DELETE /affiliations/1
  # DELETE /affiliations/1.xml
  def destroy
    @affiliation = Affiliation.find(params[:id])
    @affiliation.destroy

    respond_to do |format|
      format.html { redirect_to affiliations_url }
      format.xml  { head :ok }
    end
  end
end
