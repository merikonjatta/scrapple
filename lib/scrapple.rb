require 'bundler'
Bundler.require(:default, :development)
require 'pathname'
require 'fileutils'
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

      load_settings
      setup_dirs
      load_lib

      FileLookup.roots << @content_dir

      build_middleware_stack
      load_plugins
    end


    def load_settings
      if File.exist?(config_file = @root.join("config.yml"))
        @settings = Syck.load_file(config_file)
      else
        @settings = {}
      end
    end


    def setup_dirs
      {
        "data_dir" => "data",
        "tmp_dir" => "tmp",
        "plugins_dir" => "plugins",
        "content_dir" => "sample_content"
      }.each do |name, default|
        value = @settings.delete(name) || default
        instance_variable_set("@#{name}", @root.join(value))
      end

      [@data_dir, @tmp_dir].each do |dir|
        unless dir.directory?
          begin FileUtils.mkdir_p dir, :mode => 0755
          rescue
            abort "Couldn't create #{dir.to_s}. Please create it or specify another location in config.yml"
          end
        end
        unless dir.writable?
          abort "Directory #{dir.to_s} is not writable by #{`whoami`.strip}."
        end
      end

      [@plugins_dir, @content_dir].each do |dir|
        unless dir.directory?
          abort "#{dir.to_s} doesn't exist. A typo, maybe?"
        end
      end
    end


    def load_lib
      %W(
        file_lookup  settings  hookable page webapp  middleware_stack
      ).each { |lib| require @root.join("lib/scrapple/#{lib}") }
    end



    def build_middleware_stack
      @middleware_stack = Scrapple::MiddlewareStack.new
      @middleware_stack.append Rack::Session::Cookie, :key => "scrapple_session"
      @middleware_stack.append Scrapple::Webapp
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
