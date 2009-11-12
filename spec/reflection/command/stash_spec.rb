require File.dirname(__FILE__) + '/../../spec_helper'

describe Reflection::Command::Stash do
  before(:each) do
    @options = OpenStruct.new({ :directory => '/home/tmp/fu_asset_directory' })
    @subject = Reflection::Command::Stash.new(@options)
  end
  
  describe 'validations' do
    it 'should validate the existence of the directory' do
      Reflection::Validations.should_receive(:existence_of).with('/home/tmp/fu_asset_directory')
      @subject.validate!
    end
  end
  
  describe '#run!' do
    before(:each) do
      Reflection::Repository.stub!(:exists?).and_return(false) 
      @subject.stub!(:prepare_stash_repository)
      @subject.stub!(:stash_directory_into_repository)
    end

    it 'should fail if the directory is a repository' do
      Reflection::Repository.stub!(:exists?).and_return(true) 
      Reflection::Support.should_receive(:exit_with_error)
      @subject.run!
    end
    
    it 'should prepare the stash repository' do
      @subject.should_receive(:prepare_stash_repository)
      @subject.run!
    end
    
    it 'should stash the directory into the repository' do
      @subject.should_receive(:stash_directory_into_repository)
      @subject.run!
    end
  end
  
  describe '#prepare_stash_repository' do
    before(:each) do
      @mock_stash_repository = mock('StashRepository')
      @mock_stash_directory = mock('Directory::Stash', :repository => @mock_stash_repository)
    end
    
    context 'stash directory exists' do
      before(:each) do
        @mock_stash_directory.stub!(:exists?).and_return(true)
      end
      
      it 'should validate the repository' do
        @mock_stash_directory.should_receive(:validate_repository)
        @subject.prepare_stash_repository(@mock_stash_directory)
      end
    end
    
    context 'stash directory does not exist' do
      before(:each) do
        @mock_stash_directory.stub!(:exists?).and_return(false)
      end
      
      it 'should clone the --repository into the stash path' do
        @mock_stash_directory.should_receive(:clone_repository)
        @subject.prepare_stash_repository(@mock_stash_directory)
      end
    end
  end
  
  describe '#stash_directory_into_repository' do
    before(:each) do
      @mock_stash_repository = mock('StashRepository')
      @mock_stash_directory = mock('Directory::Stash', :repository => @mock_stash_repository, :path => '/home/stash/path')
      FileUtils.stub!(:mv)
    end
    
    it "should move the stash-repository-directory (.git) one level above the asset directory path" do
      pending
      FileUtils.should_receive(:mv).with('/home/stash/path/.git', '/home/tmp')
      @subject.stash_directory_into_repository(@mock_stash_directory)
    end
    
    it "should add the contents of directory to the repository" do
    end
    
    it "should git-commit and git-push the repository"
    it "should move the directory's .git directory back to stash-directory-repository"    
  end
end
