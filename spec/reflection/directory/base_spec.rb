require File.dirname(__FILE__) + '/../../spec_helper'

describe Reflection::Directory::Base do  
  before(:each) do
    @subject = Reflection::Directory::Base.new("/test/home/path")
  end

  describe '#exists?' do
    it 'should now if the path exists' do
      File.stub!(:exist?).and_return(true)
      @subject.exists?.should be_true
    end
  end
  
  describe '#parent' do
    it 'should find the parent of the last directory living in path' do
      @subject.parent.path.should eql('/test/home')
    end
  end
  
  describe '#name' do
    it 'should find the name of the directory living at the end of path' do
      @subject.name.should eql('path')
    end
  end
  
  describe '#git_index' do
    it 'should join an .git index directory to path' do
      @subject.git_index.should eql('/test/home/path/.git')
    end
  end
  
  describe '#to_s' do
    it 'should resolve as path' do
      @subject.to_s.should eql('/test/home/path')
    end
  end
end
