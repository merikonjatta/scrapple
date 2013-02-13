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
