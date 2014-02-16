require File.dirname(__FILE__) + '/finder_base'

describe FinderBase do
  before do
    @finder = FinderBase.new
  end

  shared_examples 'an argument error' do
    it 'should raise ArgumentError' do
      expect { @finder.find(@body) }.to raise_error(ArgumentError)
    end
  end

  context 'with body' do
    before do
      @body = <<-END
    line 1
    line 2
    line 3
    yay
    END
    end

    it 'should return nil' do
      expect(@finder.find(@body)).to be_nil
    end
  end

  context 'with empty body' do
    before do
      @body = ""
    end

    include_examples "an argument error"
  end

  context 'with nil body' do
    before do
      @body = nil
    end

    include_examples "an argument error"
  end
end
