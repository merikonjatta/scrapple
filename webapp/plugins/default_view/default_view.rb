module DefaultView
  class << self

    def handle(page)
      ext = page.file.sub(/\A.*\./, '')
      page.body = Tilt[ext].new{ page.content }.render(page)
    end

  end
end

Compund::Webapp.register_handler(DefaultView, "default")
