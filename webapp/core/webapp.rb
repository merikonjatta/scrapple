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

    get '/*/*/*' do |path, handler_name, action|
      process path, handler_name, action
    end

    get '/*/*' do |path, handler_name|
      process path, handler_name
    end

    get '/*' do |path|
      process path
    end


    def process(path=nil, handler_name=nil, action=nil)
      page = Page.new
      page.file = self.class.find_file(path)
      page.handler_name = handler_name
      page.action = action
      page.params = params

      page.render
    end


  end
end
