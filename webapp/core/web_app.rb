require 'sinatra/base'
require 'pathname'
require 'yaml'
require 'active_support/core_ext'

module Compund
  class HandlerNotFound < Exception; end
  class ActionNotFound < Exception; end

  module Handlers; end
  module Plugins; end

  class WebApp < Sinatra::Base

    require 'pry' if development?

    def self.register_handler(name, mod)
      @@handlers ||= {}
      @@handlers[name] = mod
    end

    def handlers
      @@handlers ||= {}
    end

    def self.hook(point, options, &block)
      @@hooks ||= {}
      @@hooks[point] ||= []
      @@hooks[point].push({:options => options, :block => block})
    end

    def self.hooks_at(point)
      @@hooks ||= {}
      return @@hooks[point] || []
    end

    configure do
      set :root, File.expand_path("..", File.dirname(__FILE__))
      set :public_folder, File.join(settings.root, 'core', 'public')
      set :views, File.join(settings.root)

      # Load and normalize config.yml directives
      YAML.load_file(File.join(settings.root, 'config.yml')).each { |k,v| set k, v }
      unless Pathname.new(settings.content_dir).absolute?
        set :content_dir, File.expand_path(settings.content_dir, settings.root) 
      end

      # Require all init.rb scripts in plugins dir
      Dir[settings.root + "/plugins/**/init.rb"].each do |script|
        require script
      end
    end


    get '/system' do
      'System'
    end

    get '/*/*/*' do |path, handler_name, action|
      request[:path] = path
      request[:handler_name] = handler_name
      request[:action] = action
      request[:file_path] = File.join(settings.content_dir, path)
      request[:content] = File.open(request[:file_path]) { |f| f.read }
      raise Sinatra::NotFound unless File.exists?(request[:file_path])

      self.class.hooks_at(:before_render).each do |hook|
        hook[:block].call(self)
      end
      body request[:content]
    end

  end
end
