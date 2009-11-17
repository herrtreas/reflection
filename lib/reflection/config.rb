require 'optparse'
require 'ostruct'

module Reflection
  class Config
    
    attr_accessor :command
    attr_accessor :directory
    attr_accessor :repository
    
    def self.parse(args)
      config = Config.new
      config.parse_options(args)
      config
    end

    def parse_options(args)
      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: reflection --COMMAND --repository=GIT_REPO --directory=PATH"

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
      end

      opt_parser.parse!(args)
    end

  end
end
