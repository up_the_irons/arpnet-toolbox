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

  context "send()" do
    before do
      @mail_forwarder = MailForwarder::Base.new(@msg)
    end

    it "should raise NotImplementedError" do
      expect { @mail_forwarder.send }.to raise_error(NotImplementedError)
    end
  end
end

describe MailForwarder::AsAttachment::Simple do
  before do
    @msg = double(:msg,
                  :subject => "Hello",
                  :header => {})
    @to = 'you@example.com'
    @from = 'me@example.com'
    @body = 'Check this out'
    @mail_forwarder = MailForwarder::AsAttachment::Simple.new(@msg)
  end

  context "send()" do
    def do_send(opts = {})
      @mail_forwarder.send(@to, @from, @body, opts)
    end

    it "should create new mail with headers, add attachment, then send" do
      @mail = double(:mail)

      expect(Mail).to receive(:new).and_return(@mail)
      expect(@mail).to receive(:[]=).with(:to, @to)
      expect(@mail).to receive(:[]=).with(:from, @from)
      expect(@mail).to receive(:[]=).with(:body, @body)
      expect(@mail).to receive(:[]=).with(:subject, anything())
      expect(@mail).to receive(:[]=).with('Content-Disposition', 'inline')
      expect(@mail).to receive(:add_part).with(@msg)
      expect(@mail).to receive(:content_type=).with(nil)
      expect(@mail).to receive(:send).with(:add_multipart_mixed_header)
      expect(@mail).to receive(:deliver!)

      do_send
    end

    it "should assign arbitrary headers if we provide them" do
      @mail = double(:mail,
                     :[]= => nil,
                     :add_part => nil,
                     :content_type= => nil,
                     :send => nil,
                     :deliver! => nil)

      @bcc = "secret@example.com"
      @reply_to = "john2@example.com"

      allow(Mail).to receive(:new).and_return(@mail)

      expect(@mail).to receive(:[]=).with(:bcc, @bcc)
      expect(@mail).to receive(:[]=).with('Reply-To', @reply_to)

      do_send(:headers => { :bcc => @bcc, 'Reply-To' => @reply_to })
    end
  end
end
