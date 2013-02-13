module DefaultView
  class << self

    def handle(page)
      ext = page.file.sub(/^.*\./, '')
      engine = Tilt[ext]

      if engine.nil?
        page.body = page.file_body
      else
        page.body = engine.new{ page.file_body }.render(page)
      end

      if %(sass scss).include?(ext)
        page.headers['content-type'] = "text/css"
      elsif mime_type = Scrapple::Webapp.mime_type(ext)
        page.headers['content-type'] = mime_type
      else
        page.headers['content-type'] = "text/html"
      end
    end

  end
end

Scrapple::Webapp.register_handler(DefaultView, "default")
