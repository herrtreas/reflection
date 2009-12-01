module Reflection
  module Command
    class Apply < Reflection::Command::Base

      def validate!
        validate.existence_of config.directory
        if config.rails_root
          validate.existence_of config.rails_root
          Reflection::Rails.validate_environment(config)
        end
      end

      def run!
        stash_directory = Directory::Stash.new(Reflection::Repository.new(config.repository), 'apply')
        target_directory = Directory::Base.new(config.directory)

        unless config.force
          get_user_approval_for_cleaning_target(target_directory)
          get_user_approval_for_apply_database_dump if config.rails_root
        end
        
        verify_that_target_is_not_a_repository(target_directory)

        Reflection.log.info "Applying '#{config.repository}' >> '#{config.directory}'.."

        target_directory.clean!

        if stash_directory.exists?
          stash_directory.validate_repository
          stash_directory.copy_git_index_to(target_directory.path)
          repo = Repository.new_from_path(target_directory.path)
          repo.reset!
          repo.pull
          stash_directory.get_git_index_from(target_directory.path)
        else
          stash_directory.clone_repository
          stash_directory.move_content_to(target_directory.path)
          # stash_directory.get_git_index_from(target_directory.path)
        end

        Reflection::Rails.apply(config, target_directory)
        Reflection.log.info "Apply Command done."
      end


      private

        def get_user_approval_for_cleaning_target(target_directory)          
          puts "\nIn order to get a fresh copy of your files, "
          puts "Reflection will have to remove all files under '#{target_directory.path}'."
          puts "If you are sure, hit <enter> to proceed.."
          
          unless STDIN.getc == 10
            puts "Aborting.."
            exit
          end
        end

        def get_user_approval_for_apply_database_dump
          puts "\nCaution: You've enabled Rails database dumping/applying."
          puts "In order to apply a fresh dump, Reflection will override your database."
          puts "If you are sure, hit <enter> to proceed.."

          unless STDIN.getc == 10
            puts "Aborting.."
            exit
          end
        end
    end
  end
end
