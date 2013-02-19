module Scrapple::Plugins
  class HandlerDirectory
    class << self

      DEFAULT_DEPTH = 3

      def confidence(page)
        page.type == "directory" ? 1000 : 0
      end


      def handle(page)
        depth = page['directory_handler']['depth'] || DEFAULT_DEPTH rescue DEFAULT_DEPTH
        body = "<h1>" + (page['title'] || File.basename(page.fullpath)) + "</h1>\n"
        body << page.index(:depth => depth)
        [200, {"Content-Type" => "text/html"}, [body]]
      end

    end
  end

  Scrapple::PageApp.register_handler(HandlerDirectory, :name => "directory")
end
