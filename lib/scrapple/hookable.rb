module Scrapple
  module Hookable

    # Call hooks for a point
    def call_hooks(point)
      (self.class.hooks[point] ||= []).map do |hook|
        hook.call(self)
      end
    end


    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        @hooks = {}
      end
    end

    module ClassMethods
      attr_reader :hooks

      # Install a hook
      def hook(point, &block)
        (@hooks[point] ||= []) << block
      end
    end

  end
end
