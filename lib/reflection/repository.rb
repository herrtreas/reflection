require 'digest/md5'
require 'git'

module Reflection
  class Repository
    
    attr_accessor :url
    
    def self.exists?(path)
      begin
        Git.open(path)
      rescue ArgumentError
        return false
      end      
    end
    
    def initialize(new_url)
      self.url = new_url
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
  end
end