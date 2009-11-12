require 'optparse'
require 'ostruct'

module Reflection
  module CLI
    class << self

      def run!(args = nil)
        options = parse_options(args)
        if options == false
          Reflection::Support.exit_with_error("Ahh ja, missing arguments. Please read 'reflection --help' to get a feeling of how it works.")
        else
          case options.command
          when :apply
            Reflection::Command::Apply.run!(options)
          when :stash
            Reflection::Command::Stash.run!(options)
          else
            Reflection::Support.exit_with_error("Couldn't identify command. Please run 'reflection --help'.")
          end
        end
      end

      def parse_options(args)
        options = OpenStruct.new

        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: reflection --COMMAND --repository=GIT_REPO --directory=PATH"

          opts.separator " "
          opts.separator "On the server side:"

          opts.on("-s", "--stash", "Store your assets and/or a database dump in a git-repository.") do |stash|
            options.command = :stash
          end

          opts.separator "On the client side:"
          opts.on("-a", "--apply", "Apply assets and/or a database dump loaded from a git-repository.") do |apply|
            options.command = :apply
          end

          opts.separator " "
          opts.separator "Required options for both:"
          opts.on("-r", "--repository GIT_URL", "A Git repository(url) to be used as storage") do |repository|
            options.repository = repository
          end

          opts.on("-d", "--directory PATH", "Path to your asset directory") do |directory|
            options.directory = directory
          end
        end

        opt_parser.parse!(args)
        verify_options(options)
      end


      private

        def verify_options(options)
          return ([:stash, :apply].include?(options.command) && !options.repository.nil? && !options.directory.nil?) ? options : false
        end
    end
  end
end
