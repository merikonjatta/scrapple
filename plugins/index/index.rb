module IndexHelper
  def index(options = {})
    dirname = File.dirname(self.fullpath)

    entries = Dir.entries(dirname)[2..-1]

    directories = entries.select {|entry| File.directory?(File.join(dirname, entry)) }.sort
    files = (entries - directories).sort
    paths = (directories + files).map { |entry| Pathname.new(File.join(self.path, "..", entry)).cleanpath.to_s }
    pages = paths.map { |path| Scrapple::Page.for(path, :fetch => true, :ignore_settings_files => true) }

    html = %Q(<ul class="index">\n)
    pages.each do |page|
      html << %Q(<li)
      html << %Q( class="active") if page.path == self.path
      html << %Q(><a href="#{Scrapple::FileLookup.relative_path(page.fullpath, File.dirname(self.fullpath))}">)
      html << (page['title'] || File.basename(page.path))
      html << %Q(</a></li>\n)
    end
    html << %Q(</ul>\n)
    html
  end
end


class Scrapple::Page
  include IndexHelper
end
