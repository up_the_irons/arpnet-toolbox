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

describe MailClassifier::ByClassifier do
  context "with multiple classifiers" do
    before do
      # This could be done with simply one ByToken classifier, but since
      # at the time of this writing, we only have one classifier type,
      # we'll simply use multiple separate ones for testing
      @classifiers = [
        MailClassifier::ByToken.new('@@SPAM'),
        MailClassifier::ByToken.new('@@DMCATakedown'),
        MailClassifier::ByToken.new('@@SMTPOpenRelayNotice'),
      ]
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

    it "should return MailClassifier::Classification::SPAM (first match)" do
      @classifier = MailClassifier::ByClassifier.new(@classifiers)
      expect(@classifier.classification(@msg)).to \
        be_an_instance_of(MailClassifier::Classification::SPAM)
    end
  end
end

describe MailClassifier::ByString do
  context "classification()" do
    context "with mail subject that contains a string" do
      before do
        @string = "Exploitable NTP server"
        @msg = double(:msg,
                      :subject => "Exploitable NTP server used for an attack: 10.0.0.1",
                      :body => <<-END
                         Line 1
                         Line 2
                         Hello
                         Bye
                      END
                      )
      end

      it "should return MailClassifier::Classification::Attacks::NTPAmplification" do
        @classifier = MailClassifier::ByString.new(@string, "Attacks::NTPAmplification")
        expect(@classifier.classification(@msg)).to \
          be_an_instance_of(MailClassifier::Classification::Attacks::NTPAmplification)
      end
    end

    context "with mail body that contains a string" do
      before do
        @string = "Exploitable NTP server"
        @msg = double(:msg,
                      :subject => "foo",
                      :body => <<-END
                         Line 1
                         Line 2
                         Hello

                         Exploitable NTP server used for an attack: 10.0.0.1
                         Bye
                      END
                      )
      end

      it "should return MailClassifier::Classification::Attacks::NTPAmplification" do
        @classifier = MailClassifier::ByString.new(@string, "Attacks::NTPAmplification")
        expect(@classifier.classification(@msg)).to \
          be_an_instance_of(MailClassifier::Classification::Attacks::NTPAmplification)
      end
    end

    context "without mail that contains our strings" do
      before do
        @string = 'lsjdlfkjdsf'
        @msg = double(:msg,
                      :subject => "foo",
                      :body => "Oh, hello there...")

      end

      it "should return nil" do
        @classifier = MailClassifier::ByString.new(@string, "SPAM")
        expect(@classifier.classification(@msg)).to be_nil
      end
    end
  end
end

describe MailClassifier::Classification::Base do
  before do
    @classification = MailClassifier::Classification::Base.new('foo')
  end

  context "forwarder()" do
    it "should return basic mail forwarder" do
      expect(@classification.forwarder).to eq(MailForwarder::AsAttachment::Simple)
    end
  end
end
