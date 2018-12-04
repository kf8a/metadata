require 'csv'

# Manage People records
class PeopleController < ApplicationController
  open_actions = %i[index show alphabetical emeritus lno]

  helper_method :people, :person
  before_action :require_login, except: open_actions
  before_action :admin?, except: open_actions

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
      format.csv { send_data csv(@roles), filename: "users-#{Time.zone.today}.csv" }
    end
  end

  def alphabetical
    @title = 'KBS LTER Directory (alphabetical)'
    respond_to do |format|
      format.html # index.rhtml
    end
  end

  def emeritus
    @roles = RoleType.find_by(name: 'lter')
                     .roles.order('seniority')
                     .where('name like ?', 'Emeritus%')
    respond_to do |format|
      format.html # emeritus.rhtml
    end
  end

  def lno
    role_type = RoleType.find_by(name: 'lno')
    roles = role_type.roles

    @active = roles.flat_map(&:people).uniq
    all_lter = Person.where('lno_name is not null').all
    @inactive = all_lter - @active
    respond_to do |format|
      format.html
      format.csv { send_data lno_csv(@active, @inactive), filename: "users-#{Time.zone.now}.csv" }
    end
  end

  def show_all; end

  # GET /people/1
  # GET /people/1.xml
  def show
    respond_with person
  end

  # GET /people/new
  def new
    @person = Person.new
    @roles = lter_roles #+ lno_roles
  end

  # GET /people/1/edit
  def edit
    @title = 'Edit ' + person.full_name
    @roles = lter_roles #+ lno_roles
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
    flash[:notice] = 'Person was successfully updated.' if person.update(person_params)
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
    @tile = if @subdomain_request == 'lter'
              'KBS LTER Directory'
            else
              'GLBRC Directory'
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
                                   :url, :deceased, :friendly_name, :orcid_id,
                                   affiliations_attributes:
                                   %i[role_id title seniority research_interest
                                      supervisor started_on left_on _destroy id])
  end

  def lter_roles
    specific_roles('lter')
  end

  def lno_roles
    specific_roles('lno')
  end

  def specific_roles(name)
    Role.where(role_type_id: RoleType.where(name: name).first)
  end

  def csv(roles)
    roles.flat_map do |r|
      r.people.collect { |p| p.to_csv << r.name }
    end
  end

  def lno_csv(active, inactive)
    CSV.generate do |csv|
      active.each do |person|
        csv << person.to_lno_active
      end
      inactive.each do |person|
        csv << person.to_lno_inactive
      end
    end
  end
end
