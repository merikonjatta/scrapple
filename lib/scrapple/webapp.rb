require 'sinatra/base'
require 'pathname'
require 'syck'
require 'yaml'
require 'active_support/core_ext'
require 'pry'

module Scrapple

  class Webapp < Sinatra::Base

    get %r{(.*)/(as|with)/(.+)} do |path, dummy, handler|
      params['path'] = path
      params['handler'] = handler
      for_path(path)
    end


    get '/*' do |path|
      for_path(path)
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
