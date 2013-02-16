require 'sinatra/base'
require 'pathname'
require 'syck'
require 'yaml'
require 'active_support/core_ext'
require 'pry'

module Scrapple

  class Webapp < Sinatra::Base

    get %r{(.*)/(as|with|in)/(.+)} do |path, dummy, handler|
      params['path'] = path
      params['handler'] = handler
      for_path(path)
    end


    get '/*' do |path|
      for_path(CGI.unescape(path))
    end

    post '/' do
      if FileLookup.parent_root(params['fullpath']) == FileLookup.roots.first
        page = Page.for(params['fullpath'])
        page.write(params['content']);
        redirect to(page.path)
      end
    end


    def for_path(path = '')
      page = Page.for(path, :fetch => true)
      raise Sinatra::NotFound if page.nil?

      @params = normalize(@params)

      # Call PageApp
      env['scrapple.page'] = page
      env['scrapple.params'] = @params

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
