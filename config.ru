require File.expand_path('../lib/scrapple', __FILE__)
Scrapple.init
run Scrapple.middleware_stack.to_app
