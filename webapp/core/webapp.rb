require 'sinatra/base'
require 'pathname'
require 'yaml'
require 'active_support/core_ext'
require 'pry'

require 'core/page'
require 'core/file_finder'
require 'core/file_parser'

module Compund
  class HandlerNotFound < Exception; end
  class FileNotFound < Exception; end

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
      set :content_dir, File.expand_path(ENV['CONTENT_DIR'])

      # Require all <plugin>.rb scripts in plugins dir
      Dir[settings.root + "/plugins/*"].each do |plugin_dir|
        plugin_name = plugin_dir.match(/.*\/(.*)$/)[1]
        require File.join(plugin_dir, plugin_name)
      end
    end

    get '/compund' do
      'Compund'
    end

    get '/' do
      process nil
    end

    get '/*/*' do |path, handler|
      process path, handler
    end

    get '/*' do |path|
      process path
    end


    def process(_path=nil, _handler_name=nil)
      params["handler"] ||= "default"

      page = Page.new do |pg|
        pg.file = FileFinder.find(_path, settings.content_dir)
        pg.params = self.params
      end

      page.render
    end


  end
end
