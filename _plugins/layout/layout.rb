require 'tilt'

module Scrapple::Plugins
  class Layout

    class << self
      def wrap(body, env)
        page = env['scrapple.page']
        return body if page.nil?

        layout_page = get_layout_page(page)
        return body if page.fullpath == layout_page.fullpath

        engine = Tilt[layout_page.type]
        return body if engine.nil?

        wrapped = engine.new { layout_page.content }.render(page, :env => env) { body }

        # Recursive wrapping
        page['layout'] = layout_page['layout']
        page['layout'] ? wrap(wrapped, page) : wrapped
      end


      def get_layout_page(page)
        page['layout'] ||= DEFAULT_LAYOUT
        Scrapple::Page.for(page['layout'], :fetch => true, :ignore_perdir_files => true)
      end
    end
  end
end
