module Layout
  class << self

    def wrap_with_layout(page)
      # Only supports default handler.
      return if page['handler'] != "default"
      # Layout is not specified? Don't do anything.
      return if page['layout'].nil?

      layout_file = Scrapple::FileFinder.find_nearest_in_ancestors(page['layout'], page.file, Scrapple::Webapp.content_dir)

      # Layout file is the same as the file to be wrapped? Don't do anything.
      return if page.file == layout_file
      # Layout file not found? Give up.
      return if layout_file.nil?
      
      ext = layout_file.sub(/^.*\./, '')
      engine = Tilt[ext]
      # Tilt doesn't know how? Give up.
      return if engine.nil?

      page.body = engine.new(layout_file).render(page) { page.body }
      page.headers['content-type'] = "text/html"
    end

  end
end

Scrapple::Page.hook(:after_render) do |page|
  Layout.wrap_with_layout(page)
end
