module Scrapple::Plugins
  module MacroIndex

    # Produce an HTML list of child pages.
    # @param options [Hash]
    # @option [Page, String] :of            (self) Starting point, either a Page or a path
    # @option [Number] :depth               (1)    How deep?
    # @option [Array<Page>] :no_recurse     ([self]) Do not recurse into these pages
    # @option [Bool] :trailing_slash        (1)    Add trailing slashes after directory names whose contents were not listed
    # @option [Bool] :ignore_settings_files (true) Do not list _settings.txt files
    # @option [Array, Page, String] :ignore ([])   Do not list these pages.
    def index(options = {})
      options = {
        :of => self,
        :depth => 1,
        :no_recurse => [self],
        :trailing_slash => true,
        :ignore_settings_files => true,
        :ignore => []
      }.merge!(options)

      start = index_get_start_page(options[:of])
      return Rack::Utils.escape_html("index: #{options[:of]} doesn't exist") if start.nil?

      pages = start.children(options.select { |k,v| [:ignore, :ignore_settings_files].include? k }) 
      index_build_html(pages, options)
    end


    def index_get_start_page(place)
      unless place.is_a? Scrapple::Page
        start = place.to_s
        # A relative path ("./foo", "foo/bar", "../../") should be joined with
        # this Page's full path.
        if Pathname.new(start).relative?
          start = Pathname.new(self.fullpath).join(start).cleanpath.to_s
        end

        # A virtual absolute path ("/index.md") should be turned into
        # a real absolute path.
        if Pathname.new(start).absolute? && Scrapple::FileLookup.parent_root(start).nil?
          start = Pathname.new(self.root).join(start).cleanpath.to_s
        end

        start = Scrapple::Page.for(start)
      else
        start = place
      end
      start
    end


    def index_build_html(pages, options)
      html = "<ul class=\"index\">\n"
      pages.each do |page|
        html << "<li class=\""
        html << "active " if page.fullpath == self.fullpath
        html << (page.has_children? ? "directory" : "file")
        html << "\"><a href=\""
        html << page.link
        html << "\">"
        html << page['title']
        if page.has_children? && options[:no_recurse].none? {|n| n.same? page }
          if options[:depth] > 1
            html << "</a>"
            recurse_options = options.merge(:of => page, :depth => options[:depth]-1, :ignore => page)
            html << index(recurse_options)
          else
            html << "<span class=\"trailing_slash\">/</span>" if options[:trailing_slash]
            html << "</a>"
          end
        else
          html << "</a>"
        end
        html << "</li>\n"
      end
      html << "</ul>\n"
      html
    end
  end

  Scrapple::Page.send(:include, MacroIndex)
end
