class PasswordMailer < ActionMailer::Base

  def password(user, sent_at = Time.now)
    @subject = 'Software Application Taxonomy - Your Secret Password'
    @body["user"] = user
    @sent_on = sent_at
    @from = 'aforward@site.uottawa.ca'
    @recipients = user.email

    @headers = {}
  end
end
