module RawHandler
  class << self

    # The `view` action 
    def view(page)
      page.headers['content-type'] = 'text/plain'

      if page.content
        page.body = page.content
      else
        page.body = File.read(page.file)
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

Compund::Webapp.register_handler(RawHandler, "raw")
