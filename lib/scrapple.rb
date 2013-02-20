require 'bundler'
Bundler.require(:default, :development)
require 'pathname'
require 'syck'
require 'yaml'
require 'active_support/core_ext'


module Scrapple
  class HandlerNotFound < Exception; end
  class FileNotFound < Exception; end
  module Plugins; end

  class << self

    attr_reader :root
    attr_reader :content_dir
    attr_reader :plugins_dir
    attr_reader :data_dir
    attr_reader :tmp_dir
    attr_reader :settings
    attr_reader :middleware_stack

    # Require necessary libs and add file lookup paths.
    def setup
      @root = Pathname.new(File.expand_path("../../", __FILE__))

      load_lib

      # TODO make these configurable
      # TODO make sure tmp and data are writeable
      @data_dir    = @root.join("data")
      @tmp_dir     = @root.join("tmp")
      @plugins_dir = @root.join("plugins")
      @content_dir ||= @root.join("sample_content")
      FileLookup.roots << @content_dir

      # Load global settings
      # TODO settings file? config file? WTF? KISS
      @settings = Settings.new
      if settings_file = FileLookup.find_in_root("_settings", @content_dir)
        @settings.parse_and_merge(settings_file)
      end
      if File.exist?(config_file = @data_dir.join("config.yml"))
        @settings.parse_and_merge(config_file)
      end

      # Build basic middleware stack
      @middleware_stack = Scrapple::MiddlewareStack.new
      @middleware_stack.append Rack::Session::Cookie, :key => "scrapple_session"
      @middleware_stack.append Scrapple::Webapp

      # Let Webapp do its stuff
      Scrapple::Webapp.setup

      # Define some directive aliases up front
      Scrapple::Settings.alias_key("as",   "handler")
      Scrapple::Settings.alias_key("with", "handler")
      Scrapple::Settings.alias_key("in",   "handler")

      load_plugins
    end


    def load_lib
      %W(
        file_lookup
        settings
        hookable
        page
        webapp
        middleware_stack
      ).each { |lib| require @root.join("lib/scrapple/#{lib}") }
    end


    def load_plugins
      # Add plugins dir to load path so that plugins with dependencies can
      # require them early.
      $: << @plugins_dir

      # Require all <plugins_root>/<plugin>/<plugin>.rb scripts in plugins dir
      Pathname.glob(@plugins_dir.to_s + "/*") do |plugin_dir|
        plugin_name = plugin_dir.to_s.match(/.*\/(.*)$/)[1]
        begin
          require plugin_dir.join(plugin_name)
        rescue LoadError
        end
      end

      # Add all <plugins_root>/<plugin>/content directories to FileLookup.roots
      Pathname.glob(@plugins_dir.to_s + "/*/content") do |plugin_content_dir|
        FileLookup.roots << plugin_content_dir.to_s if plugin_content_dir.directory?
      end
    end

  end

end

Scrapple.setup
