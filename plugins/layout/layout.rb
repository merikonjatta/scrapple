module Scrapple::Plugins
  # Rack middleware that wraps the body in a layout.
  class Layout

    DEFAULT_LAYOUT = "layouts/clean.haml"

    def initialize(app=nil)
      @app = app
    end


    def call(env)
      response = @app.call(env)

      # Only for text/html
      return response unless response[1]['Content-Type'] =~ %r{text/html}

      body = response.last.to_enum.inject("") { |whole, part| whole + part }

      # Avoid wrapping if...
      return response if body.empty?
      return response if looks_like_html?(body)

      new_content = wrap_in_layout(body, env)
      return [response[0], response[1], [new_content]]
    end


    # Recursively wrap a page in the specified layout Page and return the resulting content
    # @param [String] original_content  The content to yield to the layout page (in other words, the rendered result of original_page)
    def wrap_in_layout(original, env)
      layout_page = get_layout_page(env)
      return original if layout_page.nil?

      engine = Tilt[layout_page.type]
      return original if engine.nil?

      new_rendered = engine.new{ layout_page.content }.render(self, :env => env) { original }

      # TODO Call recursively in case layout is nested

      return new_rendered
    end


    # Get the Scrapple::Page object for the layout file that
    # should be used to wrap the specified Page.
    # @param [env] env   Rack env for this request
    # @return [Scrapple::Page, nil]  The page that should be used to wrap the original page, or nil if not found
    def get_layout_page(env)
      if page = env['scrapple.page']
        return nil if page['layout'] =~ /^(no|false|none)$/i
        layout = page['layout']
      else
        layout = env['scrapple.layout']
      end

      layout ||= DEFAULT_LAYOUT


      # Try to find the actual layout file
      # Create a new Page object for the layout file
      layout_page = Scrapple::Page.for(layout, :fetch => true)
      # Layout file not found?
      return nil if layout_page.nil?
      # Layout file is the same as the file to be wrapped?
      return nil if page.fullpath == layout_page.fullpath

      # Copy settings from original to layout page, except for which layout to use
      page.settings.hash.delete("layout")
      layout_page.settings.merge!(page.settings)

      return layout_page
    end


    # Determine if a string looks like an html document.
    def looks_like_html?(string)
      string =~ /\<html.*\>.*\<head.*\>.*\<body/im
    rescue
      # TODO Twitter auth callback body results in "Invalid byte sequence in US-ASCII"
      true
    end
  end


  Scrapple.middleware_stack.insert_before(Scrapple::Webapp, Layout)
end
