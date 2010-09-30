class InviteMailer < ActionMailer::Base
  
  def invitation(invite)
    from       "sippel@kbs.msu.edu <Suzanne Sippel>"
    recipients invite.email
    subject    "Welcome to the GLBRC Sustainability Data Catalog"
    body       :invite => invite
  end
end
