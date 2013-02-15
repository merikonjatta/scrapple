module RawView
  class << self

    def can_handle?
      true
    end


    def handle(page)
      return [200, {"Content-Type" => "text/plain"}, [page.content]]
    end

  end
end

Scrapple::PageApp.register_handler(RawView, :name => "raw")
