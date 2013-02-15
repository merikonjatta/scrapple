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
      def register_handler(mod, properties)
        raise ArgumentError "Please specify a name for this handler." if properties[:name].blank?

        @handlers[properties[:name]] = mod
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
      specified = self.class.handlers[@params['handler'] || @page['handler']]
      return specified unless specified.nil?

      extension = File.extname(page.fullpath)[1..-1]
      (name, mod) = self.class.handlers.find { |name, mod| mod.can_handle? extension }

      return mod
    end

    attr_reader :page, :params
    attr_reader :body, :headers, :status

  end
end
