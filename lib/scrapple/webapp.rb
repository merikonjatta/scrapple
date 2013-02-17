require 'sinatra/base'

module Scrapple

  class Webapp < Sinatra::Base

		# Not putting this stuff in a configure block because FileLookup.roots must
		# be configured first. The configure block is simply executed immediately
		# while this class definition is taking place. Making this an explicit call
		# makes things easier.
		def self.setup
			# The first _settings.txt found is read for webapp config
			setng = Settings.new.parse(FileLookup.find("_settings"), :dont_stop => true)[1]

			# Relative URL root needs preceding slash, but no trailing slash
			relroot = setng["relative_url_root"] || "/"
			set :relative_url_root, relroot.sub(/^[^\/]/, '/\0').sub(/\/$/, '')
		end

		# A get route with handler specified
    get %r{(.*)/(as|with|in)/(.+)} do |path, dummy, handler|
      params['path'] = path
      params['handler'] = handler
      for_path(path)
    end

		# A get route with no handler specified
    get '/*' do |path|
      for_path(CGI.unescape(path))
    end

		# A post route to root, for writing to a file
    post '/' do
      if FileLookup.parent_root(params['fullpath']) == FileLookup.roots.first
        page = Page.for(params['fullpath'])
        page.write(params['content']);
        redirect to(page.path)
      end
    end


    def for_path(path = '')
      page = Page.for(path, :fetch => true)
      pass if page.nil?

      # Call PageApp
      env['scrapple.page'] = page
      env['scrapple.params'] = @params

      response = @app.call(env)
      return response
    end

  end
end
