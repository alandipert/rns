require File.join(File.dirname(__FILE__), *%w[.. spec_helper.rb])
require 'ns'

describe Ns do
  context 'adding methods to classes' do
    it "works" do
      (1 + 1).should == 2
    end
  end
  context 'adding methods to blocks' do
    it "works" do
      (1 + 1).should == 2
    end
  end
end
