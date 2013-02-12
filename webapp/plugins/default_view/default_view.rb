module DefaultView
  class << self

    def handle(page)
      ext = page.file.sub(/\A.*\./, '')
      engine = Tilt[ext]
      if engine.nil?
        page.body = page.content
      else
        page.body = engine.new{ page.content }.render(page)
      end
    end

  end
end

Compund::Webapp.register_handler(DefaultView, "default")
