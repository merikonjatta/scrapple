require 'sinatra/base'
require 'pathname'
require 'yaml'
require 'active_support/core_ext'
require 'pry'

require 'core/page'

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

    get '/*/*/*' do |path, handler, action|
      process path, handler, action
    end

    get '/*/*' do |path, handler|
      process path, handler
    end

    get '/*' do |path|
      process path
    end


    def process(_path=nil, _handler_name=nil, _action=nil)
      params["handler"] ||= "default"
      params["action"] ||= "view"

      page = Page.new do |pg|
        pg.file = self.class.find_file(_path)
        pg.params = self.params
      end

      page.render
    end


  end
end
