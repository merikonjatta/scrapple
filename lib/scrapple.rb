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
      @config = DEFAULTS.merge!(YAML.load_file(ROOT.join("config.yml")))
    end


    def validate_config
      @config['data_dir'] ||= @root + "data"
      @config['plugins_dir'] ||= @root + "plugins"

      @config['fallback_renderer'] ||= 'webpage'
      @config['default_renderers'] ||= {
        'md'       => 'webpage',
        'markdown' => 'webpage',
        'textile'  => 'webpage',
        'rdoc'     => 'webpage',
        'html'     => 'raw',
        'js'       => 'raw',
        'css'      => 'raw',
      }
     
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
      Pathname.glob(plugins_dir + "/*").each do |dir|
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
      @renderer[properties[:name]] = mod
    end

    # Choose a suitable renderer for this page and request.
    # @param page [Page]
    # @return [Module]
    def renderer_for(page)
      (
        renderer(params['renderer']) ||
        renderer(page['renderer']) ||
        renderer(config["default_renderers"][page.type]) ||
        renderer(config["fallback_renderer"])
      )
    end

    # Get a renderer module by name.
    def renderer(name)
      renderers[name]
    end

  end

end


