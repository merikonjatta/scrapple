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
    end

  end
end

Scrapple::Webapp.register_handler(DefaultView, "default")
