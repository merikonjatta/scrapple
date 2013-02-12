module Layout
  class << self

    def within_layout(page)
      return if page['handler'] != "default"
      return if page['layout'].nil?

      layout_file = Compund::FileFinder.find(page['layout'], Compund::Webapp.content_dir)
      return if page.file == layout_file

      wrapper_page = Compund::Page.new do |pg|
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

Compund::Page.hook(:after_render) do |page|
  Layout.within_layout(page)
end
