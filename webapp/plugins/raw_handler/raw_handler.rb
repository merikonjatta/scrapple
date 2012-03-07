class RawHandler < Compound::Handler

	action :view do |path, app|
		app.headers "Content-Type" => "text/plain"
		File.open(path){ |f| f.read }
	end

	action :edit do |path, app|
		app.headers "Content-Type" => "text/plain"
		"Editing:\n" + File.open(path){ |f| f.read }
	end

	action :write do |path, app|
		app.headers "Content-Type" => "text/plain"
		"Wrote #{path} with:\n\n#{app.params[:content]}"
	end

end
