# Needs to be loaded first because other plugins will call
# Sass::Plugin.add_template_location(css_path, css_path)

require 'sass/plugin/rack'
Scrapple.insert_middleware_after(Scrapple::Webapp, Sass::Plugin::Rack)

Sass::Plugin.options[:cache_location] = File.expand_path("../.sass-cache", __FILE__)
