require 'sinatra/base'

module Scrapple

  class Webapp < Sinatra::Base
    @handlers = {}

    class << self
      attr_reader :handlers

      # Register a handler.
      # @param [Module] mod    Handler module.
      # @param [Hash] properties  Properties of the handler.
      # @option properties [String] :name        The name of this module.
      def register_handler(mod, properties)
        raise ArgumentError "Please specify a name for this handler." if properties[:name].blank?
        @handlers[properties[:name]] = mod
      end

      # Not putting this stuff in a configure block because FileLookup.roots must
      # be configured first. The configure block is simply executed immediately
      # while this class definition is taking place. Making this an explicit call
      # makes things easier.
      def setup
        # The first _settings.txt found is read for webapp config
        setng = Settings.new.parse(FileLookup.find("_settings"), :dont_stop => true)[1]

        # Relative URL root needs preceding slash, but no trailing slash
        relroot = setng["relative_url_root"] || "/"
        set :relative_url_root, relroot.sub(/^[^\/]/, '/\0').sub(/\/$/, '')
      end
    end


    # A get route with handler specified
    get %r{(.*)/(as|with|in)/(.+)} do |path, dummy, handler|
      params['handler'] = handler
      for_path(CGI.unescape(path))
    end

    # A get route with no handler specified
    get '/*' do |path|
      for_path(CGI.unescape(path))
    end

    # A post route to root, for writing to a file
    post '/' do
      page = Page.for(params['fullpath'])
      # TODO better error handling
      return "No file" if page.nil?
      return "Not in content dir" if page.root != Scrapple.content_dir
      page.write(params['content']);
      redirect to(page.path)
    end


    def for_path(path = '')
      page = Page.for(path, :fetch => true)
      raise Sinatra::NotFound if page.nil?

      # Set rack env so that other middleware plugins can access them
      env['scrapple.page'] = page
      env['scrapple.params'] = params

      return choose_handler_for(page).call(env)
    end


    # Choose a suitable handler for this page and request.
    # @param page [Page]
    # @return [Module]
    def choose_handler_for(page)

      specified = self.class.handlers[params['handler'] || page['handler']]
      return specified unless specified.nil?

      mod = self.class.handlers.values.sort { |a,b| a.confidence(page) <=> b.confidence(page) }.reverse.first
      return mod
    end

  end
end
