$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'reflection'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  config.before(:each) do
    @global_mock_log = mock('Log')
    @global_mock_log.stub!(:debug)
    @global_mock_log.stub!(:info)
    Reflection.stub!(:log).and_return(@global_mock_log)
  end
end
