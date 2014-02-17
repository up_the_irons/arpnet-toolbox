require File.dirname(__FILE__) + '/mail_forwarder'

describe MailForwarder::Base do
  before do
    @msg = double(:msg, :subject => "Die Katze ist auf dem Tisch")
  end

  context "initialization" do
    context "with block given" do
      it "should set Mail.defaults with block" do
        block = Proc.new {}
        expect(Mail).to receive(:defaults).with(&block)
        MailForwarder::Base.new(@msg, &block)
      end
    end

    context "without block given" do
      it "should not set Mail.defaults" do
        expect(Mail).to_not receive(:defaults)
        MailForwarder::Base.new(@msg)
      end
    end
  end

  context "subject()" do
    before do
      @subject_prefix = "Forwarded Message: "
      @mail_forwarder = MailForwarder::Base.new(@msg, :subject_prefix => @subject_prefix)
    end

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

describe MailForwarder::AsAttachment do
  before do
    @msg = double(:msg,
                  :subject => "Hello")
    @to = 'you@example.com'
    @from = 'me@example.com'
    @body = 'Check this out'
    @mail_forwarder = MailForwarder::AsAttachment.new(@msg)
  end

  context "send()" do
    def do_send
      @mail_forwarder.send(@to, @from, @body)
    end

    it "should create new mail with headers, add attachment, then send" do
      @mail = double(:mail)

      expect(Mail).to receive(:new).and_return(@mail)
      expect(@mail).to receive(:[]=).with(:to, @to)
      expect(@mail).to receive(:[]=).with(:from, @from)
      expect(@mail).to receive(:[]=).with(:body, @body)
      expect(@mail).to receive(:[]=).with(:subject, anything())
      expect(@mail).to receive(:add_part).with(@msg)
      expect(@mail).to receive(:deliver!)

      do_send
    end
  end
end
