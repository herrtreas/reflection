require 'optparse'
require 'ostruct'
require 'yaml'

module Reflection

  class ConfigArgumentError < StandardError; end

  class Config
    
    attr_accessor :command
    attr_accessor :directory
    attr_accessor :repository
    attr_accessor :rails_root
    attr_accessor :rails_environment
    attr_accessor :store_configuration_path
    attr_accessor :verbose
    attr_accessor :force
    
    def self.parse(args = [])
      config = Config.new
      case
        when !args.empty? && File.exists?(args.first)
          config.read!(args.first)
        when !args.empty?
          config.parse_command_line_options(args)
          config.write(config.store_configuration_path) if config.store_configuration_path
        else
          config.read!(File.join(Dir.pwd, 'reflection.yml'))
      end
      config
    end

    def to_hash
      { 
        :command => self.command, 
        :directory => self.directory,
        :repository => self.repository, 
        :rails_root => self.rails_root,
        :rails_environment => self.rails_environment,
        :verbose => self.verbose,
        :force => self.force
      }
    end
    
    def from_hash(hash)
      self.command = hash[:command]
      self.directory = hash[:directory]
      self.repository = hash[:repository]
      self.rails_root = hash[:rails_root]
      self.rails_environment = hash[:rails_environment]
      self.verbose = Reflection.verbose = hash[:verbose]
      self.force = hash[:force]
    end

    def write(path)
      begin
        io = File.open(path, 'w')
        YAML.dump(self.to_hash, io)
        io.close
      rescue => e
        Reflection::Support.exit_with_error("Writing of config file to '#{path}' failed: #{e.message}")
      end
    end

    def read!(path)
      begin
        if File.exist?(path)
          options = YAML.load_file(path)
          raise(Reflection::ConfigArgumentError, "Config file is invalid.") unless options.is_a?(Hash)
          self.from_hash(options)
        end
      rescue => e
        Reflection::Support.exit_with_error("Parsing of config file '#{path}' failed: #{e.message}")
      end
    end

    def parse_command_line_options(args)
      opt_parser = OptionParser.new do |opts|
        opts.banner =   "Usage: reflection --COMMAND --repository=GIT_REPO --directory=PATH\n"
        opts.banner <<  " -or-\n"
        opts.banner <<  "Usage: reflection /path/to/reflection-config-file.yml"
        
        opts.separator " "
        opts.separator "On the server side:"

        opts.on("-s", "--stash", "Store your assets and/or a database dump in a git-repository.") do |stash|
          self.command = :stash
        end

        opts.separator "On the client side:"
        opts.on("-a", "--apply", "Apply assets and/or a database dump loaded from a git-repository.") do |apply|
          self.command = :apply
        end

        opts.separator " "
        opts.separator "Required options for both:"
        opts.on("-r", "--repository GIT_URL", "A Git repository(url) to be used as storage") do |repository|
          self.repository = repository
        end

        opts.on("-d", "--directory PATH", "Path to your asset directory") do |directory|
          self.directory = directory
        end

        opts.separator " "
        opts.separator "Additional options for both:"

        opts.on("--rails [RAILS_ROOT]", "Enable dumping/applying of a Rails managed MySQL database") do |path|
          self.rails_root = path || nil
        end        

        opts.on("--rails-env [ENV]", "Rails environment to instrument") do |environment|
          self.rails_environment = environment || nil
        end        
        
        opts.on("--write [FILE]", "Create a configuration FILE from the current commandline options") do |config_file_path|
          self.store_configuration_path = config_file_path if config_file_path
        end

        opts.on("-v", "--verbose", "Include debug information in output") do
          self.verbose = true
          Reflection.verbose = true
        end

        opts.on("--force", "Hide tedious warnings") do
          self.force = true
        end
      end

      opt_parser.parse!(args)
    end

  end
end
