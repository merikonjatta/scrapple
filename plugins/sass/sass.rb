require 'sass/plugin/rack'
Scrapple.middleware_stack.insert_after(Scrapple::Webapp, Sass::Plugin::Rack)

Sass::Plugin.options[:cache_location] = Scrapple.tmp_dir.join(".sass-cache")
