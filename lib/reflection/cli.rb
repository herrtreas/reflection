module Reflection
  module CLI
    class << self

      def run!(args = nil)
        config = Reflection::Config.parse(args)
        
        if config.command == :show_version
          puts "Version: #{Reflection.version}"
          exit
        end
        
        if verify_config(config) == false
          Reflection::Support.exit_with_error("Missing arguments. Please read 'reflection --help' to get a feeling of how it works.")
        else
          case config.command
            when :apply
              Reflection::Command::Apply.run!(config)
            when :stash
              Reflection::Command::Stash.run!(config)
            else
              Reflection::Support.exit_with_error("Couldn't identify command. Please run 'reflection --help'.")
          end
        end
      end


      private

        def verify_config(config)
          return ([:stash, :apply].include?(config.command) && !config.repository.nil? && !config.directory.nil?) ? config : false
        end
    end
  end
end
