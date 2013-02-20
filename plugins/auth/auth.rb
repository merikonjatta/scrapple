require 'data_mapper'
DataMapper.setup(:default, "yaml:///#{Scrapple.data_dir}/auth.yaml")

require 'auth/models/user'
require 'auth/models/identity'
DataMapper.finalize
DataMapper.auto_upgrade!

require 'auth/app'
Scrapple.middleware_stack.insert_before(Scrapple::Webapp, Scrapple::Plugins::Auth::App)

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
      ware = OmniAuth::Strategies.const_get(OmniAuth::Utils.camelize(name.to_s))
      Scrapple.middleware_stack.insert_before(App, ware, *args, &block)
    end

  end
end
