module Reflection
  module Rails
    class << self
      
      def validate_environment(config)
        env_file_path = File.join(config.rails_root, 'config/environments', "#{config.rails_environment}.rb")
        unless File.exist?(env_file_path)
          Reflection::Support.exit_with_error("Rails environment '#{config.rails_environment}' doesn't exist in #{env_file_path}.")
        end
      end
      
      def clean_target(target_directory)
        target_file_path = File.join(target_directory.path, '_rails_database_dump.sql')
        if File.exist?(target_file_path)
          %x(rm #{target_file_path})          
        end
      end
      
      def database_command_line_options(database_config)
        options = []
        options <<  "-h #{database_config['host']}"
        options <<  "-u#{database_config['username']}"
        options <<  "-p#{database_config['password']}" if database_config['password'] && !database_config['password'].empty?
        options <<  "#{database_config['database']}"
        options.join(' ')
      end
      
      def read_database_configuration(config)
        begin
          database_path = File.join(config.rails_root, "config/database.yml")
          if db_config = YAML.load_file(database_path)[config.rails_environment]
            return db_config
          else
            Reflection.log.error("Rails database configuration for '#{config.rails_environment}' isn't available in #{database_path}")
            return false
          end
        rescue => e
          Reflection.log.error("Error while parsing Rails database configuration: #{e}")
          return false
        end
      end
      
      def stash(config, target_directory)
        Reflection.log.debug "Stashing database dump.."
        return unless database_config = read_database_configuration(config)
        options = database_command_line_options(database_config)
        target_file_path = File.join(target_directory.path, '_rails_database_dump.sql')
        %x(mysqldump #{options} --add-drop-table > #{target_file_path})
      end
    
      def apply(config, target_directory)
        Reflection.log.debug "Applying database dump.."        
        return unless database_config = read_database_configuration(config)
        options = database_command_line_options(database_config)
        target_file_path = File.join(target_directory.path, '_rails_database_dump.sql')
        %x(mysql #{options} < #{target_file_path})
        clean_target(target_directory)
      end
      
    end
  end
end