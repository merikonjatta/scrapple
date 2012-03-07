class RawHandler < Compound::Handler

	def view(path, app)
		app.headers "Content-Type" => "text/plain"
		File.open(path){ |f| f.read }
	end

	def edit(path, app)
		app.headers "Content-Type" => "text/plain"
		"Editing:\n" + File.open(path){ |f| f.read }
	end

	def write(path, app)
		app.headers "Content-Type" => "text/plain"
		"Wrote #{path} with:\n\n#{app.params[:content]}"
	end

end
