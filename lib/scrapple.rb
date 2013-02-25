require 'bundler'
Bundler.require(:default, :development)
require 'pathname'
require 'fileutils'
require 'yaml'
require 'active_support/core_ext'


module Scrapple
  class HandlerNotFound < Exception; end
  class FileNotFound < Exception; end
  module Plugins; end

  class << self

    DEFAULT_SETTINGS = {
      "perdir_file" => "_config.yml",
      "content_dir" => "sample_content",
      "plugins_dir" => "plugins",
      "data_dir"    => "data",
      "tmp_dir"     => "tmp",
    }

    attr_reader :root
    attr_reader :settings
    attr_reader :middleware_stack
    attr_reader :plugins

    # Set up accessor methods for basic settings entries
    %w(content_dir plugins_dir data_dir tmp_dir perdir_file).each do |name|
      define_method name do
        settings[name]
      end
    end


    # Require necessary libs and add file lookup paths.
    def setup
      @root = Pathname.new(File.expand_path("../../", __FILE__))
      Dir.chdir @root

      load_settings
      setup_dirs
      load_lib

      FileLookup.roots << content_dir

      build_middleware_stack
      load_plugins
    end


    def load_settings
      @settings = DEFAULT_SETTINGS
      if File.exist?(config_file = @root.join("config.yml"))
        @settings.merge!(YAML.load_file(config_file)) rescue TypeError # FIXME
      end
    end


    def setup_dirs
      %w(data_dir tmp_dir plugins_dir content_dir).each do |name|
        @settings[name] = Pathname.new(File.expand_path(@settings[name])).cleanpath
      end

      [data_dir, tmp_dir].each do |dir|
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

      [plugins_dir, content_dir].each do |dir|
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
      $: << plugins_dir

      # Require all <plugins_root>/<plugin>/<plugin>.rb scripts in plugins dir
      @plugins = []
      Pathname.glob(plugins_dir.to_s + "/*").map { |dir|
        [dir.to_s.match(/.*\/(.*)$/)[1], dir, dir.join("content")]
      }.each do |name, dir, content_dir|
        begin
          require dir.join(name)
          FileLookup.roots << content_dir if File.directory?(content_dir)
          @plugins << dir
        rescue LoadError
        end
      end
    end

  end

end

Scrapple.setup
