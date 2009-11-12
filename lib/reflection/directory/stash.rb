module Reflection
  module Directory
    class Stash < Directory::Base
    
      attr_accessor :repository
    
      def initialize(repository)
        @repository = repository
      end
    
      def path
        @path = File.join(Reflection.home.path, repository.identifier)
      end
    
      def exists?
        File.exist?(self.path)
      end
    
      def validate_repository
        if Reflection::Repository.exists?(self.path) && !@repository.same_in_path?(self.path)
          Reflection::Support.exit_with_error "The stash directory '#{self.path}' is a repository, but not the one you specified (--repository)."
        else
          Reflection.log.debug "Directory '#{self.path}' valid."
        end
      end
    
      def clone_repository
        Reflection.log.debug "Cloning repository '#{self.repository.url}' to '#{self.path}'"      
        @repository.clone(self.path)
      end
    end
  end
end