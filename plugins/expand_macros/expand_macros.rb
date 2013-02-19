
module Scrapple::Plugins

  # Mixin modules that handle macro expansions
  module ExpandMacros

    # Expand all allowed macros in a body string.
    # @return [Page] self, for chainability
    def expand_macros
      return if self['macros'] == false
      return if self['macros'] =~ /^(false|no|none)$/i

      self.content.gsub!(/(.?)\[\[(.*?)\]\]/) do
        begin
          if $1 == "\\"
            "[[#{$2}]]"
          elsif ! macro_allowed?($2)
            $1 + "[[#{$2}]]"
          else
            $1 + instance_eval(Helpers.unescape_html($2)).to_s
          end
        rescue Exception => e
          sorry_couldnt_expand_macro($2, e)
        end
      end

      self
    end


    # Check if this macro is allowed in the page.
    # @param code [String]  The macro code
    # @return [Bool]
    def macro_allowed?(code)
      case self['macros']
      when String
        macro_name = code.match(/^[^\s({]+/)[0]
        self['macros'].split(',').map(&:strip).include?(macro_name)
      else
        true
      end
    end


    # Sorry. No, really, I am.
    def sorry_couldnt_expand_macro(code, e)
      str = "Sorry, couldn't expand macro [[#{Helpers.unescape_html(code)}]]:\n"
      str << "#{e.class.name}: #{e.message}\n at #{e.backtrace[1]})"
      if self['debug_macros']
        str << "\nBacktrace: \n"
        str << e.backtrace.join("\n")
      end
      "<pre>" + Rack::Utils.escape_html(str) + "</pre>"
    end



    module Helpers
      UNESCAPE_HTML = Rack::Utils::ESCAPE_HTML.invert
      UNESCAPE_HTML_PATTERN = Regexp.new(UNESCAPE_HTML.keys.map {|pat| Regexp.escape(pat)}.join("|"))

      module_function

      # Unescape HTML entities in the macro code
      def unescape_html(code)
        code.gsub(UNESCAPE_HTML_PATTERN) { |pattern| UNESCAPE_HTML[pattern] || pattern }
      end
    end

  end


  # Some default macros to include.
  module DefaultMacros
    def h(str)
      Rack::Utils.escape_html(str)
    end
  end

  Scrapple::Page.send(:include, ExpandMacros)
  Scrapple::Page.send(:include, DefaultMacros)

end
