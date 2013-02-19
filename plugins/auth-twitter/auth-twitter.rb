require 'auth/auth'

module Scrapple::Plugins::Auth
  module Twitter
    def self.setup
      # TODO how to catch 401 Unauthorized (from /auth/twitter) if key and secret are invalid
      @consumer_key    = Scrapple.settings["twitter"]["consumer_key"]
      @consumer_secret = Scrapple.settings["twitter"]["consumer_secret"]

      Scrapple.middleware_stack.insert_before(Scrapple::Plugins::Auth::App, OmniAuth::Strategies::Twitter, @consumer_key, @consumer_secret)

      Scrapple::Plugins::Auth::App.callback_for("twitter") do |env|
        auth_hash = env['omniauth.auth']
        ident = Identity.first_or_new(:provider => "twitter", :uid => auth_hash['uid'])

        unless ident.saved?
          ident.nickname = auth_hash['info']['nickname']
          ident.image_url = auth_hash['info']['image']
          ident.save
        end

        ident
      end
    end
  end
end

Scrapple::Plugins::Auth::Twitter.setup
