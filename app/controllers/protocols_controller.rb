# Serves protocols
class ProtocolsController < ApplicationController
  before_action :admin?, except: [:index, :show, :download] if Rails.env != 'development'
  before_action :protocol, only: [:edit, :update, :destroy]

  # GET /protocols
  def index
    store_location
    initialize_instance_variables

    respond_with @protocols
  end

  # GET /protocols/1
  def show
    store_location
    @protocol = website.protocols.where('id = ?', params[:id]).first

    if @protocol
      respond_with @protocol
    else
      respond_to do |format|
        format.html { redirect_to protocols_url }
        format.xml  { head :not_found }
      end
    end
  end

  # GET /protocols/new
  def new
    @protocol = Protocol.new
    @datasets = Dataset.pluck(:dataset, :id)
    @websites = Website.all
  end

  # GET /protocols/1;edit
  def edit
    @datasets = Dataset.pluck(:dataset, :id)
    @websites = Website.all
  end

  # POST /protocols
  def create
    @protocol = Protocol.new(protocol_params)
    flash[:notice] = 'Protocol was successfully created.' if @protocol.save

    respond_with @protocol
  end

  # PUT /protocols/1
  def update
    params[:protocol][:updated_by] = current_user
    @websites = Website.all
    if params[:new_version]
      old_protocol = Protocol.find(params[:id])
      # Creating a new protocol
      @protocol = Protocol.new(protocol_params)
      @protocol.deprecate!(old_protocol)
    end
    if @protocol.update_attributes(protocol_params)
      flash[:notice] = 'Protocol was successfully updated.'
    end

    respond_with @protocol
  end

  def download
    head(:not_found) && return unless (protocol = Protocol.find_by_id(params[:id]))
    if Rails.env.production?
      file_from_s3(protocol)
    else
      file_from_filesystem(protocol)
    end
  end

  private

  def file_from_s3(protocol)
    redirect_to(protocol.pdf.s3_object(params[:style])
                            .url_for(:read,
                                     secure: true,
                                     expires_in: 10.seconds).to_s)
  end

  def file_from_filesystem(protocol)
    path = protocol.pdf.path(params[:style])
    send_file path, type: 'application/pdf', disposition: 'inline'
  end

  def set_title
    @title = 'Protocols'
  end

  def set_crumbs
    crumb = Struct::Crumb.new
    @crumbs = []
    return unless params[:id]
    crumb.url = protocols_path
    crumb.name = 'Data Catalog: Protocols'
    @crumbs << crumb
  end

  def protocol_themes
    website.protocols.all_tag_counts(on: 'themes').order('name')
  end

  def experiment_protocols
    website.protocols.tagged_with(:experiments)
           .where(active: true).order('title')
  end

  def untagged_protocols
    website.protocols.where(active: true)
           .all.collect { |e| e if e.theme_list.blank? }
           .compact
  end

  def protocol
    @protocol = Protocol.find(params[:id])
  end

  def protocol_params
    params.require(:protocol).permit(:theme_list, :title, :description, :updated_by, :active,
                                     :body, :abstract, :dataset_id, :in_use_from, :in_use_to,
                                     :tag, :website_ids, :name, { person_ids: [] },
                                     { website_ids: [] }, { datatable_ids: [] },
                                     :change_summary, :pdf)
  end

  def initialize_instance_variables
    @website = website

    @protocols = website.protocols.where('active is true').order('title')
    @protocol_themes = protocol_themes
    @experiment_protocols = experiment_protocols

    @untagged_protocols = untagged_protocols

    @retired_protocols = website.protocols.where('active is false').order('title')
  end
end
