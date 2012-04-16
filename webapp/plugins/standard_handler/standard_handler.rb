class Compund::Handlers::StandardHandler < Compund::Handlers::Base

  def view(path)
    locals = {:title => path, :text => File.open(path){ |f| f.read }}
    erb(local_view(__FILE__, "view"), :locals => locals)
  end

  def edit(path)
    "Editing:\n" + File.open(path){ |f| f.read }
  end

  def write(path)
    "Wrote #{path} with:\n\n#{params[:content]}"
  end

end
