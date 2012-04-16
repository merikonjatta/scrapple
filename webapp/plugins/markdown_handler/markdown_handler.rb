require 'maruku'
Compund::WebApp.load_handler("standard")

module Compund
	module Handlers
		class MarkdownHandler < Compund::Handlers::StandardHandler

			def view(path)
				standard_view(path, markdown(File.open(path){ |f| f.read }))
			end

		end
	end
end
