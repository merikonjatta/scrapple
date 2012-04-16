require 'sinatra/base'
require 'pathname'
require 'yaml'
require 'active_support/core_ext'

require File.join(File.dirname(__FILE__), 'handlers/base')


module Compund
	class HandlerNotFound < Exception; end
	class ActionNotFound < Exception; end

	class WebApp < Sinatra::Base

		require 'pry' if development?

		configure do
			set :root, File.expand_path("..", File.dirname(__FILE__))
      set :public_folder, File.join(settings.root, 'core', 'public')
      set :views, File.join(settings.root, 'core', 'views')

      # Load and normalize config.yml directives
			YAML.load_file(File.join(settings.root, 'config.yml')).each { |k,v| set k, v }
			unless Pathname.new(settings.content_dir).absolute?
				set :content_dir, File.expand_path(settings.content_dir, settings.root) 
			end
		end


		def self.load_handler(name)
			name = name + '_handler'
			require File.join(settings.root, 'plugins', name, name)
			("Compund::Handlers::"+name.camelize).constantize
		end

		def load_handler(name)
			self.class.load_handler(name)
		end

    def local_view(base, name)
      base_pathname = Pathname.new(File.dirname(base))
      views_pathname = Pathname.new(settings.views)
      base_pathname.relative_path_from(views_pathname).join("views", name).to_s.intern
    end


		get '/system' do
			'System'
		end


		get '/*/*/*' do |path, handler_name, action|
      @path = path
      @handler_name = handler_name
      @action = action
			@fullpath = File.join(settings.content_dir, @path)
			raise Sinatra::NotFound unless File.exists?(@fullpath)

			result = load_handler(@handler_name).new(self).invoke(@action, @fullpath)
			result
		end

	end
end