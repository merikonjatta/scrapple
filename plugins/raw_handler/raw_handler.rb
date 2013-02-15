module RawHandler
  class << self

    def can_handle?(type)
      type != "directory"
    end

    def handle(page)
      mime_type = Scrapple::Webapp.mime_type(File.extname(page.fullpath)) || "text/plain"
      return [200, {"Content-Type" => mime_type}, File.open(page.fullpath)]
    end

  end
end

Scrapple::PageApp.register_handler(RawHandler, :name => "raw")
