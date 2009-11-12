module Reflection
  module Support
    
    autoload :Home, 'reflection/support/home'
    autoload :Log,  'reflection/support/log'      
    
    def self.exit_with_error(message)
      puts message
      exit(1)
    end
  end
end