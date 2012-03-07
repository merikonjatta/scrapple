require 'sinatra/base'

class CompoundBase < Sinatra::Base
	if development?
		require 'pry'
	end

	get '/system' do
		'System'
	end

	get '/system/users' do
		'Users'
	end

	get '/*/view' do
		"Hello, World! => #{params[:splat]}"
	end
end
