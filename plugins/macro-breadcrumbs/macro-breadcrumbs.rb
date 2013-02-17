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

			pages = entries.keys.uniq.map { |path| entries[path] }.reverse

			str = "<ul class=\"breadcrumb\">\n"
			pages.uniq[0...-1].each do |page|
				str << "<li><a href=\""
				str << page.link
				str << "\">"
				str << page['title']
				str << "</a></li>\n"
				str << "<li class=\"seperator\">&raquo;</li>\n"
			end
			str << "<li class=\"active\">"
			str << pages.last['title']
			str << "</li>\n</ul>\n"

			str
		end

	end

	Scrapple::Page.send(:include, Breadcrumbs)
end
