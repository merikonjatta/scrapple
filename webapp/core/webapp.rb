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
    @hooks = {
      :before_render => [],
      :after_render => [],
    }

    class << self
      attr_reader :handlers, :hooks

      def register_handler(mod, name)
        @handlers[name] = mod
      end

      def hook(point, &block)
        @hooks[point] << block
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
      params[:file] = find_file(path)
      params[:handler_name] ||= "default"
      params[:action] ||= "view"

      call_hooks(:before_render)
      self.class.handlers[params[:handler_name]].send(params[:action], self)
      call_hooks(:after_render)
      self.body
    end


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

    def call_hooks(point)
      self.class.hooks[point].each do |block|
        block.call(self)
      end
    end

  end
end
