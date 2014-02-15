require File.dirname(__FILE__) + '/mail_classifier'

describe MailClassifierByToken do
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

      it "should return MailClassification::SPAM" do
        @classifier = MailClassifierByToken.new(@msg, @token)
        expect(@classifier.classification).to \
          be_an_instance_of(MailClassification::SPAM)
      end
    end

    context "with token and no defined class" do
      before do
        @token = '@@SomeOtherThing'
        @msg = double(:msg, :subject => "Hey", :body => "I am #{@token}")
      end

      it "should return nil" do
        @classifier = MailClassifierByToken.new(@msg, @token)
        expect(@classifier.classification).to be_nil
      end
    end
  end
end
