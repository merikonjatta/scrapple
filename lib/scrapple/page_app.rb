module Scrapple
  class PageApp

    @handlers = {}

    class << self
      def call(env)
        self.new(env).call
      end

      attr_reader :handlers

      def register_handler(mod, name)
        @handlers[name] = mod
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
      params['handler'] ||= "default"
      handler = self.class.handlers[params['handler']]
      @status, additional_headers, @body = handler.handle(page)
      return [200, @headers.merge(additional_headers), @body]
    end

    attr_reader :page, :params
    attr_reader :body, :headers, :status

  end
end
