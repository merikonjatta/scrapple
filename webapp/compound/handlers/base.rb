module Compound
	module Handlers
		class Base

			def initialize(app)
				@app = app
			end

			# Invoke an action defined as a method
			def invoke(action_name, *args)
				raise Compound::ActionNotFound unless self.public_methods.include? action_name.intern
				self.send(action_name.intern, *args)
			end

			# Delegate all unknown methods to base app
			def method_missing(method_name, *args)
				raise NoMethodError, "No such method #{method_name}" unless @app.public_methods.include? method_name.intern
				@app.send(method_name, *args)
			end

		end
	end
end
