class Scrapple
  # Represents a repository of content.
  # Holds multiple bags (or sources of content), each of which must respond to
  #   * get
  #   * get_all
  #   * rc
  class Content

    attr_reader :bags

    def initialize
      @bags = []
    end

    # Add a bag.
    # Initializes a FileSystemSource if argument is a String or a Pathname.
    # 
    # @param source [String, Pathname, FileSystemSource, Object]
    def <<(bag)
      bag = FileSystemBag.instance(bag) if (bag.is_a?(String)|| bag.is_a?(Pathname))
      @bags << bag
    rescue Bag::PathNotFound
      @bags
    end

    # Get a file within the bags.
    # Returns the first match.
    #
    # @param path [String, Pathname] Relative path (or pseudo-full path) of what you want.
    # @return [Page]
    def get(path)
      path = Pathname.new(path)
      @bags.lazy.map { |bag| bag.get(path, do_raise: false) }.find { |page| page }
    end

    # Get all matching files within the bags.
    #
    # @param path [String, Pathname] Relative path (or pseudo-full path) of what you want.
    # @return [Array<Page>]
    def get_all(path)
      path = Pathname.new(path)
      @bags.map { |bag| bag.get(path, do_raise: false) }.compact
    end
  end
end
