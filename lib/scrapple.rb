require 'bundler'
Bundler.require(:default, :development)

require 'pathname'
require 'fileutils'
require 'yaml'
require 'active_support/core_ext'

%w{
  scrapple/content
  scrapple/file_system_bag
  scrapple/page
  scrapple/parser
  scrapple/webapp
  scrapple/middleware_stack
}.each { |lib| require File.expand_path("../", __FILE__) + "/#{lib}" }


class Scrapple
  class HandlerNotFound < StandardError; end
  class FileNotFound < StandardError; end
  module Plugins; end

  class << self

    DEFAULTS = {
      "rc_file"     => "_config.yml",
    }

    attr_reader :root
    attr_reader :config
    attr_reader :middleware_stack
    attr_reader :plugins
    attr_reader :content
    attr_reader :renderers

    def plugins_dir
      config["plugins_dir"]
    end

    def data_dir
      config["data_dir"]
    end

    def rc_file
      config["rc_file"]
    end

    def init
      @root = Pathname.new(File.expand_path("../../", __FILE__)).cleanpath
      @renderers = {}
      load_config
      validate_config
      clean_pathnames
      check_dirs
      init_content
      build_middleware_stack
      load_plugins
    end


    def load_config
      @config = DEFAULTS.merge!(YAML.load_file(@root.join("config.yml")))
    rescue
      @config = {}
    end


    def validate_config
      @config['data_dir'] ||= @root + "data"
      @config['plugins_dir'] ||= @root + "plugins"
      @config['content_dir'] ||= @root + "sample_content"
      @config['fallback_renderer'] ||= 'page'

      @config['default_renderers'] ||= {}
      @config['default_renderers'].merge!({
        'directory' => 'directory',

        'md'        => 'page',
        'mdown'     => 'page',
        'markdown'  => 'page',
        'textile'   => 'page',
        'rdoc'      => 'page',
        'haml'      => 'page',
        'erb'       => 'page',

        'txt'       => 'raw',
        'rb'        => 'raw',
        'pl'        => 'raw',
        'php'       => 'raw',
        'c'         => 'raw',

        'jpg'       => 'raw',
        'jpeg'      => 'raw',
        'png'       => 'raw',
        'gif'       => 'raw',
        'svg'       => 'raw',
        'pdf'       => 'raw',
        'html'      => 'raw',
        'js'        => 'raw',
        'css'       => 'raw',
      })
     
      unless @config['content_dir']
        abort "Please specify content_dir in your config.yml"
      end
    end

    def clean_pathnames
      ["content_dir", "plugins_dir", "data_dir"].each do |key|
        config[key] = Pathname.new(config[key]).cleanpath
      end
    end

    def check_dirs
      ["content_dir", "plugins_dir", "data_dir"].each do |dir|
        unless config[dir].directory?
          begin
            FileUtils.mkdir_p config[dir], :mode => 0755
          rescue
            abort "Couldn't create #{config[dir].to_s}. Please create it or specify another location in config.yml"
          end
        end
      end

      unless data_dir.writable?
        abort "Directory #{data_dir.to_s} is not writable by #{`whoami`.strip}."
      end
    end

    def init_content
      @content = Scrapple::Content.new
      @content << config["content_dir"]
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
      Pathname.glob(plugins_dir + "*").each do |dir|
        begin
          require dir + dir.basename
          @content << (dir + "content")
          @plugins << dir
        rescue LoadError
        end
      end
    end


    # Register a renderer.
    # @param [Module] mod                Renderer module.
    # @param [Hash] properties           Properties of the renderer.
    # @option properties [String] :name  The name of this module.
    def register_renderer(mod, properties)
      raise ArgumentError "Please specify a name for this renderer." if properties[:name].blank?
      @renderers[properties[:name]] = mod
    end

    # Get a renderer module by name.
    # @param name [String]
    # @return [Module]
    def renderer(name)
      @renderers[name]
    end

  end

end


