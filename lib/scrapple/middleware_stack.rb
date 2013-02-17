module Scrapple
	class MiddlewareStack

		def initialize
			@stack = []
		end

		attr_reader :stack

		def append(klass, *args, &block)
			insert_at(-1, klass, *args, &block)
		end

		def prepend(klass, *args, &block)
			insert_at(0, klass, *args, &block)
		end

		def insert_after(existing, klass, *args, &block)
			index = check_exists(existing)
			insert_at(index+1, klass, *args, &block)
		end

		def insert_before(existing, klass, *args, &block)
			index = check_exists(existing)
			insert_at(index, klass, *args, &block)
		end

		def insert_at(index, klass, *args, &block)
			entry = {
				:klass => klass,
				:args => args || [],
				:block => block
			}
			@stack.insert(index, entry)
		end

		def check_exists(klass)
			index = @stack.index { |entry| entry[:klass] == klass }
			raise ArgumentError, "#{klass.name} not found in middleware stack" unless index
			index
		end

		def middleware
			stack[0..-2].map { |entry| [entry[:klass], entry[:args], entry[:block]] }
		end

		def endpoint
			stack.last[:klass]
		end

		# Returns a full application with all apps in the stack.
		def to_app
			Rack::Builder.new {
				Scrapple.middleware_stack.middleware.each { |ware| use ware[0], *ware[1], &ware[2] }
				run Scrapple.middleware_stack.endpoint
			}
		end

	end
end
