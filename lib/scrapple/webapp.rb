require 'sinatra/base'
require 'pathname'
require 'yaml'
require 'active_support/core_ext'
require 'pry'

module Scrapple

  class Webapp < Sinatra::Base

    configure do
      set :root, File.expand_path("..", File.dirname(__FILE__))
      set :content_dir, File.expand_path(ENV['CONTENT_DIR'])

      # Some fields are array by default
      Settings.array_fields << 'tags'

      # Configure FileLookup
      FileLookup.base_paths << settings.content_dir
    end

    get '/*' do |path|
      page = Page.for(path, settings.content_dir, :fetch => true)

      # See if the last path component was a handler
      if page.nil? && md = path.match(/^(.*)\/([-a-zA-Z_]+)/)
        page = Page.for(md[1], settings.content_dir, :fetch => true)
        params['handler'] = md[2]
      end

      # Not found if still not found
      raise Sinatra::NotFound if page.nil?

      # Call PageApp
      env['scrapple.page'] = page
      env['scrapple.params'] = params
      env['scrapple.content_dir'] = settings.content_dir

      response = @app.call(env)
      return response
    end

  end
end
