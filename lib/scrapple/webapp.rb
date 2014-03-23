require 'sinatra/base'

module Scrapple

  class Webapp < Sinatra::Base

    # A get route with handler specified
    get %r{(.*)/(as|with|in)/(.+)} do |path, dummy, renderer_name|
      params['handler_name'] = renderer_name
      for_path(CGI.unescape(path))
    end

    # A get route with no handler specified
    get '/*' do |path|
      for_path(CGI.unescape(path))
    end


    def for_path(path = '')
      page = Scrapple::Content.get(path)
      raise Sinatra::NotFound if page.nil?

      renderer = Scrapple.renderer_for(page)

      # Set rack env so that other middleware plugins can access them
      env['scrapple.page'] = page
      env['scrapple.params'] = params
      env['scrapple.renderer'] = renderer

      return renderer.call(env)
    end

  end
end
