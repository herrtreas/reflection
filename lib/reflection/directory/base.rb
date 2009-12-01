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
      
      def clean!
        Reflection.log.debug "Cleaning #{self.path}/.."
        %x(rm -r #{self.path}/*)
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
      
      def copy_git_index_to(target_path)
        Reflection.log.debug "Copying git-index '#{self.git_index}' to #{target_path}"
        %x(cp -R #{self.git_index} #{target_path})
      end
      
      def get_git_index_from(target_path)
        Reflection.log.debug "Getting git-index from #{target_path}"
        
        %x(rm -rf #{self.git_index}) if File.exists?(self.git_index)
        %x(mkdir -p #{self.path})
        %x(mv -f #{File.join(target_path, '/.git')} #{File.join(self.path, "/")})
      end
      
      def move_content_to(target_path)
        Reflection.log.debug "Moving content to '#{target_path}'.."
        %x(mv #{File.join(self.path, '/*')} #{File.join(target_path, '/')})
        # %x(cp -R #{File.join(self.path, '/.')} #{target_path})
        # %x(rm -rf #{self.path})
      end
      
    end
  end
end