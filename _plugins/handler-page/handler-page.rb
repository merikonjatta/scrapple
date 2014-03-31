module Scrapple::Plugins
  module HandlerPage
    class << self

      def call(env)
        engine = Tilt[page.type]

        content = Scrapple::Plugins::MacroExpander.expand(page.content,
                                                          :allowed => page['macros'],
                                                          :scope => page,
                                                          :locals => {:env => env})
        content = engine.new { content }.render(page, :env => env)
        content = Scrapple::Plugins::Layout.wrap(content, env)

        headers = {'Content-Type' => content_type_for(page.type) }
        return [200, headers, [content]]
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
