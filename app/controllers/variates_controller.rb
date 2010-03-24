class VariatesController < ApplicationController
  # GET /variates
  # GET /variates.xml
  def index
    @variates = Variate.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @variates.to_xml }
    end
  end

  # GET /variates/1
  # GET /variates/1.xml
  def show
    @variate = Variate.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @variate.to_xml }
    end
  end

  # GET /variates/new
  def new
    @variate = Variate.new
    respond_to do |format|
       format.html
       format.js do
         render :update do |page|
           page.insert_html :bottom, 'variates', :partial => "new"
         end
       end
     end
  end

  # GET /variates/1;edit
  def edit
    @variate = Variate.find(params[:id])
  end

  # POST /variates
  # POST /variates.xml
  def create
    @variate = Variate.new(params[:variate])

    respond_to do |format|
      if @variate.save
        flash[:notice] = 'Variate was successfully created.'
        format.html { redirect_to variate_url(@variate) }
        format.xml  { head :created, :location => variate_url(@variate) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @variate.errors.to_xml }
      end
    end
  end

  # PUT /variates/1
  # PUT /variates/1.xml
  def update
    @variate = Variate.find(params[:id])

    respond_to do |format|
      if @variate.update_attributes(params[:variate])
        flash[:notice] = 'Variate was successfully updated.'
        format.html { redirect_to variate_url(@variate) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @variate.errors.to_xml }
      end
    end
  end

  # DELETE /variates/1
  # DELETE /variates/1.xml
  def destroy
    @variate = Variate.find(params[:id])
    @variate.destroy

    respond_to do |format|
      format.html { redirect_to variates_url }
      format.xml  { head :ok }
    end
  end
end
