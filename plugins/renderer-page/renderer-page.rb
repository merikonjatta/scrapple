require 'layout/layout'

module Scrapple::Plugins
  module RendererPage
    class << self

      def render(page, params, env)
        engine = Tilt[page.type]
        raise "Tilt can't handle this type: #{page.type}" if engine.nil?

        page.body = engine.new { page.body }.render(page, page: page, env: env)

        if page['layout']
          page = Scrapple::Plugins::Layout.wrap(page, env)
        end

        headers = {'Content-Type' => content_type_for(page.type) }
        return [200, headers, [page.body]]
      end


      def content_type_for(ext)
        case ext
        when "sass", "scss", "less"
          "text/css"
        when "coffee"
          "text/javascript"
        when "builder"
          "text/xml"
        else
          Sinatra::Base.mime_type(ext) || "text/html"
        end
      end

    end
  end

  Scrapple.register_renderer(RendererPage, :name => "page")
end
