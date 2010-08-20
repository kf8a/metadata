class UsersController < Clearance::UsersController
  layout :site_layout
  
  def set_title
    @title = request_subdomain.upcase
  end
end
