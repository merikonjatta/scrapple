class RawHandler < Compound::Handler

	def view(path)
		headers "Content-Type" => "text/plain"
		File.open(path){ |f| f.read }
	end

	def edit(path)
		headers "Content-Type" => "text/plain"
		"Editing:\n" + File.open(path){ |f| f.read }
	end

	def write(path)
		headers "Content-Type" => "text/plain"
		"Wrote #{path} with:\n\n#{params[:content]}"
	end

end
