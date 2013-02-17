class ExpandMacros
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    return [status, headers, body] unless headers['Content-Type'] =~ %r{text/html}

    page = env['scrapple.page']
    params = env['scrapple.params']

    new_body = Expand.new(page).expand_macros(body.join)
    return [status, headers, [new_body]]
  end


  # Class that handles macro expansions.
  class Expand
    UNESCAPE_HTML = Rack::Utils::ESCAPE_HTML.invert
    UNESCAPE_HTML_PATTERN = Regexp.new(UNESCAPE_HTML.keys.map {|pat| Regexp.escape(pat)}.join("|"))

    def initialize(page)
      @page = page

      @allowed_macros = case page['macros']
                        when false, /^(false|no|none)/i
                          []
                        when String
                          page['macros'].split(',').map(&:strip)
                        else
                          nil
                        end
    end


    # Expand all allowed macros in a body string.
    # @param body [String]
    # @return [String]
    def expand_macros(body)
      body.gsub(/(.?)\[\[(.*?)\]\]/) do
				if $1 == "\\"
					"[[#{$2}]]"
				else
					$1 + expand_macro($2)
				end
      end
    end


    # Expand a piece of macro code.
    # @param code [String]
    # @return [String] output returned from the code
    def expand_macro(code)
      macro_name = code.match(/^[^\s(]+/)[0]
      if allowed?(macro_name)
        @page.instance_eval(unescape_html(code)).to_s
      else
        "[[#{code}]]"
      end
    rescue Exception => e
      str = "Sorry, couldn't expand macro [[#{unescape_html(code)}]]:\n"
			str << "#{e.class.name}: #{e.message}\n at #{e.backtrace[1]})"
      if @page['macro_debug']
				str << "\nBacktrace: "
        str << e.backtrace.join("\n")
      end
      "<pre>" + Rack::Utils.escape_html(str) + "</pre>"
    end


    # Check if this macro is allowed in the current page.
    # @param macro_name [String]  The name of the macro
    # @return [Bool]
    def allowed?(macro_name)
      case @allowed_macros
      when Array
        @allowed_macros.include?(macro_name)
      else
        true
      end
    end

    # Unescape HTML entities in the macro code
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

Scrapple.insert_middleware_before(Scrapple::PageApp, ExpandMacros)

class Scrapple::Page
  include ExpandMacros::DefaultMacros
end
