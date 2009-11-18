require 'rubygems'

module Reflection
  autoload :CLI,              'reflection/cli'
  autoload :Config,           'reflection/config'
  autoload :Command,          'reflection/command'
  autoload :Directory,        'reflection/directory'
  autoload :Rails,            'reflection/rails'
  autoload :Repository,       'reflection/repository'
  autoload :Support,          'reflection/support'
  autoload :Validations,      'reflection/validations'
  
  class << self
    
    attr_accessor :home
    attr_accessor :log
    attr_accessor :verbose
    
    def boot!(args)
      @log = Reflection::Support::Log.new
      @home = Reflection::Support::Home.new
      @home.create
      Reflection::CLI.run!(args)
    end
    
  end
end