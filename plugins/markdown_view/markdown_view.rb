module MarkdownView
  class << self

    def can_handle?(extension)
      %w(md mkd markdown mdown).include? extension
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

Scrapple::PageApp.register_handler(MarkdownView, :name => "markdown")
