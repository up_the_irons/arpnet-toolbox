require File.dirname(__FILE__) + '/mail_base'

describe MailBase do
  context "initialization" do
    context "with block given" do
      it "should set Mail.defaults with block" do
        block = Proc.new {}
        expect(Mail).to receive(:defaults).with(&block)
        MailBase.new(&block)
      end
    end

    context "without block given" do
      it "should not set Mail.defaults" do
        expect(Mail).to_not receive(:defaults)
        MailBase.new
      end
    end
  end
end
