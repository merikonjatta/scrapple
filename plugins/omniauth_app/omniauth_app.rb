module Scrapple::Plugins
	module OmniAuthApp
		OMNIAUTH_ROOT = File.expand_path("..", __FILE__)

		module_function
		def strategy(name, *args, &block)
			App.strategy(name, *args, &block)
		end

		# Handles login with OmniAuth.
		# This plugin itself does not provide any authentication strategies:
		# it merely acts as a base to bind other plugins like OmniAuth-Twitter.
		class App < Sinatra::Base
			@strategies = {}

			# Add a strategy. Inserts its middleware, and sets up a route that catches its
			# callback.
			def self.strategy(name, *args, &block)
				name = name.to_s

				ware = ::OmniAuth::Strategies.const_get("#{::OmniAuth::Utils.camelize(name)}")
				Scrapple.middleware_stack.insert_before(OmniAuthApp::App, ware, *args, &block)

				match "/auth/#{name}/callback"  do
					callback(name)
				end
			end

			# Helper for defining routes that match any of get, post, put, and delete
			def self.match(pattern, &block)
				%w(get post put delete).map(&:to_sym).each do |verb|
					self.send(verb, pattern, &block)
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
			def callback(name)
				binding.pry
			end
		end

	end

	Scrapple.middleware_stack.insert_after(Layout, OmniAuthApp::App)
end
