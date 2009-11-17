require File.dirname(__FILE__) + '/../spec_helper'

describe Reflection::Config do
  before(:each) do
    @valid_options = { :command => :stash, :repository => 'repo', :directory => 'dir' }
  end
  
  describe 'parse' do
    before(:each) do
      @mock_config = mock('Reflection::Config', :store_configuration_path => nil)
      Reflection::Config.stub!(:new).and_return(@mock_config)
    end
    
    it 'should parse a yaml file if the first arg is an existing file' do
      @mock_config.should_receive(:read!).with('/tmp')
      Reflection::Config.parse(['/tmp'])
    end
    
    it 'should parse args as options' do
      @mock_config.should_receive(:parse_command_line_options).with(['-s', '-d'])
      Reflection::Config.parse(['-s', '-d'])
    end

    it 'should write options to configuration file if --write params is set' do
      @mock_config.should_receive(:write).with('/test/path')
      @mock_config.stub!(:parse_command_line_options)
      @mock_config.stub!(:store_configuration_path).and_return('/test/path')
      Reflection::Config.parse(['-s','-d', '--write /test/path'])
    end

    it 'should expect a reflection.yml config file in path if args are empty' do
      Dir.stub!(:pwd).and_return('/current_dir')
      @mock_config.should_receive(:read!).with('/current_dir/reflection.yml')
      Reflection::Config.parse
    end    
  end

  describe '#to_hash' do
    it 'should turn its attributes into a hash' do
      @config = Reflection::Config.new
      @config.command = :stash
      @config.repository = 'repo'
      @config.directory = 'dir'
      @config.to_hash.should == @valid_options
    end
  end
  
  describe '#from_hash' do
    it 'should assign attributes from a hash' do
      @config = Reflection::Config.new
      @config.from_hash( @valid_options )
      @config.command.should eql(:stash)
      @config.repository.should eql('repo')
      @config.directory.should eql('dir')
    end
  end
  
  describe '#write' do
    before(:each) do
      @config = Reflection::Config.new
      @mock_file = mock('File')
      @mock_file.stub!(:close)
    end
    
    it 'should dump the config values to a file at the given path' do
      @config.stub!(:to_hash).and_return( @valid_options )
      YAML.should_receive(:dump).with( @valid_options, @mock_file )
      File.should_receive(:open).with('/test/path', 'w').and_return(@mock_file)
      @config.write('/test/path')
    end
    
    it 'should gracefully fail if it cannot dump the yaml file' do
      Reflection::Support.should_receive(:exit_with_error)
      File.should_receive(:open).with('/test/path', 'w').and_raise(StandardError)
      @config.write('/test/path')
    end
  end

  describe '#read!' do
    before(:each) do
      File.stub!(:exist?).and_return(true)
      @config = Reflection::Config.new
    end
    
    it 'should get the config attributes from a yaml file' do
      YAML.should_receive(:load_file).with('/tmp/test').and_return( @valid_options )
      @config.should_receive(:from_hash).with(@valid_options)
      @config.read!('/tmp/test')
    end
    
    it "should not try to load a yaml file if it doesn't exist" do
      YAML.should_not_receive(:load_file)
      File.stub!(:exist?).and_return(false)
      @config.read!('/tmp/test')
    end
    
    it "should gracefully fail if yaml file loading crashed" do
      Reflection::Support.should_receive(:exit_with_error)
      YAML.stub!(:load_file).and_raise(StandardError)
      @config.read!('/tmp/test')
    end
    
    it "should gracefully fail if parsing result is not a hash" do
      Reflection::Support.should_receive(:exit_with_error)
      YAML.stub!(:load_file).and_return("String Instead Of Hash")
      @config.read!('/tmp/test')
    end
  end
  
end
