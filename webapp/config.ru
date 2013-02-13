require File.expand_path('../core/scrapple', __FILE__)

Scrapple.middleware_stack[0..-2].each do |middleware|
  use middleware
end
run Scrapple.middleware_stack.last
