module RawView
  class << self

    def handle(page)
      return [200, {"content-type" => "text/plain"}, [page.content]]
    end

  end
end

Scrapple::PageApp.register_handler(RawView, "raw")
