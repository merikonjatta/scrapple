require 'bundler'
Bundler.require(:default, :development)

require 'pathname'
require 'fileutils'
require 'yaml'
require 'active_support/core_ext'

%w{
  scrapple/file_lookup
  scrapple/settings
  scrapple/hookable
  scrapple/page
  scrapple/webapp
  scrapple/middleware_stack
}.each { |lib| require File.expand_path("../", __FILE__) + "/#{lib}" }


module Scrapple
  class HandlerNotFound < StandardError; end
  class FileNotFound < StandardError; end
  module Plugins; end

  class << self

    ROOT = Pathname.new(File.expand_path("../../", __FILE__)).cleanpath

    DEFAULTS = {
      "content_dir" => ROOT + "sample_content",
      "plugins_dir" => ROOT + "plugins",
      "data_dir"    => ROOT + "data",
      "rc_file"     => "_config.yml",
    }

    attr_reader :root
    attr_reader :config
    attr_reader :middleware_stack
    attr_reader :plugins

    def root
      ROOT
    end

    def content_dir
      config["content_dir"]
    end

    def plugins_dir
      config["plugins_dir"]
    end

    def data_dir
      config["data_dir"]
    end

    def rc_file
      config["rc_file"]
    end


    def load_config
      @config = DEFAULTS.merge!(YAML.load_file(ROOT.join("config.yml")))
    end

    def clean_pathnames
      ["content_dir", "plugins_dir", "data_dir"].each do |key|
        config[key] = Pathname.new(config[key]).cleanpath
      end
    end

    def check_dirs
      [data_dir, content_dir, plugins_dir].each do |dir|
        unless dir.directory?
          begin
            FileUtils.mkdir_p dir, :mode => 0755
          rescue
            abort "Couldn't create #{dir.to_s}. Please create it or specify another location in config.yml"
          end
        end
      end

      [data_dir, content_dir].each do |dir|
        unless dir.writable?
          abort "Directory #{dir.to_s} is not writable by #{`whoami`.strip}."
        end
      end
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
      Pathname.glob(plugins_dir + "/*").each do |dir|
        begin
          require dir + dir.to_s.match(/.*\/(.*)$/)[1]
          FileLookup.roots << (dir + "content") if (dir + "content").directory?
          @plugins << dir
        rescue LoadError
        end
      end
    end

  end

end


Scrapple.load_config
Scrapple.clean_pathnames
Scrapple.check_dirs

Scrapple::FileLookup.roots << Scrapple.content_dir

Scrapple.build_middleware_stack
Scrapple.load_plugins
