module Scrapple::Plugins::Auth
  # Handles login UI and callbacks for OmniAuth.
  class App < Sinatra::Base
    # Add a strategy. Sets up a route that catches its callback.
    # @param name [String] Name of the Strategy. The OmniAuth::Strategy class
    #                      must be able to be inferred from the name.
    def self.strategy(name, *args, &block)
      match "/auth/#{name}/callback"  do
        callback(name)
      end
    end

    # Centralized Login page with links to all /auth/:strategy URLs
    get '/omniauth/login' do
      haml :login
    end

    # Centralized failure page
    get '/auth/failure' do
      haml :failure
    end

    # Callback routine for all strategies.
    def callback(strategy_name)
      auth_hash = env['omniauth.auth']
      user = User.for_identity(auth_hash['provider'], auth_hash['uid'])
      identity = user.identities.last

      # This is provider-dependent
      user.username = auth_hash['info']['nickname']
      user.identities.last.nickname = auth_hash['info']['nickname']
      user.identities.last.image_url = auth_hash['info']['image']

      unless user.save && user.identities.last.save
        # Handle validation errors
      end

      if user.saved? && user.identities.last.saved?
        env['rack.session']['user_id'] = user.id
      else
        binding.pry
      end

      redirect to("/")
    end

    # Helper for defining routes that match any of get, post, put, and delete
    def self.match(pattern, &block)
      %w(get post put delete).map(&:to_sym).each do |verb|
        self.send(verb, pattern, &block)
      end
    end
  end

end
