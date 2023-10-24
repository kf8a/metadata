namespace :textile2md do
  desc 'update html'
  task :to_markdown => :environment  do
    # Page.all.each do |page|
    #   page.body_backup = page.body if page.body_backup.nil? || page.body_backup.empty?
    #   page.body = RedCloth.new(page.body).to_html
    #   page.save
    # end
    Protocol.all.each do |protocol|
      protocol.description_backup = protocol.description if protocol.description_backup.nil?
      protocol.description = RedCloth.new(protocol.description).to_html unless protocol.description.nil?
      protocol.abstract_backup = protocol.abstract if protocol.abstract_backup.nil?
      protocol.abstract = RedCloth.new(protocol.abstract).to_html unless protocol.abstract.nil?
      protocol.body_backup = protocol.body if protocol.body_backup.nil?
      protocol.body = RedCloth.new(protocol.body).to_html unless protocol.body.nil?
      protocol.change_summary_backup = protocol.change_summary if protocol.change_summary_backup.nil?
      protocol.change_summary = RedCloth.new(protocol.change_summary).to_html unless protocol.change_summary.nil?
      protocol.save
    end

    Citation.all.each do |citation|
      citation.abstract_backup = citation.abstract if citation.abstract_backup.nil?
      citation.abstract = RedCloth.new(citation.abstract).to_html unless citation.abstract.nil?
      citation.save
    end

    Meeting.all.each do |meeting|
      meeting.announcement = meeting.announcement if meeting.announcement.nil?
      meeting.announcement = RedCloth.new(meeting.announcement).to_html unless meeting.announcement.nil?
      meeting.save
    end
    Sponsor.all.each do |sponsor|
      sponsor.data_use_statement_backup = sponsor.data_use_statement if sponsor.data_use_statement_backup.nil?
      sponsor.data_use_statement = RedCloth.new(sponsor.data_use_statement).to_html unless sponsor.data_use_statement.nil?
      sponsor.save
    end
    Dataset.all.each do |dataset|
      dataset.abstract_backup = dataset.abstract if dataset.abstract_backup.nil?
      dataset.abstract = RedCloth.new(dataset.abstract).to_html unless dataset.abstract.nil?
      dataset.save
    end
    Datatable.all.each do |datatable|
      datatable.description_backup = datatable.description if datatable.description_backup.nil?
      datatable.description = RedCloth.new(datatable.description).to_html unless datatable.description.nil?
      datatable.save
    end
    Abstract.all.each do |meeting_abstract|
      meeting_abstract.abstract_backup = meeting_abstract.abstract if meeting_abstract.abstract_backup.nil?
      meeting_abstract.abstract = RedCloth.new(meeting_abstract.abstract).to_html unless meeting_abstract.abstract.nil?
      meeting_abstract.save
    end
  end

  desc 'revert to textile'
  task :revert_markdown => :environment  do
    Page.all.each do |page|
      page.body = page.body_backup
      page.body_backup = nil
      page.body_markdown = false
      page.save
    end
    Protocol.all.each do |protocol|
      protocol.description = protocol.description_backup
      protocol.description_backup = nil
      protocol.abstract = protocol.abstract_backup
      protocol.abstract_backup = nil
      protocol.body = protocol.body_backup
      protocol.body_backup = nil
      protocol.change_summary = protocol.change_summary_backup
      protocol.change_summary_backup = nil
      protocol.save
    end
    Citation.all.each do |citation|
      citation.abstract = citation.abstract_backup
      citation.abstract_backup = nil
      citation.save
    end
    Meeting.all.each do |meeting|
      meeting.announcement = meeting.announcemnt_backup
      meeting.announcemnt_backup = nil
      meeting.save
    end
    Sponsor.all.each do |sponsor|
      sponsor.data_use_statement = sponsor.data_use_statement_backup
      sponsor.data_use_statement_backup = nil
      sponsor.save
    end
    Dataset.all.each do |dataset|
      dataset.abstract = dataset.abstract_backup
      dataset.abstract_backup = nil
      dataset.save
    end
    Datatable.all.each do |datatable|
      datatable.description = datatable.description_backup
      datatable.description_backup = nil
      datatable.save
    end
    Abstract.all.each do |meeting_abstract|
      meeting_abstract.abstract = meeting_abstract.abstract_backup
      meeting_abstract.abstract_backup = nil
      meeting_abstract.save
    end
  end
end
