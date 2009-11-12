module Reflection
  module Support
    class Home
      
      def path
        @path ||= File.expand_path(File.join(ENV['HOME'], '.reflection'))
      end
      
      def create
        unless File.exist?(self.path)
          Dir.mkdir(self.path)
        end
      end
      
    end
  end
end