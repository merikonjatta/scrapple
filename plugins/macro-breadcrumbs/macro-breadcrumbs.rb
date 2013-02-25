module Scrapple::Plugins
  module Breadcrumbs

    # Produce an HTML list of breadcrumbs.
    def breadcrumbs
      components = self.path.split('/')

      entries = {}
      components.count.times do |i|
        path = components[0...components.count-i].join('/')
        path = "/" if path == ""
        page = Scrapple::Page.for(path, :fetch => true, :ignore_settings_files => true)
        entries[page.fullpath] = page
      end

      pages = entries.keys.uniq.map { |path| entries[path] }.reverse.uniq

      str = "<ul class=\"breadcrumb\">\n"
      pages.each do |page|
        if page == pages.last
          str << "<li class=\"active\"><a href=\""
        else
          str << "<li><a href=\""
        end
        str << page.link
        str << "\">"
        str << page['title']
        str << "</a></li>\n"
        str << "<li class=\"seperator\">&raquo;</li>\n" unless page == pages.last
      end
      str << "</ul>"

      str
    end

  end

  Scrapple::Page.send(:include, Breadcrumbs)
end
