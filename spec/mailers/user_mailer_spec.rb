require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "test_mail" do
    let(:email) { 'someone@somewhere.org' }
    let(:user) { User.create(email:) }
    let(:recipient) { user.email }
    let(:mail) { UserMailer.with(recipient:).test_mail }

    it "renders the headers" do
      expect(mail.subject).to eq("Test mail")
      expect(mail.to).to eq(["someone@somewhere.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end

    context "when a recipient bounces" do
      before do
        ActionMailer::Base.deliveries.clear
      end

      it "marks the user as having a postmark error", :job do
        allow_any_instance_of(ActionMailer::MessageDelivery)
          .to(receive(:deliver_now))
          .and_raise(
            Postmark::InactiveRecipientError.new(
              406,
              nil,
              {'Message' => "You tried to send to recipient(s) that have been marked as inactive. " \
                            "Found inactive addresses: #{email}. Inactive recipients are ones that " \
                            "have generated a hard bounce, a spam complaint, or manual suppression."}
            )
          )
        expect {
          described_class.with(recipient: user.email).test_mail.deliver_later
        }.to(change { user.reload.postmark_error_at })

        expect(UserMailer.deliveries.size).to eq(0)
      end
    end
  end

end
