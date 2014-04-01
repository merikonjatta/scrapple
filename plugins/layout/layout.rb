require 'tilt'

module Scrapple::Plugins
  class Layout

    class Unapplicable < StandardError; end

    class << self
      def wrap(page, env)
        raise Unapplicable if page['layout'].nil?

        layout_page = Scrapple.content.get(page['layout'])
        raise Unapplicable if layout_page.nil?
        raise Unapplicable if layout_page.path == page.path

        engine = Tilt[layout_page.type]
        raise Unapplicable if engine.nil?

        page.body = engine.new { layout_page.body }.render(page, page: page, env: env) { page.body }

        # Recursive wrapping
        if layout_page['layout']
          page['layout'] = layout_page['layout']
          wrap(page, env)
        else
          page
        end
      rescue Unapplicable
        return page
      end
    end
  end
end
