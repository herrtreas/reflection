require File.dirname(__FILE__) + '/../../spec_helper'

describe Reflection::Rails::Database do
  before(:each) do
    YAML.stub!(:load_file).and_return({ 'development' => {} })
    @database = Reflection::Rails::Database.new('/rails_root', 'development')
  end
  
  describe '#initialize' do
    it 'should read the configuration file during init' do
      YAML.should_receive(:load_file)
      Reflection::Rails::Database.new('/rails_root', 'development')
    end
    
    it 'should exit with error if initialization failed' do
      Reflection::Support.should_receive(:exit_with_error)
      YAML.stub!(:load_file).and_raise(StandardError)
      Reflection::Rails::Database.new('/rails_root', 'development')
    end
  end
  
  describe '#create' do
    before(:each) do
      @database.configuration = { "database" => "test" }
      @database.stub!(:command_line_options).and_return('options')
    end
    
    it 'should create the database' do
      @database.should_receive(:run).with(/^echo "CREATE DATABASE test;"/)
      @database.create
    end
  end

  describe '#drop' do
    before(:each) do
      @database.configuration = { "database" => "test" }
      @database.stub!(:command_line_options).and_return('options')
    end
    
    it 'should drop the database' do
      @database.should_receive(:run).with(/^echo "DROP DATABASE test;"/)
      @database.drop
    end
  end
  
  describe '#recreate!' do
    before(:each) do
      @database.stub!(:create)
      @database.stub!(:drop)
    end
    
    it 'should drop the database' do
      @database.should_receive(:drop)
      @database.recreate!
    end
  
    it 'should create the database' do
      @database.should_receive(:create)
      @database.recreate!
    end
  end
  
  describe '#migrate' do
    before(:each) do
    end
    
    it 'should run the migrate command' do
      @database.should_receive(:run).with(/rake db:migrate/)
      @database.migrate
    end
    
    it 'should temporarily cd into the rails root' do
      @database.should_receive(:run).with(/cd \/rails_root/)
      @database.migrate
    end
    
    it 'should instrument the specified environment' do
      @database.should_receive(:run).with(/RAILS_ENV=development/)
      @database.migrate
    end
  end
  
  describe '#dump_to_directory' do
    before(:each) do
      @database.stub!(:command_line_options).and_return('options')
    end
    
    it 'should dump the database into the target directory' do
      @database.should_receive(:run).with(/mysqldump options/)
      @database.dump_to_directory('path')
    end
    
    it 'should dump the database into a special dump file' do
      @database.should_receive(:run).with(/> path\/_rails_database_dump.sql$/)
      @database.dump_to_directory('path')
    end    
  end
  
  describe '#load_dump_from_file' do
    before(:each) do
      @database.stub!(:command_line_options).and_return('options')
    end
    
    it 'should load the dump into the database' do
      @database.should_receive(:run).with(/mysql options/)
      @database.load_dump_from_file('path')
    end
    
    it 'should dump the database into a special dump file' do
      @database.should_receive(:run).with(/< path\/_rails_database_dump.sql$/)
      @database.load_dump_from_file('path')
    end    
  end
  
  describe '#read_configuration_yml' do
    before(:each) do
      @db_config = { "host" => "localhost", "username" => "root" }
    end
    
    it 'should read the configuration for the specified environment' do
      YAML.should_receive(:load_file).with('/rails_root/config/database.yml').and_return({ "production" => {}, "development" => @db_config })
      @database.read_configuration_yml.should == @db_config
    end
    
    it 'should not load the configuration twice' do
      YAML.should_receive(:load_file).once.and_return({ "production" => {}, "development" => @db_config })
      @database.read_configuration_yml
      @database.read_configuration_yml
    end
    
    it "should #exit_with_error if the environment isn't configured" do
      Reflection::Support.should_receive(:exit_with_error).with(/available/)
      YAML.stub!(:load_file).and_return({ "production" => {} })
      @database.read_configuration_yml
    end
    
    it "should #exit_with_error if the database.yml cannot be found" do
      Reflection::Support.should_receive(:exit_with_error).with(/Error/)
      YAML.stub!(:load_file).and_raise(StandardError)
      @database.read_configuration_yml
    end
  end
  
  describe '#command_line_options' do
    before(:each) do
      @database.configuration = { "host" => "localhost", "database" => "test", "username" => "root", "password" => "secret" }
    end
    
    it 'should create options for the mysql command' do
      @database.command_line_options.should == "-h localhost -uroot -psecret test"
    end
    
    it 'should ignore the password option if its not available' do
      @database.configuration['password'] = ""
      @database.command_line_options.should == "-h localhost -uroot test"
    
      @database.configuration['password'] = nil
      @database.command_line_options.should == "-h localhost -uroot test"
    end
  end
end
