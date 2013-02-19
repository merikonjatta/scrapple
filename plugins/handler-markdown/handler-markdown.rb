module Scrapple::Plugins
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

        if page['markdown'].is_a? Hash
          options_from_page = page['markdown'].inject({}) do |result, (key, value)|
            case key
            when /hard_?wrap/i
              renderer_options[:hard_wrap] = value
            else
              options[key.to_sym] = value
            end
          end
        end

        renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(renderer_options), options)
        body = renderer.render(page.expand_macros.content)
        headers = {"Content-Type" => "text/html"}

        return [200, headers, [body]]
      end

    end
  end

  Scrapple::PageApp.register_handler(HandlerMarkdown, :name => "markdown")
end
