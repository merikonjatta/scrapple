require 'sass/plugin/rack'
Scrapple.middleware_stack.insert_after(Scrapple::Webapp, Sass::Plugin::Rack)

Sass::Plugin.options[:cache_location] = File.expand_path("../.sass-cache", __FILE__)
