require File.dirname(__FILE__) + '/mail_forwarder'

describe MailForwarderBase do
  before do
    @msg = double(:msg, :subject => "Die Katze ist auf dem Tisch")
    @subject_prefix = "Forwarded Message: "
    @mail_forwarder = MailForwarderBase.new(@msg, :subject_prefix => @subject_prefix)
  end

  context "subject()" do
    context "with arg" do
      before do
        @s = 'Hi!'
      end

      it "should return arg" do
        expect(@mail_forwarder.subject(@s)).to eq(@s)
      end
    end

    context "without arg" do
      it "should return origin message subject with prefix" do
        expect(@mail_forwarder.subject).to eq(@subject_prefix + @msg.subject)
      end
    end
  end
end

describe MailForwarderAsAttachment do
  context "send()" do
    it "should create new mail"
    it "should set headers and body"
    it "should add original mail as attachment"
  end
end
