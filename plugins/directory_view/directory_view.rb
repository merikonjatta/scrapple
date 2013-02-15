class DirectoryView
  class << self

    def can_handle?(type)
      type == "directory"
    end


    def handle(page)
      [200, {"Content-Type" => "text/html"}, ["This is a directory, oh?"]]
    end
      
  end
end

Scrapple::PageApp.register_handler(DirectoryView, :name => "directory")
