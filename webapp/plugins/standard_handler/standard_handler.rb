class Compound::Handlers::StandardHandler < Compound::Handlers::Base

  @@template_dir = File.join(File.dirname(__FILE__), "views")

  def view(path)
    standard_view(path, File.open(path){ |f| f.read})
  end

  def edit(path)
    "Editing:\n" + File.open(path){ |f| f.read }
  end

  def write(path)
    "Wrote #{path} with:\n\n#{params[:content]}"
  end


  protected
  def standard_view(title, text)
    erb(:view,
        :locals => {:title => title, :text => text},
        :views => @@template_dir)
  end

end
