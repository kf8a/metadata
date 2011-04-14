module DatatablesHelper

  def permission_request_email_list(datatable)
    emails = datatable.owners.collect {|owner| owner.email}
    emails << 'glbrc.data@kbs.msu.edu'
    emails << 'poonam31@msu.edu'
    emails.join(',')
  end
  
  def options_for_measurement_scale(variate)
    options_for_select(['nominal','interval','ratio', 'datetime'],
        variate.measurement_scale)
  end
  
  def options_for_data_type(variate)
    options_for_select(['text','datetime','integer','real','text'],
        variate.data_type)
  end

  def render_study(options)
    study = Study.where(options).first

    if study
      render :partial => 'study',  :locals => {:study => study, :themes => @themes}
    end
  end
end
