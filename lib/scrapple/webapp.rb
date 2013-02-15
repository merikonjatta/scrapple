require 'sinatra/base'
require 'pathname'
require 'syck'
require 'yaml'
require 'active_support/core_ext'
require 'pry'

module Scrapple

  class Webapp < Sinatra::Base

    configure do
      set :root, File.expand_path("..", File.dirname(__FILE__))
      set :content_dir, File.expand_path(ENV['CONTENT_DIR'])

      # Configure FileLookup
      FileLookup.base_paths << settings.content_dir
    end


    get '/*' do |path|
      page = Page.for(path, :fetch => true)

      # See if the last path component was a handler
      if page.nil? && md = path.match(/^(.*)\/([-a-zA-Z_]+)/)
        page = Page.for(md[1], :fetch => true)
        @params['handler'] = md[2]
      end

      # Not found if still not found
      raise Sinatra::NotFound if page.nil?

      @params = normalize(@params)

      # Call PageApp
      env['scrapple.page'] = page
      env['scrapple.params'] = @params
      env['scrapple.content_dir'] = settings.content_dir

      response = @app.call(env)
      return response
    end


    def normalize(hash)
      result = {}
      hash.each do |key, value|
        key = Scrapple.resolve_directive_alias(key)
        result[key] = value
      end
      result
    end

  end
end
