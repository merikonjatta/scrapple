module Layout
  class << self

    def wrap_with_layout(page)
      return if page['handler'] != "default"
      return if page['layout'].nil?

      layout_file = Scrapple::FileFinder.find_nearest_in_ancestors(page['layout'], page.file, Scrapple::Webapp.content_dir)
      return if page.file == layout_file

      wrapper_page = Scrapple::Page.new do |pg|
        pg.file = layout_file
        pg.locals['content'] = page.body

        pg.ignore_settings_files = true
        pg.handler = page.handler
        pg.headers = page.headers
        pg.status = page.status
      end

      (page.status, page.headers, page.body) = wrapper_page.render
    end

  end
end

Scrapple::Page.hook(:after_render) do |page|
  Layout.wrap_with_layout(page)
end
