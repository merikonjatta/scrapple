require 'bundler'
Bundler.require(:default, :development)
require 'pathname'
require 'syck'
require 'yaml'
require 'active_support/core_ext'


module Scrapple
  class HandlerNotFound < Exception; end
  class FileNotFound < Exception; end

	ROOT = File.expand_path('../../', __FILE__)

  class << self

		# Require necessary libs and add file lookup paths.
		def setup
			load_lib

			# If no content dir was specified, just run with sample content
			ENV['CONTENT_DIR'] ||= File.join(ROOT, "sample_content")
			FileLookup.roots << ENV['CONTENT_DIR']

			Scrapple::Webapp.setup

			# Define some directive aliases up front
			Scrapple::Settings.alias_key("as",   "handler")
			Scrapple::Settings.alias_key("with", "handler")
			Scrapple::Settings.alias_key("in",   "handler")

			# If no plugins dir was specified, use the local directory
			ENV['PLUGINS_DIR'] ||= File.join(ROOT, "plugins")

			load_plugins
		end


		def load_lib
			%W(
				file_lookup
				settings
				hookable
				page
				webapp
				page_app
				middleware_stack
			).each { |lib| require File.join(ROOT, "lib/scrapple/#{lib}") }
		end


		def load_plugins
			# Require all <plugins_root>/<plugin>/<plugin>.rb scripts in plugins dir
			Dir[ENV['PLUGINS_DIR'] + "/*"].each do |plugin_dir|
				plugin_name = plugin_dir.match(/.*\/(.*)$/)[1]
				require File.join(plugin_dir, plugin_name)
			end

			# Add all <plugins_root>/<plugin>/content directories to FileLookup.roots
			Dir[ENV['PLUGINS_DIR'] + "/*/content"].each do |plugin_content_dir|
				FileLookup.roots << plugin_content_dir if File.directory?(plugin_content_dir)
			end
		end

	end

end

Scrapple.setup
