module Compound
	module Handlers
		class StandardHandler < Compound::Handlers::Base

			@@template_dir = File.join(File.dirname(__FILE__), "views")

			def view(path)
				render_standard_view(File.open(path){ |f| f.read})
			end

			def edit(path)
				"Editing:\n" + File.open(path){ |f| f.read }
			end

			def write(path)
				"Wrote #{path} with:\n\n#{params[:content]}"
			end


			protected
			def render_standard_view(text)
				erb(:view,
						:locals => {:text => text},
						:views => @@template_dir)
			end

		end
	end
end
