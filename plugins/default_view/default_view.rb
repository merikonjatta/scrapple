module DefaultView
  class << self

    def can_handle?(extension)
      Tilt.mappings.keys.include? extension
    end


    def handle(page)
      ext = page.fullpath.sub(/^.*\./, '')
      engine = Tilt[ext]

      headers = {}
      body = ""

      if engine.nil?
        body = page.content
      else
        body = engine.new{ page.content }.render(page)
      end

      if %(sass scss).include?(ext)
        headers['Content-Type'] = "text/css"
      elsif mime_type = Scrapple::Webapp.mime_type(ext)
        headers['Content-Type'] = mime_type
      else
        headers['Content-Type'] = "text/html"
      end

      return [200, headers, [body]]
    end

  end
end

Scrapple::PageApp.register_handler(DefaultView, :name => "default")
