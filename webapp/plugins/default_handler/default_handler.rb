class DefaultHandler < Compound::Handler

	def view(path, app)
		app.erb :view, :locals => {:text => (File.open(path){ |f| f.read })}
	end

	def edit(path, app)
		app.body("Editing:\n" + File.open(path){ |f| f.read })
		app.headers({"Content-Type" => "text/plain"})
	end

	def write(path, app)
		app.body("Wrote #{path} with:\n\n#{app.params[:content]}")
	end

end
