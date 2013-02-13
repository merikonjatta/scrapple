module Scrapple
  class HandlerNotFound < Exception; end
  class FileNotFound < Exception; end
end

Bundler.require(:default, :development)

SCRAPPLE_ROOT = File.expand_path('../../', __FILE__)

Dir[SCRAPPLE_ROOT + "/core/*.rb"].each do |core_lib|
  require core_lib
end

module Scrapple
  @middleware_stack = [
    Scrapple::Webapp,
    Scrapple::PageApp
  ]

  def self.middleware_stack
    @middleware_stack
  end

  def self.insert_middleware_after(existing, new)
    index = @middleware_stack.index(existing)
    raise ArgumentError, "#{existing.name} not found in middleware stack" if index.nil?
    @middleware_stack.insert(index+1, new)
  end

  def self.insert_middleware_before(existing, new)
    index = @middleware_stack.index(existing)
    raise ArgumentError, "#{existing.name} not found in middleware stack" if index.nil?
    @middleware_stack.insert(index, new)
  end
end


# Require all <plugin>.rb scripts in plugins dir
Dir[SCRAPPLE_ROOT + "/plugins/*"].each do |plugin_dir|
  plugin_name = plugin_dir.match(/.*\/(.*)$/)[1]
  require File.join(plugin_dir, plugin_name)
end
