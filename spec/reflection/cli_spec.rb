require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Reflection::CLI do
  before(:all) do
    @subject = Reflection::CLI
  end
  
  describe '#run!' do
    before(:each) do
      @config = mock('Reflection::Config', :command => :stash)
      Reflection::Config.stub!(:parse).and_return(@config)
      @subject.stub!(:verify_config).and_return(true)
    end
    
    it 'should create a config object, holding the parsed commandline options' do
      Reflection::Config.should_receive(:parse).with("args").and_return(@config)
      Reflection::Command::Stash.stub!(:run!)
      @subject.run!("args")
    end
    
    it 'should verify the config and fail gracefully displaying a message if verification fails' do
      Reflection::Support.should_receive(:exit_with_error).with(/reflection --help/)
      @subject.stub!(:verify_config).and_return(false)
      @subject.run!("args")
    end
    
    context 'successfully parsed options' do
      it 'should call the Stash command if parse_options returned succesfull with command :stash' do
        Reflection::Command::Stash.should_receive(:run!).with(@config)
        @config.stub!(:command).and_return(:stash)
        @subject.run!
      end

      it 'should call the Apply command if parse_options returned succesfull with command :apply' do
        Reflection::Command::Apply.should_receive(:run!).with(@config)
        @config.stub!(:command).and_return(:apply)
        @subject.run!
      end
    end
  end  
end
