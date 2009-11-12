module Reflection
  module Validations
    class << self
      
      def existence_of(path)        
        if File.exist?(path)
          return true
        else
          Reflection::Support.exit_with_error "Option validation failed: #{path} does not exist."
        end
      end
      
      # def presense_of(option)
      #   if !option.nil? && !option.empty?
      #     return true
      #   else
      #     exit_with_error "Option validation failed: "
      #   end
      # end
      
    end
  end
end