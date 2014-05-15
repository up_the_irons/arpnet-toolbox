require File.dirname(__FILE__) + '/ip_finder'

describe IpFinder do
  before do
    @ip_finder = IpFinder.new
    @ip  = '10.10.10.10'
  end

  shared_examples "finds IP" do
    it "should return IP" do
      expect(@ip_finder.find(@pattern)).to eq(@ip)
    end
  end

  shared_examples "does not find IP" do
    it "should return nil" do
      expect(@ip_finder.find(@pattern)).to eq(nil)
    end
  end

  context "with empty body" do
    before do
      @pattern = ""
    end

    include_examples "does not find IP"
  end

  context "with nil body" do
    before do
      @pattern = nil
    end

    include_examples "does not find IP"
  end

  context "with valid IP" do
    context "with simple @ip pattern" do
      before do
        @pattern = "@ip #{@ip}"
      end

      include_examples "finds IP"
    end

    context "with sloppy @ip pattern" do
      before do
        @pattern = "lkjs @ip #{@ip} some crap over here"
      end

      include_examples "finds IP"
    end

    context "with multiline @ip pattern" do
      before do
        @pattern = <<-TEXT
          some stuff here
          @ip #{@ip} lskjdf
          more stuff
        TEXT
      end

      include_examples "finds IP"
    end

    context "with trailing characters and no spaces" do
      before do
        @token = "server used for an attack:"
      end

      context "IPv4" do
        before do
          @ip = "192.168.1.10"
          @pattern = "[ddos-response@example.com: Exploitable server used for an attack: #{@ip}]"
        end

        it "should return IP" do
          expect(@ip_finder.find(@pattern, @token)).to eq(@ip)
        end

        it "should return IP (example 2)" do
          @ip = "192.168.1.2"
          @pattern = "[ddos-response@example.com: Exploitable server used for an attack: #{@ip}]"
          expect(@ip_finder.find(@pattern, @token)).to eq(@ip)
        end
      end

      context "IPv6" do
        before do
          @ip = "fe80:dead:beef::100"
          @pattern = "[ddos-response@example.com: Exploitable server used for an attack: #{@ip}]"
        end

        it "should return IP" do
          expect(@ip_finder.find(@pattern, @token)).to eq(@ip)
        end

        it "should return IP (example 2)" do
          @ip = "fda4:7d0:d9cd::3fc1"
          @pattern = "[ddos-response@example.com: Exploitable server used for an attack: #{@ip}]"
          expect(@ip_finder.find(@pattern, @token)).to eq(@ip)
        end

        it "should return IP (example 3)" do
          @ip = "fe20::150:560f:fec4:3"
          @pattern = "[ddos-response@example.com: Exploitable server used for an attack: #{@ip}]"
          expect(@ip_finder.find(@pattern, @token)).to eq(@ip)
        end
      end
    end

    context "with SpamCop subject line" do
      before do
        @token = "SpamCop \\("
      end

      context "IPv4" do
        before do
          @ip = "192.168.1.10"
          @pattern = "[SpamCop (#{@ip}) id:1234567890]"
        end

        it "should return IP" do
          expect(@ip_finder.find(@pattern, @token)).to eq(@ip)
        end
      end

      context "IPv6" do
        before do
          @ip = "fda4:7d0:d9cd::3fc1"
          @pattern = "[SpamCop (#{@ip}) id:1234567890]"
        end

        it "should return IP" do
          expect(@ip_finder.find(@pattern, @token)).to eq(@ip)
        end
      end
    end
  end

  context "without valid IP" do
    before do
      @pattern = "@ip 10.10.blah"
    end

    include_examples "does not find IP"
  end

  context "valid_ip?()" do
    context "with valid v4 IP" do
      before do
        @ip = '10.10.10.1'
      end

      it "should return true" do
        expect(IpFinder.new.valid_ip?(@ip)).to be true
      end
    end

    context "with valid v6 IP" do
      before do
        @ip = 'fe80::1'
      end

      it "should return true" do
        expect(IpFinder.new.valid_ip?(@ip)).to be true
      end
    end

    context "without valid IP" do
      before do
        @ip = '10.10.blah'
      end

      it "should return false" do
        expect(IpFinder.new.valid_ip?(@ip)).to be false
      end
    end
  end
end
