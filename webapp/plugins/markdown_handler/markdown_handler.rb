module Compund::Handlers::MarkdownHandler 

  def view(path)
    @text = markdown(File.open(path){ |f| f.read })
    @title = path
    erb(local_view(__FILE__, "view"))
  end

end
