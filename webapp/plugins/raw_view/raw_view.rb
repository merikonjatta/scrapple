module RawView
  class << self

    def handle(page)
      page.headers['content-type'] = 'text/plain'

      if page.content
        page.body = page.content
      else
        page.body = File.read(page.file)
      end
    end

  end
end

Compund::Webapp.register_handler(RawView, "raw")
