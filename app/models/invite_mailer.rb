class InviteMailer < ActionMailer::Base
  
  def invitation(invite)
    from       "DO_NOT_REPLY@glbrc.org"
    recipients invite.email
    subject    "Welcome to the GLBRC Sustainability Data Catalog"
    body       :invite => invite
  end
end
