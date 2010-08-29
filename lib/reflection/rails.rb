module Reflection
  module Rails
    
    autoload :Database, 'reflection/rails/database'
    
    class << self
      
      def validate_environment(config)
        env_file_path = File.join(config.rails_root, 'config/environments', "#{config.rails_environment}.rb")
        unless File.exist?(env_file_path)
          Reflection::Support.exit_with_error("Rails environment '#{config.rails_environment}' doesn't exist in #{env_file_path}.")
        end
      end
      
      # TODO: 
      # Method is obsolete and has moved to Rails::Database
      # Cannot be removed atm because Command::Stash depends on it
      def clean_target(config, target_directory)
        database = Database.new(config.rails_root, config.rails_environment)
        database.clean_dump_file(target_directory.path)
      end
      
      def stash(config, target_directory)
        Reflection.log.debug "Stashing database dump.."
        database = Database.new(config.rails_root, config.rails_environment)
        database.dump_to_directory(target_directory.path)
      end
    
      def apply(config, target_directory)
        Reflection.log.debug "Applying database dump.."        
        database = Database.new(config.rails_root, config.rails_environment)
        database.recreate!
        database.load_dump_from_file(target_directory.path)
        database.clean_dump_file(target_directory.path)
        database.migrate! unless config.skip_migration
      end
      
    end
  end
end