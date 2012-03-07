class RawHandler < Compound::Handler

	action :view do |path, app|
		app.body(File.open(path){ |f| f.read })
		app.headers({"Content-Type" => "text/plain"})
	end

	action :edit do |path, app|
		app.body("Editing:\n" + File.open(path){ |f| f.read })
		app.headers({"Content-Type" => "text/plain"})
	end

end
