module RawView
  class << self

    def handle(page)
      page.headers['content-type'] = 'text/plain'
      page.body = page.file_body
    end

  end
end

Scrapple::Webapp.register_handler(RawView, "raw")
