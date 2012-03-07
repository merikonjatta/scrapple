module Compound
	class Handler

		def invoke(name, *params)
			raise Compound::ActionNotFound if (proc = self.class.actions[name.intern]).nil?
			proc.call(*params)
		end


		class << self
			def action(name, &block)
				(@actions ||= {})[name.intern] = block
			end

			def view(&block)
				action(:view, &block)
			end

			def edit(&block)
				action(:edit, &block)
			end

			def actions
				@actions ||= {}
			end
		end

	end
end
