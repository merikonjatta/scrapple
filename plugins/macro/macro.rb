class Macro
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    return [status, headers, body] unless headers['Content-Type'] =~ %r{text/html}

    page = env['scrapple.page']
    params = env['scrapple.params']

    new_body = Expand.new(page).expand_macros(body)
    return [status, headers, [new_body]]
  end


  class Expand
    UNESCAPE_HTML = Rack::Utils::ESCAPE_HTML.invert
    UNESCAPE_HTML_PATTERN = Regexp.new(UNESCAPE_HTML.keys.map {|pat| Regexp.escape(pat)}.join("|"))

    def initialize(page)
      @page = page

      @allowed_macros = case page['macros']
                        when /^(false|no|none)/i
                          []
                        when String
                          page['macros'].split(',').map(&:strip)
                        else
                          nil
                        end
    end


    def expand_macros(body)
      body.join.gsub(/\[\[(.*?)\]\]/) do |macro_brackets|
        code = macro_brackets[2...-2].strip
        macro_name = code.match(/^[^\s(]+/)[0]

        if allowed?(macro_name)
          expand_macro(code)
        else
          macro_brackets
        end
      end
    end


    def allowed?(macro_name)
      case @allowed_macros
      when Array
        @allowed_macros.include?(macro_name)
      else
        true
      end
    end


    def expand_macro(code)
      @page.instance_eval(unescape_html(code))
    rescue Exception => e
      Rack::Utils.escape_html("(Sorry, couldn't expand macro [[#{code}]]: #{e.class.name}: #{e.message})")
    end


    def unescape_html(code)
      code.gsub(UNESCAPE_HTML_PATTERN) { |pattern| UNESCAPE_HTML[pattern] || pattern }
    end

  end


  # Some default macros to include.
  module DefaultMacros
    def h(str)
      Rack::Utils.escape_html(str)
    end
  end

end

Scrapple.insert_middleware_before(Scrapple::PageApp, Macro)

class Scrapple::Page
  include Macro::DefaultMacros
end
