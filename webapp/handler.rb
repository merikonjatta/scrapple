module Compound
	class Handler

		def invoke(name, *params)
			raise Compound::ActionNotFound unless (self.public_methods - Compound::Handler.public_instance_methods).include? name.intern
			self.send(name.intern, *params)
		end

	end
end
