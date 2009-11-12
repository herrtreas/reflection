require 'fileutils'

module Reflection
  module Command
    class Stash < Reflection::Command::Base

      def validate!
        validate.existence_of options.directory
      end

      def run!
        Reflection.log.info "Stashing '#{options.directory}'.."

        if Reflection::Repository.exists?(options.directory) || Reflection::Repository.exists?(asset_directory_path(options.directory))
          Reflection::Support.exit_with_error "The specified --directory is a repository. Reflection is afraid of breaking something, so it won't touch it. Pleace specify another one.."
        end

        stash_directory = Reflection::Directory::Stash.new(Reflection::Repository.new(options.repository))

        prepare_stash_repository(stash_directory)
        stash_directory_into_repository(stash_directory)

        Reflection.log.info "Stash Command done."
      end

      def prepare_stash_repository(directory)
        Reflection.log.debug "Preparing stash repository.."

        if directory.exists?
          directory.validate_repository
        else
          directory.clone_repository
        end
      end

      def stash_directory_into_repository(directory)
        asset_repository_path = File.expand_path(parent_directory_path(options.directory))
        FileUtils.cp_r(File.join(directory.path, '.git'), asset_repository_path)
        asset_repo = Git.open(asset_repository_path)
        
        #directory.repository.add_and_commit_files()
        Reflection.log.debug "Committing all changes.."
        Reflection.log.debug(asset_repo.add(asset_directory_path(options.directory)))
        Reflection.log.debug(asset_repo.commit_all("Updated stash.")) rescue true
        
        Reflection.log.debug "Pushing commit.."
        Reflection.log.debug(asset_repo.push)
        
        FileUtils.rm_r(File.join(directory.path, "/.git"))
        FileUtils.mv(File.join(asset_repository_path, '.git'), directory.path)
      end


      private

        # FIXME: Find a better solution ;)
        def parent_directory_path(path)
          path.split('/')[0..-2].join('/')
        end
        
        def asset_directory_path(path)
          path.split('/').last
        end
    end
  end
end
