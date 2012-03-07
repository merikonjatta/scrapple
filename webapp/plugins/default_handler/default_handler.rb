class DefaultHandler < Compound::Handler

	action :view do |path, app|
		app.erb :view, :locals => {:text => (File.open(path){ |f| f.read })}
	end

	action :edit do |path, app|
		app.body("Editing:\n" + File.open(path){ |f| f.read })
		app.headers({"Content-Type" => "text/plain"})
	end

	action :write do |path, app|
		app.body("Wrote #{path} with:\n\n#{app.params[:content]}")
	end

end
