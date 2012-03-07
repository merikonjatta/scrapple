require 'sinatra/base'
require 'yaml'
require 'active_support/core_ext'

require './handler'


module Compound
	class HandlerNotFound < Exception; end
	class ActionNotFound < Exception; end

	class Base < Sinatra::Base

		if development?
			require 'pry'
		end

		configure do
			YAML.load_file(File.join(settings.root, 'config.yml')).each { |k,v| set k, v }
			set :content_dir, File.expand_path(File.join(settings.root, settings.content_dir))
		end


		def self.load_handler(name)
			name = name + '_handler'
			require File.join(settings.root, 'plugins', name, name)
			name.camelize.constantize
		end


		def load_handler(name)
			self.class.load_handler(name)
		end


		get '/system' do
			'System'
		end


		get '/*/*/as/*' do |path, action, handler_name|
			fullpath = File.join(settings.content_dir, path)
			raise Sinatra::NotFound unless File.exists?(fullpath)

			result = load_handler(handler_name).new.invoke(action, fullpath, self)
			result
		end

	end
end
