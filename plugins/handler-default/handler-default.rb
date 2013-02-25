module Scrapple::Plugins
  module HandlerDefault
    class << self

      def confidence(page)
        if (Tilt.mappings.keys - %w(markdown md mkd)).include?(page.type)
          1000
        else
          0
        end
      end


      def call(env)
        page = env['scrapple.page']
        engine = Tilt[page.type]

        content = Scrapple::Plugins::MacroExpander.expand(page.content,
                                                          :allowed => page['macros'],
                                                          :scope => page,
                                                          :locals => {:env => env})
        body = engine.new { content }.render(page, :env => env)
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

  Scrapple::Webapp.register_handler(HandlerDefault, :name => "default")
end
