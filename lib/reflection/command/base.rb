module Reflection
  module Command
    class Base
      attr_accessor :options
      
      def self.run!(options)
        command = self.new(options)
        command.validate! if command.respond_to?(:validate!)
        command.run!
      end
      
      def initialize(new_options)
        self.options = new_options
      end      
      
      def validate
        Reflection::Validations
      end
      
      def verify_that_target_is_not_a_repository(target_directory)
        if Repository.exists?(target_directory.path)
          Support.exit_with_error "The specified --directory is a repository. Reflection is afraid of breaking something, so it won't touch it. Pleace specify another one.."
        end
      end
      
    end
  end
end
