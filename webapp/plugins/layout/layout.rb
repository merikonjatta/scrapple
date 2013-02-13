# Insert before scrapple
class Layout

  class GiveUp < Exception; end

  def initialize(app=nil)
    @app = app
  end


  def call(env)
    status, headers, body = @app.call(env)

    page = env['scrapple.page']
    params = env['scrapple.params']

    # Only for text/html
    raise GiveUp if headers['content-type'] !~ %r{text/html}
    # Layout is not specified?
    raise GiveUp if page['layout'].nil?

    layout_file = Scrapple::FileFinder.find_nearest_in_ancestors(page['layout'], page.fullpath, page.root)

    # Layout file not found?
    raise GiveUp if layout_file.nil?
    # Layout file is the same as the file to be wrapped?
    raise GiveUp if page.fullpath == layout_file
    
    ext = layout_file.sub(/^.*\./, '')
    engine = Tilt[ext]

    # Tilt doesn't know how?
    raise GiveUp if engine.nil?

    new_body = engine.new(layout_file).render(page) { body.join }

    return [status, headers, [new_body]]
  rescue GiveUp
    return [status, headers, body]
  end

  
  def wrap_in_layout(page, body)

  end
end

Scrapple.insert_middleware_before(Scrapple::PageApp, Layout)
