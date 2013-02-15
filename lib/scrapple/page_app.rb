module Scrapple
  # Final endpoint Rack app for Scrapple.
  # Responsible for deciding on a handler to invoke,
  # invoking the handler, and returning its output to the underlying Rack middleware stack.
  class PageApp

    @handlers = {}

    class << self
      def call(env)
        self.new(env).call
      end

      attr_reader :handlers

      # Register a handler.
      # @param [Module] mod    Handler module.
      # @param [Hash] properties  Properties of the handler.
      # @option properties [String] :name        The name of this module.
      # @option properties [Array]  :can_handle  Extensions that this handler can handle.
      #                                          Do not include the dots. Can also be Regexps.
      def register_handler(mod, properties)
        raise ArgumentError "Please specify a name for this handler." if properties[:name].blank?
        raise ArgumentError "Please specify a list of extensions this handler can handle." if properties[:can_handle].blank?

        properties[:module] = mod

        properties[:can_handle] = properties[:can_handle].map do |ext|
          (ext.is_a? Regexp) ? ext : Regexp.new("^"+Regexp.escape(ext)+"$", "i")
        end

        @handlers[properties[:name]] = properties
      end
    end


    def initialize(env)
      @env = env
      @page = env['scrapple.page']
      @params = env['scrapple.params']
      @headers = {"Content-Type" => "text/html"}
      @body = nil
      @status = 200
    end


    def call
      handler = choose_handler
      @status, additional_headers, @body = handler.handle(page)
      return [200, @headers.merge(additional_headers), @body]
    end


    # Choose a suitable handler for this page and request.
    # @return [Module]
    def choose_handler
      return @params['handler'] unless @params['handler'].nil?

      extension = File.extname(page.fullpath)[1..-1]
      (name, handler) = self.class.handlers.find do |name, properties|
        properties[:can_handle].any? { |ext_r| extension =~ ext_r }
      end

      return handler[:module]
    end

    attr_reader :page, :params
    attr_reader :body, :headers, :status

  end
end
