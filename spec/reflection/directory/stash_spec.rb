require File.dirname(__FILE__) + '/../../spec_helper'

describe Reflection::Directory::Stash do
  before(:each) do
    Reflection.home = mock('Home', :path => '/HOME_DIR/.reflection')
    @mock_repository = mock("Repository", :identifier => '_identifier_', :url => 'git.rubyphunk.com')
    @stash_directory = Reflection::Directory::Stash.new(@mock_repository)
  end
  
  describe '#path' do
    it 'should generate the path to the stash repository-directory ~/.reflection/-md5_hash-' do
      @stash_directory.path.should eql("/HOME_DIR/.reflection/_identifier_")
    end
  end
  
  describe '#validate_repository' do
    before(:each) do
      Reflection::Repository.stub!(:exists?).and_return(true)
    end
    
    it 'should compare the existing repository with the instance' do
      @mock_repository.should_receive(:same_in_path?).and_return(true)
      @stash_directory.validate_repository
    end
    
    it 'should fail if the repository is not the existing one in the path' do
      Reflection::Support.should_receive(:exit_with_error)
      @mock_repository.stub!(:same_in_path?).and_return(false)
      @stash_directory.validate_repository
    end
  end
  
  describe '#clone_repository' do
    it 'should call clone on the repository instance' do
      @mock_repository.should_receive(:clone).with(@stash_directory.path)
      @stash_directory.clone_repository
    end
  end
end