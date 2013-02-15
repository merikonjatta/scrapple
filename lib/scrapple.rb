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

# Require all <plugins_root>/<plugin>/<plugin>.rb scripts in plugins dir
Dir[SCRAPPLE_PLUGINS_ROOT + "/*"].each do |plugin_dir|
  plugin_name = plugin_dir.match(/.*\/(.*)$/)[1]
  require File.join(plugin_dir, plugin_name)
end

# Add all <plugins_root>/<plugin>/content directories to FileLookup.base_paths
Dir[SCRAPPLE_PLUGINS_ROOT + "/*/content"].each do |plugin_content_dir|
  Scrapple::FileLookup.base_paths << plugin_content_dir if File.directory?(plugin_content_dir)
end

# Define some directive aliases up front
Scrapple.alias_directive("as", "handler")
Scrapple.alias_directive("with", "handler")
