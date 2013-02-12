module DefaultHandler
  class << self

    def view(request)
      Tilt.new(request[:path]).render
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
