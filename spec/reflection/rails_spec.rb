require File.dirname(__FILE__) + '/../spec_helper'

describe Reflection::Rails do
  before(:each) do
    @config = OpenStruct.new({ :rails_root => '/rails_root/', :rails_environment => 'development' })
    @rails = Reflection::Rails
  end
  
  describe 'validate_environment' do
    it "should fail if the specified environment does't exist" do
      Reflection::Support.should_receive(:exit_with_error)
      File.stub!(:exist?).and_return(false)
      @rails.validate_environment(@config)
    end
  end
  
  describe 'read_database_configuration' do
    it 'should read the configuration for the specified environment' do
      db_config = { "host" => "localhost", "username" => "root" }
      YAML.should_receive(:load_file).with('/rails_root/config/database.yml').and_return({ "production" => {}, "development" => db_config })
      db_config = @rails.read_database_configuration(@config)
      db_config.should == db_config
    end
    
    it "should log an error and return false if the environment isn't configured" do
      Reflection.log.should_receive(:error).with(/available/)
      YAML.stub!(:load_file).and_return({ "production" => {} })
      @rails.read_database_configuration(@config).should be_false
    end
    
    it "should log an error and return false if the database.yml cannot be found" do
      Reflection.log.should_receive(:error).with(/Error/)
      YAML.stub!(:load_file).and_raise(StandardError)
      @rails.read_database_configuration(@config).should be_false
    end
  end
  
  describe 'database_command_line_options' do
    before(:each) do
      @db_config = { "host" => "localhost", "database" => "test", "username" => "root", "password" => "secret" }
    end
    
    it 'should create options for the mysql command' do
      @rails.database_command_line_options(@db_config).should == "-h localhost -u root -p secret test"
    end
    
    it 'should ignore the password option if its not available' do
      @db_config['password'] = ""
      @rails.database_command_line_options(@db_config).should == "-h localhost -u root test"

      @db_config['password'] = nil
      @rails.database_command_line_options(@db_config).should == "-h localhost -u root test"
    end
  end
end