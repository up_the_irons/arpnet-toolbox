require File.dirname(__FILE__) + '/mail_classifier'

describe MailClassifier::ByToken do
  context "classification()" do
    context "with spammy mail and spam token" do
      before do
        @token = '@@SPAM'
        @msg = double(:msg,
                      :subject => "I am spam",
                      :body => <<-END
                         Line 1
                         Line 2
                         Hello

                         #{@token}

                         Bye
                      END
                      )
      end

      it "should return MailClassifier::Classification::SPAM" do
        @classifier = MailClassifier::ByToken.new(@token)
        expect(@classifier.classification(@msg)).to \
          be_an_instance_of(MailClassifier::Classification::SPAM)
      end
    end

    context "with multiple tokens" do
      before do
        @tokens = %w(@@DMCATakedown @@SPAM @@SMTPOpenRelayNotice)
        @msg = double(:msg,
                      :subject => "I am many things",
                      :body => <<-END
                         Line 1
                         Line 2
                         Hello

                         @@SMTPOpenRelayNotice
                         @@DMCATakedown
                         @@SPAM

                         Bye
                      END
                      )
      end

      it "should return MailClassifier::Classification::DMCATakedown (first match)" do
        @classifier = MailClassifier::ByToken.new(@tokens)
        expect(@classifier.classification(@msg)).to \
          be_an_instance_of(MailClassifier::Classification::DMCATakedown)
      end
    end

    context "with token and no defined class" do
      before do
        @token = '@@SomeOtherThing'
        @msg = double(:msg, :subject => "Hey", :body => "I am #{@token}")
      end

      it "should return nil" do
        @classifier = MailClassifier::ByToken.new(@token)
        expect(@classifier.classification(@msg)).to be_nil
      end
    end
  end
end
