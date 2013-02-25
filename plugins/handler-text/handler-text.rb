module Scrapple::Plugins
  module HandlerText
    class << self
      def confidence(page)
        if %w(txt text).include?(page.type)
          1000
        else
          0
        end
      end


      def call(env)
        page = env['scrapple.page']

        body = format(File.read(page.fullpath))
        body = Scrapple::Plugins::Layout.wrap(body, env)

        [200, {"Content-Type" => "text/html"}, [body]]
      end


      def format(text)
        t = text.dup
        t = Rack::Utils.escape_html(t)
        t.gsub!(/\r\n?/, "\n")
        t.gsub!(/\n/, "<br />")
      end
    end
  end

  Scrapple::Webapp.register_handler(HandlerText, :name => "text")
end
