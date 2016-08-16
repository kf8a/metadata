# Manage People records
class PeopleController < ApplicationController
  helper_method :people, :person
  before_action :admin?,
                except: [:index, :show, :alphabetical, :emeritus] unless Rails.env == 'development'

  # GET /people
  # GET /people.xml
  def index
    role_type = RoleType.find_by(name: 'lter')
    if role_type
      @roles = role_type.roles
                        .order('seniority')
                        .where('name not like ?', 'Emeritus%')
    end
    respond_to do |format|
      format.html # index.rhtml
    end
  end

  def alphabetical
    @title = 'KBS LTER Directory (alphabetical)'
    respond_to do |format|
      format.html # index.rhtml
    end
  end

  def emeritus
    @roles = RoleType.find_by_name('lter')
                     .roles.order('seniority')
                     .where('name like ?', 'Emeritus%')
    respond_to do |format|
      format.html # emeritus.rhtml
    end
  end

  def show_all
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    respond_with person
  end

  # GET /people/new
  def new
    @person = Person.new
    @roles = lter_roles
  end

  # GET /people/1/edit
  def edit
    @title = 'Edit ' + person.full_name
    @roles = lter_roles
  end

  # POST /people
  # POST /people.xml
  def create
    @person = Person.new(person_params)
    flash[:notice] = 'Person was successfully created.' if @person.save
    respond_with @person
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    if person.update_attributes(person_params)
      flash[:notice] = 'Person was successfully updated.'
    end
    respond_with person
  end

  # DELETE /people/1
  # DELETE /people/1.xml
  def destroy
    person.destroy

    respond_to do |format|
      format.html { redirect_to people_url }
      format.xml  { head :ok }
    end
  end

  private

  def set_title
    if @subdomain_request == 'lter'
      @title = 'KBS LTER Directory'
    else
      @title = 'GLBRC Directory'
    end
  end

  def people
    Person.by_sur_name
  end

  def person
    Person.find(params[:id])
  end

  def person_params
    params.require(:person).permit(:sur_name, :given_name, :middle_name, :title, :organization,
                                   :sub_organization, :street_address, :city, :locale,
                                   :country, :postal_code, :phone, :fax, :email,
                                   :url, :deceased, :friendly_name, :orcid,
                                   affiliations_attributes:
                                   [:role_id, :title, :seniority, :research_interest,
                                    :supervisor, :started_on, :left_on, :_destroy, :id])
  end

  def lter_roles
    Role.where(role_type_id: RoleType.where(name: 'lter').first)
  end
end
