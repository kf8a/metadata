# datatable view helpers
module DatatablesHelper
  def permission_request_email_list(datatable)
    emails = datatable.owners.collect(&:email)
    emails << 'glbrc.data@kbs.msu.edu'
    emails.join(',')
  end

  def ok_to_qc?(datatable)
    datatable.can_be_qcd_by?(current_user)
  end

  def options_for_measurement_scale(variate)
    options_for_select(%w(nominal interval ratio datetime),
                       variate.measurement_scale)
  end

  def options_for_data_type(variate)
    options_for_select(%w(text datetime integer real text),
                       variate.data_type)
  end

  def render_study(options)
    study = Study.where(options).first

    if study
      render partial: 'study', locals: { study: study,
                                         themes: @themes,
                                         datatables: @datatables,
                                         website: @website }
    end
  end
end
