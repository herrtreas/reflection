module Reflection
  module Support
    class Log
      
      attr_accessor :verbose
      
      def debug(message)
        puts "** #{message}" if Reflection.verbose == true && message && !message.empty?
      end
      
      def info(message)
        puts "** #{message}" if message && !message.empty?
      end
      
      def error(message)
        puts "!! #{message}" if message && !message.empty?
      end
    end
  end
end