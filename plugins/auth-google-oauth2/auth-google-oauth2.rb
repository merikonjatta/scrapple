require 'auth/auth'

module Scrapple::Plugins::Auth
  module GoogleOauth2
    def self.setup
      # TODO how to catch 401 Unauthorized (from /auth/twitter) if key and secret are invalid
      @client_id    = Scrapple.settings["google_oauth2"]["client_id"]
      @client_secret = Scrapple.settings["google_oauth2"]["client_secret"]

      Scrapple.middleware_stack.insert_before(
        Scrapple::Plugins::Auth::App,
        OmniAuth::Strategies::GoogleOauth2,
        @client_id, @client_secret, {:access_type => 'online', :approval_prompt => ''})

      Scrapple::Plugins::Auth::App.callback_for("google_oauth2") do |env|
        auth_hash = env['omniauth.auth']
        ident = Identity.first_or_new(:provider => "google_oauth2", :uid => auth_hash['uid'])

        unless ident.saved?
          ident.nickname = auth_hash['info']['email']
          ident.image_url = auth_hash['info']['image']
          ident.email = auth_hash['info']['email']
          ident.save
        end

        ident
      end
    end
  end
end

Scrapple::Plugins::Auth::GoogleOauth2.setup
