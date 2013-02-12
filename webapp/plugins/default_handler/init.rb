module DefaultHandler
  class << self

    # The `view` action 
    def view(page)
      if page.content
        ext = page.file.sub(/\A.*\./, '')
        page.body = Tilt[ext].new{ page.content }.render(page, page.locals)
      else
        page.body = Tilt.new(page.file).render(page, page.locals)
      end
    end

    def edit(page)
      "Editing:\n" + page.file
    end

    def write(page)
      "Wrote #{page.file} with:\n\n#{page.params[:content]}"
    end

  end
end

Compund::Webapp.register_handler(DefaultHandler, "default")
