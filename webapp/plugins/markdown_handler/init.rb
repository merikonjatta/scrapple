require 'maruku'
class MarkdownHandler 

  def view(app)
    content = app.markdown(File.open(app.request[:file_path]){ |f| f.read })
    app.body Compund::Plugins::CommonLayout.use_common_layout(app, {
      :path => app.request[:path],
      :title => app.request[:file_path],
      :content => content,
    })
    app
  end

end

Compund::WebApp.hook(:before_render) do {|app|
}
