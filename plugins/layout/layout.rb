# Insert before scrapple
class Layout

  class GiveUp < Exception; end

  def initialize(app=nil)
    @app = app
  end


  def call(env)
    status, headers, body = @app.call(env)

    # Only for text/html
    return [status, headers, body] if headers['Content-Type'] !~ %r{text/html}

    page = env['scrapple.page']
    new_content = wrap_in_layout(page, body.join)
    return [status, headers, [new_content]]
  end

  
  # Recursively wrap a page in the specified layout Page and return the resulting content
  # @param [Scrapple::Page] original_page  The original Page object
  # @param [String] original_content  The content to yield to the layout page (in other words, the rendered result of original_page)
  def wrap_in_layout(original_page, original_rendered)
    layout_page = get_layout_page_for(original_page)
    return original_rendered if layout_page.nil?

    ext = layout_page.fullpath.sub(/^.*\./, '')
    engine = Tilt[ext]
    return original_rendered if engine.nil?

    new_rendered = engine.new{ layout_page.content }.render(original_page){ original_rendered }

    # Call recursively in case layout is nested
    new_rendered = wrap_in_layout(layout_page, new_rendered)

    return new_rendered
  end


  # Get the Scrapple::Page object for the layout file that
  # should be used to wrap the specified Page.
  # @param [Scrapple::Page] page  The original page
  # @return [Scrapple::Page, nil]  The page that should be used to wrap the original page, or nil if not found
  def get_layout_page_for(page)
    return nil if page['layout'].nil?

    # Try to find the actual layout file
    layout_file = Scrapple::FileLookup.find_first_ascending(page['layout'], page.fullpath)
    # Layout file not found?
    return nil if layout_file.nil?
    # Layout file is the same as the file to be wrapped?
    return nil if page.fullpath == layout_file

    # Create a new Page object for the layout file
    layout_page = Scrapple::Page.for(layout_file, page.root, :fetch => true)
    # Copy settings from original to layout page, except for which layout to use
    page.settings.hash.delete("layout")
    layout_page.settings.merge(page.settings)

    return layout_page
  end
end


Scrapple.insert_middleware_before(Scrapple::PageApp, Layout)
