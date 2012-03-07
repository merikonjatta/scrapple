require 'sinatra/base'
require 'yaml'
require 'active_support/core_ext'

class HandlerNotFound < Exception; end

class CompoundBase < Sinatra::Base

	if development?
		require 'pry'
	end


	configure do
		YAML.load_file(File.join(settings.root, 'config.yml')).each do |k,v|
			set k, v
		end
		set :content_dir, File.expand_path(File.join(settings.root, settings.content_dir))
	end


	def new_handler(name)
		name = name + '_handler'
		require File.join(settings.root, 'plugins', name, name)
		name.camelize.constantize.new
	end


	get '/system' do
		'System'
	end

	get '/*/view/as/*' do |path, handler_name|
		fullpath = File.join(settings.content_dir, path)
		raise Sinatra::NotFound unless File.exists?(fullpath)

		result = new_handler(handler_name).view(fullpath, request)

		status result[:status]
		headers result[:headers]
		body result[:body]
	end


	get '/*/edit/as/*' do |path, handler_name|
		fullpath = File.join(settings.content_dir, path)
		raise Sinatra::NotFound unless File.exists?(fullpath)

		result = new_handler(handler_name).edit(fullpath, request)

		status result[:status]
		headers result[:headers]
		body result[:body]
	end
end
