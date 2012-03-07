class MarkdownHandler < Compound::Handler
	require 'maruku'

	action :view do |path, app|
		app.markdown(File.open(path){ |f| f.read })
	end

	action :edit do |path, app|
		app.headers "Content-Type" => "text/plain"
		"Editing:\n" + File.open(path){ |f| f.read }
	end

	action :write do |path, app|
		"Wrote #{path} with:\n\n#{app.params[:content]}"
	end

end
