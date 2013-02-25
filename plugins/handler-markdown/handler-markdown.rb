module Scrapple::Plugins
  module HandlerMarkdown

    DEFAULT_MARKDOWN_OPTIONS = {
      :no_intra_emphasis => true,
      :fenced_code_blocks => true,
      :autolink => true
    }

    DEFAULT_HTML_OPTIONS = {
      :hard_wrap => true
    }


    class << self

      def confidence(page)
        if %w(md mkd markdown mdown).include?(page.type)
          1000
        else
          0
        end
      end


      def call(env)
        page = env['scrapple.page']

        md_options = DEFAULT_MARKDOWN_OPTIONS.dup
        html_options = DEFAULT_HTML_OPTIONS.dup

        if page['markdown'].is_a? Hash
          page['markdown'].each do |key, value|
            case key
            when /hard_?wrap/i
              html_options[:hard_wrap] = value
            else
              md_options[key.to_sym] = value
            end
          end
        end

        md = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(html_options), md_options)

        content = Scrapple::Plugins::MacroExpander.expand(page.content,
                                                          :allowed => page['macros'],
                                                          :scope => page,
                                                          :locals => {:env => env})
        content = md.render(content)
        content = Scrapple::Plugins::Layout.wrap(content, env)

        headers = {"Content-Type" => "text/html"}
        return [200, headers, [content]]
      end

    end
  end

  Scrapple::Webapp.register_handler(HandlerMarkdown, :name => "markdown")
end
