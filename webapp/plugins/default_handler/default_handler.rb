class DefaultHandler < Compound::Handler

	def initialize
		@template_dir = File.join(File.dirname(__FILE__), "views")
	end

	def view(path, app)
		render_default_view(app, File.open(path){ |f| f.read})
	end

	def edit(path, app)
		"Editing:\n" + File.open(path){ |f| f.read }
	end

	def write(path, app)
		"Wrote #{path} with:\n\n#{app.params[:content]}"
	end


	protected
	def render_default_view(app, text)
		app.erb(:view,
						:locals => {:text => text},
						:views => @template_dir)
	end

end
