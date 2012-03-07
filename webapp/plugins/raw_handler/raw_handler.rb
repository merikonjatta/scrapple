class RawHandler

	def view(path, request)
		result = {}
		result[:body] = File.open(path) { |f| f.read }
		result[:headers] = {"Content-Type" => "text/plain"}
		result
	end

	def edit(path, request)
		result = {}
		result[:body] = "Editing:\n" + File.open(path) { |f| f.read }
		result[:headers] = {"Content-Type" => "text/plain"}
		result
	end

end
