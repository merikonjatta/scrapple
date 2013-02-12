module Scrapple
  class Page
    @hooks = {
      :before_render => [],
      :after_render => [],
    }

    class << self
      attr_reader :hooks
      def hook(point, &block)
        @hooks[point] << block
      end
    end

    # Params that came in from the browser. Generally not for modifying.
    # Has precedence over locals.
    attr_accessor :params
    
    # Local settings for this page. Includes directives found in file,
    # and directives found in _settings.txt in parent directories.
    # But can be used to store arbitrary data
    attr_accessor :locals

    # Normally, directives found in _settings.txt files are taken into locals.
    # Set this to false to ignore them.
    attr_accessor :ignore_settings_files

    # What file in the content dir this page represents.
    # Note that this may not be a real file.
    attr_accessor :file

    # The content body of the file this page represents.
    attr_accessor :file_body

    # Body, headers and status to be returned on render to Scrapple::Webapp
    # The main job of handlers would be to overwrite these.
    attr_accessor :body, :headers, :status

    # Pass a block to configure this page.
    def initialize
      @locals = {}
      @params = {}
      @ignore_settings_files = false

      yield(self) if block_given?

      @file_body ||= File.read(@file) unless @file.nil?
      @headers   ||= self["headers"] || {}
      @status    ||= self["status"]  || 200

      sp = SettingsParser.new(@locals)

      unless @ignore_settings_files
        settings_files = FileFinder.find_in_ancestors("_settings", @file, Scrapple::Webapp.content_dir)
        settings_files.reverse_each do |settings_file|
          sp.parse_and_merge_file(settings_file)
        end
      end

      @file_body = sp.parse_and_merge(@file_body)
      @locals = sp.result
    end


    # Call hooks registered for point.
    def call_hooks(point)
      self.class.hooks[point].map { |block| block.call(self) }
    end


    # Get variables from params, locals, and settings, in that order of priority
    def [](key)
      @params[key] || @locals[key]
    end


    # Render this page. Returns a Rack response array.
    def render
      call_hooks(:before_render)
      Scrapple::Webapp.handlers[self['handler']].handle(self)
      call_hooks(:after_render)

      [@status, @headers, @body]
    end

  end
end
