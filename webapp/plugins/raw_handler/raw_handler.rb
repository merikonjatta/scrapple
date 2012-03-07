class RawHandler < Compound::Handler

	view do |path, request|
		result = {}
		result[:body] = File.open(path) { |f| f.read }
		result[:headers] = {"Content-Type" => "text/plain"}
		result
	end

	edit do |path, request|
		result = {}
		result[:body] = "Editing:\n" + File.open(path) { |f| f.read }
		result[:headers] = {"Content-Type" => "text/plain"}
		result
	end

end
