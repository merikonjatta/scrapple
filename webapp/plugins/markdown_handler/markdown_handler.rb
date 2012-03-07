require 'maruku'
Compound::Base.load_handler("default")

class MarkdownHandler < DefaultHandler

	def view(path)
		render_default_view(markdown(File.open(path){ |f| f.read }))
	end

end
