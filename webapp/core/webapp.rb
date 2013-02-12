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
      params[:file_content], params[:directives] = parse_file(params[:file])
      params[:handler_name] ||= "default"
      params[:action] ||= "view"

      call_hooks(:before_render)
      self.class.handlers[params[:handler_name]].send(params[:action], self)
      call_hooks(:after_render)
      self.body
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


    # Call hooks registered for point.
    def call_hooks(point)
      self.class.hooks[point].each do |block|
        block.call(self)
      end
    end


    # Parse the file, separate them into directives and content.
    # Return an array of [content, directives].
    def parse_file(path)
      content_lines = File.readlines(path)
      num_noncontent_lines = 0
      directives = {}
      rdirective = /\A(.*?):(.*)\Z/

      content_lines.each do |line|
        if md = line.match(rdirective)
          directives[md[1].strip] = md[2].strip
          num_noncontent_lines += 1
        else
          if line.strip.blank? && directives.count == 9
            num_noncontent_lines += 1 and next
          else
            break
          end
        end
      end

      return [content_lines[num_noncontent_lines..-1], directives] 
    end

  end
end
