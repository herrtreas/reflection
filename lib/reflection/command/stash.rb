module Reflection
  module Command
    class Stash < Reflection::Command::Base

      def validate!
        validate.existence_of config.directory
        if config.rails_root
          validate.existence_of config.rails_root
          Reflection::Rails.validate_environment(config)
        end
      end

      def run!
        Reflection.log.info "Stashing '#{config.directory}'.."

        stash_directory = Directory::Stash.new(Reflection::Repository.new(config.repository), 'stash')
        target_directory = Directory::Base.new(config.directory)

        verify_that_target_is_not_a_repository(target_directory)
        
        prepare_stash_repository(stash_directory)
        stash_directory_into_repository(stash_directory, target_directory)

        Reflection.log.info "Stash Command done."
      end

      def prepare_stash_repository(stash_directory)
        Reflection.log.debug "Preparing stash repository.."

        if stash_directory.exists?
          stash_directory.validate_repository
        else
          stash_directory.clone_repository
        end
      end

      def stash_directory_into_repository(stash_directory, target_directory)
        copy_stash_repository_git_index_to_target(stash_directory.git_index, target_directory.path)
        Reflection::Rails.stash(config, target_directory) if config.rails_root
        commit_and_push_files(target_directory.path, target_directory.name)
        move_stash_repository_git_index_back(target_directory.git_index, stash_directory.path)
        Reflection::Rails.clean_target(target_directory) if config.rails_root
      end


      private

        def copy_stash_repository_git_index_to_target(source, target)
          %x(cp -R #{source} #{target})
        end

        def commit_and_push_files(repository_path, target)
          repository = Repository.new_from_path(repository_path)
          repository.commit_all_new_files
          repository.push
        end

        def move_stash_repository_git_index_back(source, target)
          %x(rm -r #{File.join(target, "/.git")})
          %x(mv #{source} #{target})
        end

    end
  end
end
