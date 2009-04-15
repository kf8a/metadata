class MeetingAbstractsController < ApplicationController


  # GET meeting_abstracts
  # GET meeting_abstracts.xml
  def index
    @abstracts = MeetingAbstract.find(:all, :order=> :authors)
    respond_to do |format|
      format.html # index.erb
      format.xml { render :xml => @abstracts.to_xml}
    end
  end
  
  # GET meeting_abstracts/new?meeting=1
  def new
    @meeting_abstract = MeetingAbstract.new
    meeting  = Meeting.find(params[:meeting])
    @meeting_abstract.meeting_id = meeting.id
  end
  
  
  def create
    @meeting_abstract = MeetingAbstract.new(params[:meeting_abstract])
    respond_to do |format|
      if @meeting_abstract.save
        flash[:notice] = 'Meeting Abstract was successfully created.'
        format.html { redirect_to meeting_url(@meeting_abstract.meeting) }
        format.xml  { head :created, :location => meeting_abstracts_url(@meeting) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @meeting_abstract.errors.to_xml }
      end
    end
  end

  # GET meeting_abstracts/1
  # GET meeting_abstracts/1.xml
  def show
    @abstract = MeetingAbstract.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @abstract.to_xml }
    end
  end
  
  # GET /meeting_abstract/1/edit
  def edit
    @meeting_abstract = MeetingAbstract.find(params[:id])
  end

  # PUT /meeting_abstracts/1
  # PUT /meeting_abstracts/1.xml
  def update
    @meeting_abstract = MeetingAbstract.find(params[:id])

    respond_to do |format|
      if @meeting_abstract.update_attributes(params[:meeting_abstract])
        flash[:notice] = 'Meeting abstract  was successfully updated.'
        format.html { redirect_to meeting_abstract_url(@meeting_abstract) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @meeting_abstract.errors.to_xml }
      end
    end
  end
  
  def destroy
    @meeting_abstract = MeetingAbstract.find(params[:id])
    meeting_abstract_id = "abstract_#{@meeting_abstract.id}"
    @meeting_abstract.destroy
     respond_to do |format|
       format.html { redirect_to meetings_url }
       format.xml  { head :ok }
       format.js do 
         render :update do |page|
           page.visual_effect :fade, meeting_abstract_id
         end
       end
     end
    
  end

end
