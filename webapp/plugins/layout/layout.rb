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

      wrapper_page = Scrapple::Page.new do |wp|
        wp.settings = page.settings
        wp.params = page.params
        wp.headers = page.headers
        wp.status = page.status

        # Please render the layout file
        wp.file = layout_file
        # Set the original content as a local data
        wp.settings['content'] = page.body
        # Don't read settings files, they might cause infinite loops rendering layouts
        wp.ignore_settings_files = true
      end

      (page.status, page.headers, page.body) = wrapper_page.render
    end

  end
end

Scrapple::Page.hook(:after_render) do |page|
  Layout.wrap_with_layout(page)
end
