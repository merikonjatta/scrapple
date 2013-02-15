class DirectoryHandler
  class << self

    def can_handle?(type)
      type == "directory"
    end


    def handle(page)
      depth = page['directory_handler']['depth'] || 2 rescue 2
      body = "<h1>" + (page['title'] || File.basename(page.fullpath)) + "</h1>\n"
      body << page.index(:depth => depth)
      [200, {"Content-Type" => "text/html"}, [body]]
    end
      
  end
end

Scrapple::PageApp.register_handler(DirectoryHandler, :name => "directory")
