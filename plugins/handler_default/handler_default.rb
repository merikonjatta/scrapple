module HandlerDefault
  class << self

    def can_handle?(type)
      (Tilt.mappings.keys - %w(markdown md mkd)).include? type
    end

    def priority
      1000
    end

    def handle(page)
      ext = page.fullpath.sub(/^.*\./, '')
      engine = Tilt[ext]

      body = engine.new(engine_options(ext)){ page.content }.render(page)
      headers = {'Content-Type' => content_type_for(ext) }

      return [200, headers, [body]]
    end


    def engine_options(ext)
      case ext
      when nil
      else
        nil
      end
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

Scrapple::PageApp.register_handler(HandlerDefault, :name => "default")
