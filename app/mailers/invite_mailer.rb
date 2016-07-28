# emails invites to people purporting to come from suzanne
class InviteMailer < ActionMailer::Base
  default from: 'Sven Bohm <bohms@kbs.msu.edu>'

  def invitation(invite)
    @invite = invite
    mail(to: invite.email,
         subject: 'Welcome to the GLBRC Sustainability Data Catalog')
  end
end
