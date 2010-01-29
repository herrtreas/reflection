module Reflection
  module Rails
    class Database

      attr_accessor :configuration
      attr_accessor :environment
      attr_accessor :rails_root

      def initialize(new_rails_root, new_environment)
        self.rails_root = new_rails_root
        self.environment = new_environment
        self.configuration = read_configuration_yml
      end

      def dump_to_directory(target_directory)
        Reflection.log.debug "dumping database.."
        run "mysqldump #{command_line_options} --skip-lock-tables > #{dump_file_path(target_directory)}"
      end

      def load_dump_from_file(target_directory)
        Reflection.log.debug "Loading dump.."
        run("mysql #{command_line_options(:no_rehash => true)} < #{dump_file_path(target_directory)}")
      end

      def clean_dump_file(target_directory)
        dump_file = dump_file_path(target_directory)
        if File.exist?(dump_file)
          run "rm #{dump_file}"
        end
      end

      def recreate!
        Reflection.log.debug "Recreating database.."
        drop
        create
      end
      
      def create
        run("echo \"CREATE DATABASE #{self.configuration['database']};\" | mysql #{command_line_options(:skip => :database)}")
      end
      
      def drop
        run("echo \"DROP DATABASE #{self.configuration['database']};\" | mysql #{command_line_options(:skip => :database)}")
      end
      
      def migrate!
        Reflection.log.debug "Migrating database.."
        run("(cd #{self.rails_root} && RAILS_ENV=#{self.environment} rake db:migrate)")
      end

      def read_configuration_yml
        begin
          if configuration = YAML.load_file(database_config_file_path)[self.environment]
            return configuration
          else
            return Support.exit_with_error("Rails database configuration for '#{self.environment}' isn't available in #{database_config_file_path}")
          end
        rescue => e
          return Support.exit_with_error("Error while parsing Rails database configuration: #{e}")
        end
      end

      def command_line_options(opts = {})
        options = []
        options <<  "-A" if opts[:no_rehash] && opts[:no_rehash] == true
        options <<  "-h #{configuration['host']}" if configuration['host'] && !configuration['host'].empty?
        options <<  "-u#{configuration['username']}"
        options <<  "-p#{configuration['password']}" if configuration['password'] && !configuration['password'].empty?
        options <<  "#{configuration['database']}" unless opts[:skip] && opts[:skip] == :database
        options.join(' ')
      end

      def run(command)
        # Reflection.log.debug "-- #{command}"
        %x(#{command})
      end
      

      private

        def log_error_and_return_false(message)
          Reflection.log.error(message)
          return false
        end

        def database_config_file_path
          @database_config_file_path ||= File.join(self.rails_root, "config/database.yml")
        end
        
        def dump_file_path(directory)
          File.join(directory, "_rails_database_dump.sql")
        end
        
    end
  end
end
