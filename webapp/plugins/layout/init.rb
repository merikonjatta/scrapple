module Layout
  class << self

    def within_layout(page)
      return if page.directives['layout'].nil?
      return if page.handler_name != "default"

      layout_file = Compund::Webapp.find_file(page.directives['layout'])

      wrapper_page = Compund::Page.new
      wrapper_page.file = layout_file
      wrapper_page.locals = {:content => page.body}
      wrapper_page.params = page.params
      wrapper_page.handler_name = page.handler_name
      wrapper_page.action = page.action
      wrapper_page.headers = page.headers
      wrapper_page.status = page.status
      (page.status, page.headers, page.body) = wrapper_page.render
    end

  end
end

Compund::Page.hook(:after_render) do |page|
  Layout.within_layout(page)
end
