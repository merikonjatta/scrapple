require 'maruku'
Compound::WebApp.load_handler("standard")

module Compound
	module Handlers
		class MarkdownHandler < Compound::Handlers::StandardHandler

			def view(path)
				standard_view(path, markdown(File.open(path){ |f| f.read }))
			end

		end
	end
end
