require 'maruku'
Compund::WebApp.load_handler("standard")

module Compund
	module Handlers
		class MarkdownHandler < Compund::Handlers::StandardHandler

			def view(path)
        @text = markdown(File.open(path){ |f| f.read })
        @title = path
        erb(local_view(__FILE__, "view"))
			end

		end
	end
end
