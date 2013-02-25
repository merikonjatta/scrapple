require 'sass/sass'

module Scrapple::Plugins
  # Handler that shows an editor.
  # Dependencies:
  #   * Sass-Rack
  #   * jQuery
  class HandlerEditor
    class << self

      def confidence(page)
        if page.type != "directory"
          100
        else
          0
        end
      end


      def call(env)
        page = env['scrapple.page']
        page['macros'] = false
        page['editing_content'] = File.read(page.fullpath)
        page['stylesheets'] ||= []
        page['stylesheets'] << "/css/editor.css"
        page['javascripts'] ||= []
        page['javascripts'] << "/js/jquery.js"
        page['javascripts'] << "/js/jquery.vimarea.js"
        page['javascripts'] << "/js/editor.js"
        page['body_class']  = "full"

        body = Tilt['haml'].new(File.expand_path("../content/__editor.haml", __FILE__)).render(page)
        body = Scrapple::Plugins::Layout.wrap(body, env)

        [200, {"Content-Type" => "text/html"}, [body]]
      end

    end
  end


  Scrapple::Webapp.register_handler(HandlerEditor, :name => "editor")

  css_path = File.expand_path("../content/css", __FILE__)
  Sass::Plugin.add_template_location(css_path, css_path)

end
