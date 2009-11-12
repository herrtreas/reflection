require File.dirname(__FILE__) + '/../spec_helper'

describe Reflection::Repository do
  before(:all) do
    @test_git_url = 'git.rubyphunk.com:test.git'
    @test_identifier = 'f5c4e386bcf8339e4b6e5c15c22e5b97'
  end
  
  before(:each) do
    @repository = Reflection::Repository.new(@test_git_url)
    @mock_git_repo = mock('Git::Base')
    @mock_git_repo.stub!(:remote).and_return(@mock_remote = mock('Git::Remote'))
  end
  
  describe 'new_from_path' do
    it 'should create an instance by path' do
      Git.stub!(:open).and_return(@mock_git_repo)
      @mock_remote.stub!(:url).and_return('git@example.com:repo.git')
      instance = Reflection::Repository.new_from_path('/test/repo/path')
      instance.should be_instance_of(Reflection::Repository)
      instance.url.should eql('git@example.com:repo.git')
    end
    
    it 'should raise an error if path is not a valid git repository' do
      lambda do
        Reflection::Repository.stub!(:exists?).and_return(false)
        Reflection::Repository.new_from_path('/test/repo/path')
      end.should raise_error(/not a valid/)
    end
  end
  
  describe 'exists?' do
    it 'should return true if a repository exists in path' do
      Git.should_receive(:open).with('/test/path').and_return(@mock_git_repo)
      @mock_remote.stub!(:url).and_return(@test_git_url)
      Reflection::Repository.exists?('/test/path').should be_true
    end

    it 'should return false if the path is not a repository' do
      Git.should_receive(:open).with('/test/path').and_raise(ArgumentError)
      Reflection::Repository.exists?('/test/path').should be_false
    end
  end
  
  describe '#identifier' do
    it 'should return an md5 hash of the repository url' do
      @repository.identifier.should eql(@test_identifier)
    end
  end
  
  describe '#same_in_path?' do
    it 'should return true if the path is a repository with the repositories url' do
      Git.should_receive(:open).with('/test/path').and_return(@mock_git_repo)
      @mock_remote.stub!(:url).and_return(@test_git_url)
      @repository.same_in_path?('/test/path').should be_true
    end
    
    it 'should return false if the path is a repository but has no remote' do
      Git.should_receive(:open).with('/test/path').and_return(@mock_git_repo)
      @mock_git_repo.stub!(:remote).and_return(nil)
      @repository.same_in_path?('/test/path').should be_false
    end    
  end
  
  describe '#clone' do
    it 'should clone the reposity to a path' do
      Git.should_receive(:clone).with(@test_git_url, '/test/path')
      @repository.clone('/test/path')
    end
  end
end