class SessionsController < Clearance::SessionsController

  skip_before_filter :login_required
 
  def url_after_login 
    '/datatables'
  end
  
end
