module Layout
  class << self

    def within_layout(page)
      return if page['layout'].nil?
      return if page['handler'] != "default"

      layout_file = Compund::Webapp.find_file(page['layout'])

      wrapper_page = Compund::Page.new do |pg|
        pg.file = layout_file
        pg.locals['content'] = page.body

        pg.params = page.params
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
