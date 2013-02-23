module Scrapple::Plugins
  module HandlerText
    class << self
      # List taken mostly from Ack
      def confidence(page)
        if %w(txt text).include?(page.type)
          1000
        else
          0
        end
      end


      def call(env)
        page = env['scrapple.page']
        page['macros'] = false
        page['file_content'] = Rack::Utils.escape_html(File.read(page.fullpath))

        body = Rack::Utils.escape_html(File.read(page.fullpath)).gsub(/\r?\n/, '<br />')

        [200, {"Content-Type" => "text/html"}, [body]]
      end
    end
  end

  Scrapple::Webapp.register_handler(HandlerText, :name => "text")
end
