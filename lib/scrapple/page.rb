require 'pathname'
require 'cgi'

class Scrapple
  # Represents a single page (or file) in the filesystem.
  class Page
    class WriteFailed < StandardError; end

    # The content bag where this page is from.
    # @return [Object]
    attr_accessor :bag

    # Relative path to this file (from the source root). Includes preceding slash.
    # Looks like "/docs/[Fowler] Mocks aren't stubs.md"
    # @return [String]
    attr_accessor :path

    # The relative path to be used for links. Includes, preceding shash, and is URL encoded.
    # Looks like "/docs/%5BFowler%5D+Mocks+aren%27t+stubs.md"
    # @return [String]
    attr_accessor :link

    # Type of this Page. Looks like "md" "textile" "css", or "directory" if it's a directory.
    # @return [String]
    attr_accessor :type

    # True if this is an directory index file.
    attr_accessor :isindexfile
    alias_method :indexfile?, :isindexfile

    REGEX_INDEXFILE = %r{(^|/)index\..+$}


    # Pass the request filename to get a new Page instance.
    # @param [String] path   Path to the page file or directory.
    # @param [Object] bag    Content bag where this page is supposed to be from.
    # @return [Page, nil] A Page
    def self.for(path, bag)
      instance = self.new do |page|
        page.path = path
        page.bag = bag
      end

      return instance
    end


    # Manually create an instance. Note that {Page.for} is the recommended
    # way of getting new instances.
    def initialize
      @body        = ""
      @rc          = {}
      yield(self) if block_given?
      @fetched     = false
      @path        = Pathname.new("/" + @path.to_s).cleanpath
      @link        = @path.to_s.split("/")[1..-1].map{ |part| CGI.escape(part) }.join("/")
      @isindexfile = !!(@path.to_s =~ REGEX_INDEXFILE)
      @type        = @bag.directory?(@path) ? "directory" : @path.extname[1..-1]
      self['title'] ||= File.basename(@path)
    end

    # Fetch the content body and rc directives.
    def fetch
      unless @fetched
        parser = Parser.new(bag.content(path))
        @body = parser.body
        @rc = @rc.merge(parser.rc)
        @fetched = true
      end
    end

    # The content body of the file this page represents.
    # Does not include the directives section.
    # @return [String]
    def body
      fetch
      @body
    end

    # Local settings for this page. Includes directives found in file,
    # and directives found in rc files in parent directories.
    # Can be used to store arbitrary data about this page.
    # @return [Hash]
    def rc
      fetch
      @rc
    end


    # Get variables from rc
    def [](key)
      rc[key]
    end


    # Set rc value
    def []=(key, value)
      rc[key] = value
    end

    # Get the parent page.
    # This means:
    # For ordinary pages and directories, the containing directory or its index file.
    # For indexfiles, the containing directory of the containing directory, or its index file.
    # Returns nil if there is no appropriate parent.
    # @param options [Hash] See {Page#for}
    def parent(options = {})
      if indexfile?
        @bag.get(@path.dirname.dirname)
      else
        @bag.get(@path.dirname)
      end
    end

    # Get a list of child pages.
    # If self is a Directory, the list of pages in that directory.
    # If self is a Page, the list of sibling pages.
    # @param options [Hash]
    # @option options [Bool] :indexfiles_first      (true) List index.* files first.
    # @option options [Bool] :directories_first     (true) List directories first.
    # @option options [Array, String] :ignore       ([]) Fullpaths to exclude
    def children(options = {})
      has_children? ? @bag.ls(@path) : []
    end

    # True if this is a directory or an indexfile.
    # @return [Bool]
    def has_children?
      @bag.has_children?(path)
    end

    # True if other has the same bag and path
    def same?(other)
      bag == other.bag && path == other.path
    end

  end
end
