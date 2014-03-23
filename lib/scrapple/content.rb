class Scrapple
  class Content

    def initialize
      @sources = []
    end

    def <<(source)
      source = FileSystemSource.new(source) if (source.is_a?(String)|| source.is_a?(Pathname))
      @sources << source
    end

    # Get a file within the sources.
    # Returns the first match.
    #
    # @param path [String, Pathname] Relative path (or pseudo-full path) of what you want.
    # @return [Page]
    def get(path)
      sources.lazy.map { |so| so.get(path) }.find { |pa| pa }
    end

    # Get all matching files within the sources.
    #
    # @param path [String, Pathname] Relative path (or pseudo-full path) of what you want.
    # @return [Array<Page>]
    def get_all(path)
      sources.map { |so| so.get(path) }.compact
    end
  end
end
