module Compound
	module Handlers
		class RawHandler < Compound::Handlers::Base

			def view(path)
				headers "Content-Type" => "text/plain"
				File.open(path){ |f| f.read }
			end

		end
	end
end
