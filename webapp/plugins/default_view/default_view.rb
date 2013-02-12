module DefaultView
  class << self

    def handle(page)
      if page.content
        ext = page.file.sub(/\A.*\./, '')
        page.body = Tilt[ext].new{ page.content }.render(page)
      else
        page.body = Tilt.new(page.file).render(page)
      end
    end

  end
end

Compund::Webapp.register_handler(DefaultView, "default")
