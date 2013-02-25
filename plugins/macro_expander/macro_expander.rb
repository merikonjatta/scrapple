
module Scrapple::Plugins

  # Mixin modules that handle macro expansions
  class MacroExpander
    UNESCAPE_HTML = Rack::Utils::ESCAPE_HTML.invert
    UNESCAPE_HTML_PATTERN = Regexp.new(UNESCAPE_HTML.keys.map {|pat| Regexp.escape(pat)}.join("|"))

    class << self
      # Unescape HTML entities in the macro code
      def unescape_html(code)
        code.gsub(UNESCAPE_HTML_PATTERN) { |pattern| UNESCAPE_HTML[pattern] || pattern }
      end

      # Shortcut for MacroExpander.new(text, options).expand
      def expand(*args)
        self.new(*args).expand
      end
    end


    def initialize(text, options = {})
      @text = text
      @allowed = options[:allowed] || nil
      @scope   = options[:scope]   || text
      @locals  = options[:locals]  || {}

      @allowed = @allowed.split(',').map(&:strip) if @allowed.is_a? String
    end


    def expand
      return if @allowed == false
      return if @allowed =~ /^(false|no|none)$/i

      scope ||= @text
      scope = bind_to_scope(@scope, @locals)

      @text.gsub(/(.?)\[\[(.*?)\]\]/) do
        begin
          if $1 == "\\"
            "[[#{$2}]]"
          elsif ! allowed?($2)
            $1 + "[[#{$2}]]"
          else
            $1 + @scope.instance_eval(self.class.unescape_html($2)).to_s
          end
        rescue Exception => e
          sorry_couldnt_expand_macro($2, e)
        end
      end
    end


    def bind_to_scope(scope, locals)
      obj = scope.dup
      locals.each do |key, value|
        obj.define_singleton_method(key) { value }
        obj.singleton_class.send(:private, key)
      end
      obj
    end


    # Check if this macro is allowed in the page.
    # @param code [String]  The macro code
    # @return [Bool]
    def allowed?(code)
      case @allowed
      when Array
        macro_name = code.match(/^[^\s({]+/)[0]
        @allowed.include?(macro_name)
      else
        true
      end
    end


    # Sorry. No, really, I am.
    def sorry_couldnt_expand_macro(code, e)
      str = "Sorry, couldn't expand macro [[#{self.class.unescape_html(code)}]]:\n"
      str << "#{e.class.name}: #{e.message}\n at #{e.backtrace[1]})"
      "<pre>" + Rack::Utils.escape_html(str) + "</pre>"
    end


  end


  # Some default macros to include.
  module DefaultMacros
    def h(str)
      Rack::Utils.escape_html(str)
    end
  end

  Scrapple::Page.send(:include, DefaultMacros)

end
