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
    end
  end
end
