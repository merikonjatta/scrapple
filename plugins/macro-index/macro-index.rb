module Scrapple::Plugins
  module MacroIndex

    # Produce an HTML list of child pages.
    # @param options [Hash]
    # @option [Page, String] :of            (self) Starting point, either a Page or a path
    # @option [Number] :depth               (1)    How deep?
    # @option [Bool] :trailing_slash        (1)    Add trailing slashes after directory names whose contents were not listed
    # @option [Bool] :ignore_settings_files (true) Do not list _settings.txt files
    # @option [Array, Page, String] :ignore ([])   Do not list these pages.
    def index(options = {})
      options = {
        :of => self,
        :depth => 1,
        :trailing_slash => true,
        :ignore_settings_files => true,
        :ignore => []
      }.merge!(options)

      start = options[:of]

      if start.is_a? String
        # A relative path ("./foo", "foo/bar", "../../") should be joined with
        # this Page's full path.
        if Pathname.new(start).relative?
          start = Pathname.new(File.join(self.fullpath, start)).cleanpath.to_s
        end

        # A virtual absolute path ("/index.md") should be turned into
        # a real absolute path.
        if Pathname.new(start).absolute? && Scrapple::FileLookup.parent_root(start).nil?
          start = Pathname.new(File.join(self.root, start)).cleanpath.to_s
        end

        start = Scrapple::Page.for(start)
      end

      return Rack::Utils.escape_html("index: #{options[:of]} doesn't exist") if start.nil?

      # Now find its entries...
      pages = start.children(options.select { |k,v| [:ignore, :ignore_settings_files].include? k }) 

      html = "<ul class=\"index\">\n"
      pages.each do |page|
        html << "<li class=\""
        html << "active " if page.fullpath == self.fullpath
        html << (page.has_children? ? "directory" : "file")
        html << "\"><a href=\""
        html << page.link
        html << "\">"
        html << page['title']
        if page.has_children?
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
