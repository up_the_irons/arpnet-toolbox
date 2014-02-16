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
