require 'omniauth_app/omniauth_app'

module Scrapple::Plugins::OmniAuthApp
	module Twitter
		def self.setup
			@consumer_key = Scrapple.settings["twitter"]["consumer_key"]
			@consumer_secret = Scrapple.settings["twitter"]["consumer_secret"]
			Scrapple::Plugins::OmniAuthApp.strategy(:twitter, @consumer_key, @consumer_secret)
		end
	end

end

Scrapple::Plugins::OmniAuthApp::Twitter.setup
