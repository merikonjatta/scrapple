module IndexHelper
  def index
    dirname = File.dirname(self.fullpath)

    entries = Dir.entries(dirname)[2..-1]

    directories = entries.select {|entry| File.directory?(File.join(dirname, entry)) }.sort
    files = (entries - directories).sort
    pages = (directories + files).map { |entry| Scrapple::Page.for(entry) }

    html = %Q(<ul class="index">\n)
    pages.each do |page|
      html << %Q(<li)
      html << %Q( class="active") if page.path == self.path
      html << %Q(><a href=\"#{page.path}\">#{page.path}</a></li>\n)
    end
    html << %Q(</ul>\n)
    html
  end
end


class Scrapple::Page
  include IndexHelper
end
