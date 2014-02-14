require File.dirname(__FILE__) + '/mail_reader'

# Let's be pure and use the newer syntax
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

describe MailReader do
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
