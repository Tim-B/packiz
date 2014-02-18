require 'packiz.rb'
require 'fileutils'

describe Packiz do

  describe '#initialize' do
    it "should raise" do
      FileUtils.cd('spec/assets/test_project_two') do
        expect { Packiz.instance }.to raise_error
      end
    end

    it "should not raise" do
      FileUtils.cd('spec/assets/test_project_one') do
        expect { Packiz.instance }.to_not raise_error
      end
    end

  end
end