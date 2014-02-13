require File.dirname(__FILE__) + '/mail_reader'

# Let's be pure and use the newer syntax
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

describe MailReader do
  context "initialization" do
    context "with block given" do
      it "should set Mail.defaults with block" do
        block = Proc.new {}
        expect(Mail).to receive(:defaults).with(&block)
        MailReader.new(&block)
      end
    end

    context "without block given" do
      it "should not set Mail.defaults" do
        expect(Mail).to_not receive(:defaults)
        MailReader.new
      end
    end
  end

  context "go()" do
    before do
      @msgs = [
        double(:msg_1),
        double(:msg_2)
      ]

      allow(Mail).to receive(:all).and_return(@msgs)
      @mail_reader = MailReader.new
    end

    it "should grab all mails" do
      expect(Mail).to receive(:all).and_return([])
      @mail_reader.go
    end

    it "should yield messages to a block" do
      expect(Mail).to receive(:all).and_return(@msgs)
      expect { |p| @mail_reader.go(&p) }.to yield_successive_args(*@msgs)
    end
  end
end
