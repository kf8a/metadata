class InviteMailer < ActionMailer::Base
  
  def invitation(invite)
    from       "'Suzanne Sippel <sippel@kbs.msu.edu>"
    recipients invite.email
    subject    "Welcome to the GLBRC Sustainability Data Catalog"
    body       :invite => invite
  end
end
