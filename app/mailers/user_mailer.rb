class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.test_mail.subject
  #
  def test_mail
    @greeting = "Hi"

    mail to: params[:recipient]
  end
end
