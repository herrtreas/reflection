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
    
    def clone(path)
      Git.clone(self.url, path)
    end
    
    def commit_all_new_files(commit_files_path)
      repo = Git.open(self.path)
      Reflection.log.debug "Committing all changes.."
      Reflection.log.debug(repo.add(commit_files_path))
      Reflection.log.debug(repo.commit_all("Updated stash.")) rescue true
    end
    
    def push
      repo = Git.open(self.path)
      Reflection.log.debug "Pushing commit.."
      Reflection.log.debug(repo.push)
    end
  end
end