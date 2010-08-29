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
  
  describe 'stash' do
    before(:each) do
      @mock_target = mock('Reflection::Directory', :path => 'target')
      @mock_database = mock('Reflection::Rails::Database')
      Reflection::Rails::Database.stub!(:new).and_return(@mock_database)
    end
    
    it 'should should dump the database to the target directory' do
      @mock_database.should_receive(:dump_to_directory).with('target')
      @rails.stash(@config, @mock_target)
    end
  end
  
  describe 'apply' do
    before(:each) do
      @mock_target = mock('Reflection::Directory', :path => 'target')
      @mock_database = mock('Reflection::Rails::Database')
      @mock_database.stub!(:recreate!)
      @mock_database.stub!(:load_dump_from_file)
      @mock_database.stub!(:clean_dump_file)
      @mock_database.stub!(:migrate!)
      Reflection::Rails::Database.stub!(:new).and_return(@mock_database)
    end
    
    it 'should recreate the database before apply a dump' do
      @mock_database.should_receive(:recreate!)
      @rails.apply(@config, @mock_target)
    end
    
    it 'should should load the dump from the target directory into the database' do
      @mock_database.should_receive(:load_dump_from_file).with('target')
      @rails.apply(@config, @mock_target)
    end

    it 'should should remove the dump file from target' do
      @mock_database.should_receive(:clean_dump_file).with('target')
      @rails.apply(@config, @mock_target)
    end

    it 'should should migrate the database after applying a dump' do
      @mock_database.should_receive(:migrate!)
      @rails.apply(@config, @mock_target)
    end

    it 'should not should migrate the database after applying a dump when skip-migration is set' do
      @config.skip_migration = true
      @mock_database.should_not_receive(:migrate!)
      @rails.apply(@config, @mock_target)
    end
  end
  
end