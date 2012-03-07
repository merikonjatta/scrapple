class RawHandler < Compound::Handler

	def view(path)
		headers "Content-Type" => "text/plain"
		File.open(path){ |f| f.read }
	end

end
