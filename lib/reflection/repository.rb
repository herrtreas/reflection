require 'digest/md5'
require 'git'

module Reflection
  class Repository
    
    attr_accessor :url
    attr_accessor :path
    
    def self.new_from_path(path)
      unless self.exists?(path)
        raise "'#{path}' is not a valid Git repository"
      end
      
      repo = Git.open(path)
      self.new(repo.remote.url, path)
    end
    
    def self.exists?(path)
      begin
        Git.open(path)
      rescue ArgumentError
        return false
      end      
    end
    
    def initialize(new_url, path = nil)
      self.url = new_url
      self.path = path
    end
    
    def identifier
      Digest::MD5.hexdigest(self.url)
    end
    
    def same_in_path?(path)
      git_repo = Git.open(path)
      (git_repo.remote && git_repo.remote.url == self.url) || false
    end
    
    def reset!
      Reflection.log.debug "Resetting target to HEAD"
      repo = Git.open(self.path)
      repo.reset_hard
    end
    
    def clone(path)
      Git.clone(self.url, path)
    end
    
    def commit_all_new_files
      repo = Git.open(self.path)
      Reflection.log.debug "Committing all changes.."
      Reflection.log.debug(repo.add)
      Reflection.log.debug(repo.commit_all("Updated stash.")) rescue true
    end
    
    def push
      # repo = Git.open(self.path)
      Reflection.log.debug "Pushing commit.."
      Reflection.log.debug(%x((cd #{self.path} && git push --force)))
      # Reflection.log.debug(repo.push)
    end
    
    def pull
      Reflection.log.debug "Pulling in #{self.path}.."
      Reflection.log.debug(%x((cd #{self.path} && git pull --rebase)))
    end
    
  end
end