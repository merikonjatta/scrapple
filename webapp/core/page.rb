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

    # Params that came in from the browser. Generally not for modifying.
    # Has precedence over locals.
    attr_accessor :params
    
    # Local settings for this page. Includes directives found in file,
    # but can be used to store arbitrary data
    attr_accessor :locals

    # The handler this page will use on render.
    # Will be overridden by locals and params.
    attr_accessor :handler

    # What file in the content dir this page represents.
    # Note that this may not be a real file.
    attr_accessor :file

    # The contents of the file this page represents.
    # The main job of plugin hooks would be to overwrite this with modified strings.
    attr_accessor :content

    # Body, headers and status to be returned on render to Compund::Webapp
    # The main job of handlers would be to overwrite these.
    attr_accessor :body, :headers, :status

    # Pass a block to configure this page.
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


    # Render this page. Returns a Rack response array.
    def render
      call_hooks(:before_render)
      Compund::Webapp.handlers[@handler].handle(self)
      call_hooks(:after_render)

      [@status, @headers, @body]
    end


    # Parse the content and extract directives into locals.
    # Also delete the lines that represented locals.
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
