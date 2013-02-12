require 'sinatra/base'
require 'pathname'
require 'yaml'
require 'active_support/core_ext'
require 'pry'

require 'core/page'
require 'core/file_parser'

module Compund
  class HandlerNotFound < Exception; end

  module Handlers; end
  module Plugins; end

  class Webapp < Sinatra::Base

    @handlers = {}

    class << self
      attr_reader :handlers

      def register_handler(mod, name)
        @handlers[name] = mod
      end

      # Find the appropriate file based on the given path
      def find_file(path=nil)
        file = nil
        if path.blank?
          file = Dir[File.join(settings.content_dir, "index.*")].first
        else
          file = File.join(settings.content_dir, path)
        end

        if file.nil? || !File.exist?(file)
          file = Dir[File.join(settings.content_dir, "#{path}.*")].first
        end

        #raise Sinatra::NotFound if file.nil? || File.exist?(file)
        raise "File not found: #{file} for #{path}" if file.nil? || !File.exist?(file)

        return file
      end

    end

    configure do
      set :root, File.expand_path("..", File.dirname(__FILE__))
      set :public_folder, File.join(settings.root, 'core', 'public')
      set :views, File.join(settings.root)
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
        pg.file = self.class.find_file(_path)
        pg.params = self.params
      end

      page.render
    end


  end
end
