# Do I need this?
#$: << File.expand_path('../lib', __FILE__)

require File.expand_path('../lib/scrapple', __FILE__)

run Scrapple.middleware_stack.to_app
