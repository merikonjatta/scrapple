module Scrapple::Plugins
  module RendererRaw
    class << self

      def render(page, options={})
        mime_type = Scrapple::Webapp.mime_type(page.type) || "text/plain"
        return [200, {"Content-Type" => mime_type}, [page.body]]
      end

    end
  end

  Scrapple.register_renderer(RendererRaw, :name => "raw")
end
