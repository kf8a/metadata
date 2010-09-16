module DatatablesHelper

  def permission_request_email_list(datatable)
    emails = datatable.owners.collect {|owner| owner.email}
    emails << 'glbrc.data@kbs.msu.edu'
    emails << 'poonam31@msu.edu'
    emails.join(',')
  end

end
