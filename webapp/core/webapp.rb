require 'sinatra/base'
require 'pathname'
require 'yaml'
require 'active_support/core_ext'
require 'pry'

module Compund
  class HandlerNotFound < Exception; end
  class ActionNotFound < Exception; end

  module Handlers; end
  module Plugins; end

  class Webapp < Sinatra::Base

    @handlers = {}

    class << self
      attr_reader :handlers

      def register_handler(mod, name)
        @handlers[name] = mod
      end
    end

    configure do
      set :root, File.expand_path("..", File.dirname(__FILE__))
      set :public_folder, File.join(settings.root, 'core', 'public')
      set :views, File.join(settings.root)
      set :content_dir, ENV['CONTENT_DIR']

      # Require all init.rb scripts in plugins dir
      Dir[settings.root + "/plugins/**/init.rb"].each do |script|
        require script
      end
    end

    get '/system' do
      'System'
    end

    get '/*/*/*' do |path, handler_name, action|
      request[:path] = File.join(settings.content_dir, path)
      raise Sinatra::NotFound unless File.exists?(request[:path])

      request[:handler_name] = handler_name || "default"
      request[:action] = action || "view"

      body self.class.handlers[request[:handler_name]].send(request[:action], request)
    end

  end
end
