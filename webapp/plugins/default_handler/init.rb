module DefaultHandler
  class << self

    # The `view` action 
    def view(file)
      Tilt.new(file).render
    end

    def edit(request)
      "Editing:\n" + File.open(request[:path]){ |f| f.read }
    end

    def write(request)
      "Wrote #{request[:path]} with:\n\n#{params[:content]}"
    end

  end
end

Compund::Webapp.register_handler(DefaultHandler, "default")
