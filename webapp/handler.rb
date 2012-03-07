module Compound
	class Handler

		def invoke(name, *params)
			raise Compound::ActionNotFound if (action_proc = self.class.action(name)).nil?
			action_proc.call(*params)
		end

		class << self
			def action(name, &block)
				if block_given?
					(@actions ||= {})[name.intern] = block
				else
					@actions[name.intern]
				end
			end

			def actions
				@actions ||= {}
			end
		end

	end
end
