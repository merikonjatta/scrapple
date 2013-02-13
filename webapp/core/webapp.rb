require 'sinatra/base'
require 'pathname'
require 'yaml'
require 'active_support/core_ext'
require 'pry'

require 'core/page'
require 'core/file_finder'
require 'core/settings'

module Scrapple
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

      # Some fields are array by default
      Settings.array_fields << 'tags'

      # Require all <plugin>.rb scripts in plugins dir
      Dir[settings.root + "/plugins/*"].each do |plugin_dir|
        plugin_name = plugin_dir.match(/.*\/(.*)$/)[1]
        require File.join(plugin_dir, plugin_name)
      end
    end


    get '/scrapple' do
      'Scrapple'
    end

    get '/*' do |path|
      unless file = FileFinder.find(path, settings.content_dir)
        pass
        # See if the last path component was a handler
        #if md = path.match(/^(.*)\/([-a-zA-Z_]+)/)
        #  path = md[1]
        #  params["handler"] = md[2]
        #  unless file = FileFinder.find(path, settings.content_dir)
        #    pass
        #  end
        #end
      end

      params["handler"] ||= "default"

      page = Page.new do |pg|
        pg.file = file
        pg.params = self.params
      end

      page.render
    end

  end
end
