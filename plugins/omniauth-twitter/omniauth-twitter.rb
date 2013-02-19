require 'auth/auth'

module Scrapple::Plugins::Auth
  module Twitter
    def self.setup
      @consumer_key    = Scrapple.settings["twitter"]["consumer_key"]
      @consumer_secret = Scrapple.settings["twitter"]["consumer_secret"]
      Scrapple::Plugins::Auth.strategy(:twitter, @consumer_key, @consumer_secret)
    end
  end
end

Scrapple::Plugins::Auth::Twitter.setup
