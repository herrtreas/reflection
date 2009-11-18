module Reflection
  module Support
    class Log
      
      def debug(message)
        puts "** #{message}" if message && !message.empty?
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