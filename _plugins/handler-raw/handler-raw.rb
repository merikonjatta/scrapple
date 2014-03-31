module Scrapple::Plugins
  module HandlerRaw
    class << self

      def confidence(page)
        if page.type != "directory"
          500
        else
          0
        end
      end


      def call(env)
        page = env['scrapple.page']
        mime_type = Scrapple::Webapp.mime_type(File.extname(page.fullpath)) || "text/plain"
        return [200, {"Content-Type" => mime_type}, File.open(page.fullpath)]
      end

    end
  end

  Scrapple::Webapp.register_handler(HandlerRaw, :name => "raw")
end
