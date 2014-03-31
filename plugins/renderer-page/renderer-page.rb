module Scrapple::Plugins
  module RendererPage
    class << self

      def render(page, options = {})
        engine = Tilt[page.type]

        body = engine.new { page.body }.render(page)

        headers = {'Content-Type' => content_type_for(page.type) }
        return [200, headers, [body]]
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
          Scrapple::Webapp.mime_type(ext) || "text/html"
        end
      end

    end
  end

  Scrapple.register_renderer(RendererPage, :name => "page")
end
