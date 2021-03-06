module Scrapple::Plugins::Auth
  # Handles login UI and callbacks for OmniAuth.
  class App < Sinatra::Base

		def call(env)
			env['scrapple.user'] = User.get(env['rack.session']['user_id'])
			super
		end


		def self.callback_for(name, &block)
      match "/auth/#{name}/callback" do
				ident = block.call(env)
				process_identity(ident)
      end
		end

		def process_identity(ident)
			if already_logged_in = env['scrapple.user']
				already_logged_in.identities << ident
				already_logged_in.save
			else
				if ident.user.nil?
					user = User.create(:identities => [ident], :username => ident.nickname)
					env['rack.session']['user_id'] = user.id
				else
					env['rack.session']['user_id'] = ident.user.id
				end
			end

			redirect to '/auth/profile'
		end

		# Log out
		get '/auth/logout' do
			env['rack.session']['user_id'] = nil
			env['scrapple.user'] = nil
			redirect to "/"
		end

		# Where new users fill in their profiles, or otherwise choose to merge with another identity
		get '/auth/profile' do
			redirect to "/auth/login" if env['scrapple.user'].nil?
      pass
		end

		# Updating profile info
		post '/auth/profile' do
			user = env['scrapple.user']
			user.username = params['username']
			if user.save
				redirect to '/'
			else
				# TODO flash
				haml :profile
			end
		end

    # Helper for defining routes that match any of get, post, put, and delete
    def self.match(pattern, &block)
      %w(get post put delete).map(&:to_sym).each do |verb|
        self.send(verb, pattern, &block)
      end
    end
  end

end
