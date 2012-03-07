require 'maruku'
Compound::Base.load_handler("default")

class MarkdownHandler < DefaultHandler

	def view(path, app)
		render_default_view(app, app.markdown(File.open(path){ |f| f.read }))
	end

end
