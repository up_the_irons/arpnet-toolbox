require File.dirname(__FILE__) + '/mail_monitor'

describe MailReader do
  context "initialization" do
    context "with block given" do
      it "should set Mail.defaults with block" do
        block = Proc.new {}
        Mail.should_receive(:defaults).with(&block)
        MailReader.new(&block)
      end
    end

    context "without block given" do
      it "should not set Mail.defaults" do
        Mail.should_not_receive(:defaults)
        MailReader.new
      end
    end
  end
end
