module Reflection
  module Directory
    class Base
      
      attr_accessor :path
      
      def initialize(new_path)
        self.path = new_path
      end
      
      def to_s
        self.path
      end
      
      def exists?
        File.exist?(self.path)
      end
      
      def parent
        Base.new(File.expand_path(self.path.split('/')[0..-2].join('/')))
      end
      
      def name
        self.path.split('/').last
      end
      
      def git_index
        File.expand_path(File.join(self.path, '.git'))
      end
    end
  end
end