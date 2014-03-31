class Scrapple
  # Represents a repository of content.
  # Holds multiple bags (or sources of content), each of which must respond to
  #   * get
  #   * get_all
  #   * rc
  class Content

    def initialize
      @bags = []
    end

    # Add a bag.
    # Initializes a FileSystemSource if argument is a String or a Pathname.
    # 
    # @param source [String, Pathname, FileSystemSource, Object]
    def <<(bag)
      bag = FileSystemBag.new(bag) if (bag.is_a?(String)|| bag.is_a?(Pathname))
      @bags << bag
    end

    # Get a file within the bags.
    # Returns the first match.
    #
    # @param path [String, Pathname] Relative path (or pseudo-full path) of what you want.
    # @return [Page]
    def get(path)
      @bags.lazy.map { |so| so.get(path) }.find { |pa| pa }
    end

    # Get all matching files within the bags.
    #
    # @param path [String, Pathname] Relative path (or pseudo-full path) of what you want.
    # @return [Array<Page>]
    def get_all(path)
      @bags.map { |so| so.get(path) }.compact
    end
  end
end
