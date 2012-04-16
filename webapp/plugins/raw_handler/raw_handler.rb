module Compund
	module Handlers
		class RawHandler < Compund::Handlers::Base

			def view(path)
				headers "Content-Type" => "text/plain"
				File.open(path){ |f| f.read }
			end

		end
	end
end
