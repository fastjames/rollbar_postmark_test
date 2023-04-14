class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  rescue_from Postmark::InactiveRecipientError do |error|
    parse_recipients(error.message).each do |email|
      warn "ApplicationMailer rescue_from"
      user = User.find_by(email:)
      if user.present? && user.postmark_error_at.blank?
        user.update postmark_error_at: Time.current
      end
    end
  end
end

INACTIVE_ADDR_PATTERNS = [
  /Found inactive addresses: (.+?)\. Inactive/,
  /^Found inactive addresses: (.+?)\.$/,
  /these inactive addresses: (.+?)\. Inactive/,
  /these inactive addresses: (.+?)\.?$/
].freeze

def parse_recipients(message)
  INACTIVE_ADDR_PATTERNS.each do |p|
    _, recipients = p.match(message).to_a
    next unless recipients.present?

    return recipients.split(', ')
  end
end
