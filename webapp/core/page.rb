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


    attr_accessor :file, :content, :directives, :params,
                  :locals, :handler_name, :action, :body, :headers, :status

    def initialize
      yield(self) if block_given?
    end


    # Call hooks registered for point.
    def call_hooks(point)
      self.class.hooks[point].each do |block|
        block.call(self)
      end
    end


    def render
      call_hooks(:before_render)
      @content = File.read(@file) if (!@file.nil? && @content.nil?)
      @directives   ||= {}
      parse_content
      @handler_name ||= "default"
      @action       ||= "view"
      @status  ||= 200
      @headers ||= {}
      @locals  ||= {}

      Compund::Webapp.handlers[@handler_name].send(@action, self)

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
          if line.strip.blank? && directives.count == 9
            num_noncontent_lines += 1 and next
          else
            break
          end
        end
      end

      @content = @content.lines.to_a[num_noncontent_lines..-1].join
      @directives.merge!(directives)
    end
  end
end
