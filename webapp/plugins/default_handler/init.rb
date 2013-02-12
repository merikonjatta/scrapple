module DefaultHandler
  class << self

    # The `view` action 
    def view(app)
      app.body Tilt.new(app.params[:file]).render
    end

    def edit(app)
      "Editing:\n" + File.open(app.params[:file]){ |f| f.read }
    end

    def write(app)
      "Wrote #{app.params[:file]} with:\n\n#{params[:content]}"
    end

  end
end

Compund::Webapp.register_handler(DefaultHandler, "default")
