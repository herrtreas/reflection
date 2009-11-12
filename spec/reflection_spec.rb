require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Reflection" do
  
  describe '#boot' do
    before(:each) do
      Reflection::CLI.stub!(:run!)
    end
    
    it 'should init a Home instance which represents ~/.reflection' do
      Reflection.boot!([])
      Reflection.home.should be_kind_of(Reflection::Support::Home)
    end
    
    it 'should run the CLI processor' do
      Reflection::CLI.should_receive(:run!).with(['args'])
      Reflection.boot!(['args'])
    end
  end
  
end
