# Do I need this?
#$: << File.expand_path('../lib', __FILE__)

require File.expand_path('../lib/scrapple', __FILE__)

Scrapple.middleware_stack[0..-2].each do |middleware|
  use middleware
end
run Scrapple.middleware_stack.last
