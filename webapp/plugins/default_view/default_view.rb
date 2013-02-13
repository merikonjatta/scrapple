module DefaultView
  class << self

    def handle(page)
      ext = page.fullpath.sub(/^.*\./, '')
      engine = Tilt[ext]

      headers = {}
      body = ""

      if engine.nil?
        body = page.content
      else
        body = engine.new{ page.content }.render(page)
      end

      if %(sass scss).include?(ext)
        headers['content-type'] = "text/css"
      elsif mime_type = Scrapple::Webapp.mime_type(ext)
        headers['content-type'] = mime_type
      else
        headers['content-type'] = "text/html"
      end

      return [200, headers, [body]]
    end

  end
end

Scrapple::PageApp.register_handler(DefaultView, "default")
