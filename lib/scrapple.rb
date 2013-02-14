Bundler.require(:default, :development)

module Scrapple
  class HandlerNotFound < Exception; end
  class FileNotFound < Exception; end
end

SCRAPPLE_ROOT = File.expand_path('../../', __FILE__)

# If no content dir was specified, just run with sample content
ENV['CONTENT_DIR'] ||= File.join(SCRAPPLE_ROOT, "sample_content")

%W(
  file_lookup
  settings
  page
  webapp
  page_app
  middleware_stack
).each { |lib| require File.join(SCRAPPLE_ROOT, "lib/scrapple/#{lib}") }


# TODO Don't hardcode this here
SCRAPPLE_PLUGINS_ROOT = File.join(SCRAPPLE_ROOT, "plugins")

# Require all <plugin>.rb scripts in plugins dir
Dir[SCRAPPLE_PLUGINS_ROOT + "/*"].each do |plugin_dir|
  plugin_name = plugin_dir.match(/.*\/(.*)$/)[1]
  require File.join(plugin_dir, plugin_name)
end
