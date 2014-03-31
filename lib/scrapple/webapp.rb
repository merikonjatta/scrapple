require 'sinatra/base'

class Scrapple

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
      page = Scrapple.content.get(path)
      raise Sinatra::NotFound if page.nil?

      renderer = renderer_for(page)

      # Set rack env so that other middleware plugins can access them
      env['scrapple.page'] = page
      env['scrapple.params'] = params
      env['scrapple.renderer'] = renderer

      return renderer.render(page, params)
    end


    # Choose a suitable renderer for this page and request.
    # @param page [Page]
    # @return [Module]
    def renderer_for(page)
      (
        Scrapple.renderer(params['renderer']) ||
        Scrapple.renderer(page['renderer']) ||
        Scrapple.renderer(Scrapple.config["default_renderers"][page.type]) ||
        Scrapple.renderer(Scrapple.config["fallback_renderer"])
      )
    end

  end
end
