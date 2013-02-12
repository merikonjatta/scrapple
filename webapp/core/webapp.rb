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
      set :content_dir, File.expand_path(ENV['CONTENT_DIR'])

      # Require all init.rb scripts in plugins dir
      Dir[settings.root + "/plugins/**/init.rb"].each do |script|
        require script
      end
    end

    get '/compund' do
      'Compund'
    end

    get '/' do
      process nil
    end

    get '/*' do |path|
      process path
    end

    get '/*/*' do |path, handler_name|
      process path, handler_name
    end

    get '/*/*/*' do |path, handler_name, action|
      process path, handler_name, action
    end


    def process(path=nil, handler_name=nil, action=nil)
      @file = find_file(path)
      @handler_name ||= "default"
      @action ||= "view"
      body self.class.handlers[@handler_name].send(@action, @file)
    end


    def find_file(path=nil)
      file = nil
      if path.blank?
        file = Dir[File.join(settings.content_dir, "index.*")].first
      else
        file = File.join(settings.content_dir, path)
      end

      unless File.exist?(file)
        file = Dir[File.join(settings.content_dir, "#{path}.*")].first
      end

      raise Sinatra::NotFound unless File.exist?(file)

      return file
    end

  end
end
