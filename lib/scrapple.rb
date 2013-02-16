Bundler.require(:default, :development)

module Scrapple
  class HandlerNotFound < Exception; end
  class FileNotFound < Exception; end

  @directive_aliases = {}
  class << self
    attr_reader :directive_aliases

    def alias_directive(allass, to)
      @directive_aliases[allass] = to
    end

    def resolve_directive_alias(allass)
      @directive_aliases[allass] || allass
    end
  end
end

SCRAPPLE_ROOT = File.expand_path('../../', __FILE__)

%W(
  file_lookup
  settings
  hookable
  page
  webapp
  page_app
  middleware_stack
).each { |lib| require File.join(SCRAPPLE_ROOT, "lib/scrapple/#{lib}") }


# If no content dir was specified, just run with sample content
ENV['CONTENT_DIR'] ||= File.join(SCRAPPLE_ROOT, "sample_content")
Scrapple::FileLookup.roots << ENV['CONTENT_DIR']

# If no plugins dir was specified, use the local directory
ENV['PLUGINS_DIR'] ||= File.join(SCRAPPLE_ROOT, "plugins")

# Require all <plugins_root>/<plugin>/<plugin>.rb scripts in plugins dir
Dir[ENV['PLUGINS_DIR'] + "/*"].each do |plugin_dir|
  plugin_name = plugin_dir.match(/.*\/(.*)$/)[1]
  require File.join(plugin_dir, plugin_name)
end

# Add all <plugins_root>/<plugin>/content directories to FileLookup.roots
Dir[ENV['PLUGINS_DIR'] + "/*/content"].each do |plugin_content_dir|
  Scrapple::FileLookup.roots << plugin_content_dir if File.directory?(plugin_content_dir)
end

# Define some directive aliases up front
Scrapple.alias_directive("as",   "handler")
Scrapple.alias_directive("with", "handler")
Scrapple.alias_directive("in",   "handler")
