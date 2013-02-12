module Compund
  class Page
    @hooks = {
      :before_render => [],
      :after_render => [],
    }

    class << self
      attr_reader :hooks
      def hook(point, &block)
        @hooks[point] << block
      end
    end

    attr_accessor :params, :locals, :body, :headers, :status
    attr_accessor :handler
    attr_accessor :file, :content

    def initialize
      @locals       ||= {}
      @params       ||= {}

      yield(self) if block_given?

      @content ||= File.read(@file) unless @file.nil?
      @handler ||= self["handler"] || "default"
      @headers ||= self["headers"] || {}
      @status  ||= self["status"]  || 200
      parse_content
      apply_locals
    end


    # Call hooks registered for point.
    def call_hooks(point)
      self.class.hooks[point].map { |block| block.call(self) }
    end

    # Get variables from params, and locals, in that order of priority
    def [](key)
      @params[key] || @locals[key]
    end


    def render
      call_hooks(:before_render)
      Compund::Webapp.handlers[@handler].handle(self)
      call_hooks(:after_render)

      [@status, @headers, @body]
    end


    def parse_content
      num_noncontent_lines = 0
      directives = {}
      rdirective = /\A(.*?):(.*)\Z/

      @content.each_line do |line|
        if md = line.match(rdirective)
          directives[md[1].strip] = md[2].strip
          num_noncontent_lines += 1
        else
          if line.strip.blank? 
            if directives.count == 0
              num_noncontent_lines += 1 and next
            else
              num_noncontent_lines += 1 and break
            end
          else
            break
          end
        end
      end

      @content = @content.lines.to_a[num_noncontent_lines..-1].join
      @locals.merge!(directives)
    end


    def apply_locals
      @locals.each do |key, value|
        case key
        when "handler"
          @handler= value
        end
      end
    end
  end
end
