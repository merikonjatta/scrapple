module Compound
	class Handler

		def initialize(app)
			@app = app
		end

		# Delegate all unknown methods to base app
		def method_missing(method_name, *args)
			raise NoMethodError unless @app.public_methods.include? method_name.intern
			@app.send(method_name, *args)
		end

		def invoke(action_name, *args)
			raise Compound::ActionNotFound unless (self.public_methods - Compound::Handler.public_instance_methods).include? action_name.intern
			self.send(action_name.intern, *args)
		end

	end
end
