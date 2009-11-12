require File.dirname(__FILE__) + '/../../spec_helper'

describe Reflection::Support::Home do
  before(:all) do
    @original_home_env = ENV['HOME']
    ENV['HOME'] = "/test/home"
  end
  
  before(:each) do
    @home = Reflection::Support::Home.new
  end
  
  describe '#path' do
    it 'should generate HOME_DIR/.reflection' do
      @home.path.should eql('/test/home/.reflection')
    end    
  end
  
  describe '#create' do
    it 'should create the directory' do
      File.stub!(:exist?).and_return(false)
      Dir.should_receive(:mkdir).with('/test/home/.reflection')
      @home.create
    end
  end
  
  after(:all) do
    ENV['HOME'] = @original_home_env    
  end
end