class HandlerEditor
  class << self

    def can_handle?(type)
      type != "directory"
    end

    def priority
      0
    end


    def handle(page)
      page['macros'] = false
      page['editing_content'] = File.read(page.fullpath)
      page['layout'] = false

      body = Tilt['haml'].new(File.expand_path("../content/__editor.haml", __FILE__)).render(page)

      [200, {"Content-Type" => "text/html"}, [body]]
    end
    
  end
end


Scrapple::PageApp.register_handler(HandlerEditor, :name => "editor")

proc {
  css_path = File.expand_path("../content/css", __FILE__)
  Sass::Plugin.add_template_location(css_path, css_path)
}.call
