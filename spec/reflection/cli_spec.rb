require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Reflection::CLI do
  before(:all) do
    @subject = Reflection::CLI
  end
  
  describe '#run!' do
    it 'should parse commandline options' do
      Reflection::Command::Stash.stub!(:run!)
      @subject.should_receive(:parse_options).and_return(OpenStruct.new(:command => :stash))
      @subject.run!
    end
    
    it 'should fail gracefully displaying a message if parse_options returns false' do
      Reflection::Support.should_receive(:exit_with_error).with(/reflection --help/)
      @subject.stub!(:parse_options).and_return(false)
      @subject.run!
    end
    
    context 'successful parsed options' do
      before(:each) do
        @parse_options = OpenStruct.new(:options => "more")
        @subject.stub!(:parse_options).and_return(@parse_options)
      end
      
      it 'should call the Stash command if parse_options returned succesfull with command :stash' do
        @parse_options.command = :stash
        Reflection::Command::Stash.should_receive(:run!).with(@parse_options)
        @subject.run!
      end

      it 'should call the Apply command if parse_options returned succesfull with command :apply' do
        @parse_options.command = :apply        
        Reflection::Command::Apply.should_receive(:run!).with(@parse_options)
        @subject.run!
      end
    end
  end  
end
