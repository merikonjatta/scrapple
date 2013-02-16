module HandlerMarkdown
  class << self

    def confidence(page)
      if %w(md mkd markdown mdown).include?(page.type)
        1000
      else
        0
      end
    end

    def priority
      1000
    end

    def handle(page)
      options = {
        :no_intra_emphasis => true,
        :fenced_code_blocks => true,
        :autolink => true
      }

      renderer_options = {
        :hard_wrap => true
      }

      renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(renderer_options), options)
      body = renderer.render(page.content)
      headers = {"Content-Type" => "text/html"}

      return [200, headers, [body]]
    end

  end
end

Scrapple::PageApp.register_handler(HandlerMarkdown, :name => "markdown")