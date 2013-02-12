module Layout
  class << self

    def use_layout(app)
      layout_file = app.params[:directives]['layout'] || "layout"
      app.body Tilt.new(app.find_file(layout_file)).render(app, :content => app.body.first)
    end

  end
end

Compund::Webapp.hook(:after_render) do |app|
  app.body Layout.use_layout(app)
end
