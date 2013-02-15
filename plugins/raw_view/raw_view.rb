module RawView
  class << self

    def can_handle?(extension)
      true
    end

    def handle(page)
      mime_type = Scrapple::Webapp.mime_type(File.extname(page.fullpath)) || "text/plain"
      return [200, {"Content-Type" => mime_type}, [page.content]]
    end

  end
end

Scrapple::PageApp.register_handler(RawView, :name => "raw")
