require 'data_mapper'
# TODO don't put data there
DataMapper.setup(:default, "sqlite:///#{ENV['CONTENT_DIR']}/scrapple.db")

require 'auth/models/user'
require 'auth/models/identity'
DataMapper.finalize
DataMapper.auto_upgrade!

require 'auth/app'
Scrapple.middleware_stack.insert_before(Scrapple::PageApp, Scrapple::Plugins::Auth::App)

module Scrapple::Plugins
	# The Auth plugins provides central user management, persistence, and UI for
	# authentication.  Auth itself does not provide a concrete means of
	# authenticating a user: that's a job for other plugins implemented on top of
	# it. 
	# 
	# Auth is built on OmniAuth. It provides an API for using any kind of OmniAuth
	# strategy.
	module Auth
		module_function

		# Add a strategy. Inserts its middleware in the stack, then delegates to App
		# to set up routes.
		def strategy(name, *args, &block)
			name = name.to_s
			ware = OmniAuth::Strategies.const_get(OmniAuth::Utils.camelize(name))
			Scrapple.middleware_stack.insert_before(App, ware, *args, &block)

			App.strategy(name, *args, &block)
		end

	end
end
