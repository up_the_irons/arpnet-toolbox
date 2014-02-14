require File.dirname(__FILE__) + '/mail_monitor'

describe MailMonitor do
  context "initialization" do
    before do
      @sleep_time = 5
    end

    context "with block given" do
      it "should set Mail.defaults with block" do
        block = Proc.new {}
        expect(Mail).to receive(:defaults).with(&block)
        MailMonitor.new(@sleep_time, &block)
      end
    end

    context "without block given" do
      it "should not set Mail.defaults" do
        expect(Mail).to_not receive(:defaults)
        MailMonitor.new(@sleep_time)
      end
    end
  end

  context "go()" do
    context "with iterations" do
      before do
        @sleep_time = 0
        @mail_monitor = MailMonitor.new(@sleep_time)

        allow(Mail).to receive(:all).and_return([])
      end

      it "should sleep specified number of iterations" do
        @iterations = 10

        expect(@mail_monitor).to \
          receive(:sleep).with(@sleep_time).exactly(@iterations).times
        @mail_monitor.go(@iterations)
      end

      it "should not sleep if iterations 0" do
        @iterations = 0

        expect(@mail_monitor).to_not receive(:sleep)
        @mail_monitor.go(@iterations)
      end
    end
  end
end
