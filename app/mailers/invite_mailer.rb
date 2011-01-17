class InviteMailer < ActionMailer::Base
  default :from => "Suzanne Sippel <sippel@kbs.msu.edu>"

  def invitation(invite)
    @invite = invite
    mail(:to => invite.email,
         :subject => "Welcome to the GLBRC Sustainability Data Catalog")
  end
end
