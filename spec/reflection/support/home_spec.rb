require File.dirname(__FILE__) + '/../../spec_helper'

describe Reflection::Support::Home do
  before(:each) do
    @home = Reflection::Support::Home.new
  end
  
  describe '#path' do
    it 'should generate HOME_DIR/.reflection' do
      @home.path.should eql('/Users/andreas/.reflection')
    end    
  end
  
  describe '#create' do
    it 'should create the directory' do
      File.stub!(:exist?).and_return(false)
      Dir.should_receive(:mkdir).with('/Users/andreas/.reflection')
      @home.create
    end
  end
end