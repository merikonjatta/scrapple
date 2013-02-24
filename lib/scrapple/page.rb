require 'pathname'

module Scrapple
  # Represents a single page (or file) in the filesystem.
  class Page
    class WriteRefused < StandardError; end

    include Hookable

    # Local settings for this page. Includes directives found in file,
    # and directives found in perdir files in parent directories.
    # But can be used to store arbitrary data.
    # @return [Settings]
    attr_accessor :settings

    # Set this to true to ignore perdir files surrounding this Page's file.
    # @return [Bool]
    attr_accessor :ignore_perdir_files

    # Relative path to this file (from {#root}). Includes preceding slash.
    # Looks like "/docs/[Fowler] Mocks aren't stubs.md"
    # @return [String]
    attr_accessor :path

    # The relative path to be used for links. Includes, preceding shash, and is URL encoded.
    # Looks like "/docs/%5BFowler%5D+Mocks+aren%27t+stubs.md"
    # @return [String]
    attr_accessor :link

    # Base of the relative {#path}.
    # Looks like "/home/marco/scrapple-site"
    # @return [String]
    attr_accessor :root

    # Full filesystem path of this Page.
    # Looks like "/home/marco/scrapple-site/docs/[Fowler] Mocks aren't stubs.md"
    # @return [String]
    attr_accessor :fullpath

    # Type of this Page. Looks like "md" "textile" "css", or "directory" if it's a directory.
    # @return [String]
    attr_accessor :type

    # True if this is an directory index file.
    attr_accessor :isindexfile
    alias_method :indexfile?, :isindexfile

    # The content body of the file this page represents.
    # Does not include the directives section.
    # @return [String]
    attr_accessor :content

    # Pass the request filename to get a new Page instance.
    # @param [String] path   Absolute or relative path to the page file or directory.
    # @param [Hash] options  Options for the instance.
    # @option options [String] :root (nil)          Specify the absolute root path to look in, if known. 
    # @option options [Bool] :fetch (false)         Whether to do a fetch after initialize.
    #                                               Not fetching means no parsing for directives,
    #                                               no looking for perdir files, so leave it as false
    #                                               unless you need the contents.
    # @option options [Bool] :ignore_perdir_files   (false) Whether to ignore surrounding perdir files
    #
    # @return [Page, nil] A Page if file is found, nil if not
    def self.for(path, options = {})
      options = {
        :root => nil,
        :fetch => false,
        :ignore_perdir_files => false,
        :look_for_index => true
      }.merge(options)

      if options[:root] && FileLookup.roots.include?(options[:root])
        fullpath = FileLookup.find_in_root(path, options[:root])
      else
        fullpath = FileLookup.find(path)
      end

      return nil if fullpath.nil?

      instance = self.new do |page|
        page.fullpath    = fullpath
        page.ignore_perdir_files = options[:ignore_perdir_files]
      end

      instance.fetch if options[:fetch]

      return instance
    end


    # Manually create an instance. Note that {Page.for} is the recommended
    # way of getting new instances.
    def initialize
      @settings = Settings.new
      yield(self) if block_given?

      if fullpath
        @root        = FileLookup.parent_root(fullpath)
        @path        = "/" + FileLookup.relative_path(fullpath, @root)
        @link        = "/" + @path.split("/")[1..-1].map{ |part| CGI.escape(part) }.join("/")
        @isindexfile = !!(fullpath =~ /(^|\/)index\..+$/)
        @type        = if File.directory?(fullpath)
                         "directory"
                       else
                         File.extname(fullpath)[1..-1] || File.basename(fullpath)
                       end
        self['title'] ||= File.basename(fullpath)
      end

      call_hooks(:after_initialize)
    end


    # Fetch content body and settings from this and its surrounding files.
    # @return [Page] self, for chainability
    def fetch
      unless @ignore_perdir_files
        files = FileLookup.find_all_ascending(Scrapple.perdir_file, fullpath)
        files.reverse_each do |file|
          # TODO: Does this have to be parse and merge? A simple yaml load file would do
          @settings.parse_and_merge!(file, :dont_stop => true)
        end
      end

      @content = @settings.parse_and_merge!(fullpath) unless type == "directory"

      return self
    end

    # Write given contents to file. Raises a WriteRefused if the file is
    # not under the first entry in {FileLookp.roots}.
    # @param content [String] The stuff to write.
    # @raise [WriteRefused]  When the file is outside the first entry in {FileLookp.roots}
    def write(content)
      if self.root != FileLookup.roots.first
        raise WriteRefused.new("Refusing to write #{fullpath} outside of #{FileLookup.roots.first}")
      end
      File.open(fullpath, 'w') { |f| f.write(content) }
    end


    # Get variables from settings
    def [](key)
      @settings[key]
    end


    # Set settings value
    def []=(key, value)
      @settings[key] = value
    end


    # Get a list of child pages.
    # @param options [Hash]
    # @option options [Bool] :directories_first     (true) List directories first.
    # @option options [Bool] :ignore_perdir_files   (true) Do not include perdir files
    # @option options [Array, String] :ignore       ([]) Fullpaths to exclude
    def children(options = {})
      return [] unless has_children?

      options = {
        :directories_first => true,
        :ignore_perdir_files => true,
        :ignore => []
      }.merge!(options)

      options[:ignore] = [options[:ignore]] unless options[:ignore].is_a? Array
      options[:ignore].map! { |ig| ig.is_a?(Page) ? ig : Page.for(ig) }

      base = (type == "directory") ? fullpath : File.dirname(fullpath)

      pages = Dir[base + "/*"].reject { |entry|
        entry =~ /\/index\..+$/ ||
          options[:ignore].include?(entry) ||
          options[:ignore_perdir_files] && entry =~ /\/#{Regexp.escape(Scrapple.perdir_file)}$/
      }.map { |entry| Page.for(entry, :fetch => true, :ignore_perdir_files => true) }.compact

      if options[:directories_first]
        # Sort directories-first, then by name. (A Shwartzian transform)
        # Got idea from bit.ly/d4UaMM
        sh = pages.map do |page|
          sortkey = ""
          sortkey << ((page.type == "directory" || page.indexfile?) ? "0/" : "1/")
          sortkey << page.fullpath
          [sortkey, page]
        end
        sh.sort{|a,b| a.first <=> b.first }.map { |schw| schw[1] }
      else
        pages.sort
      end
    end

    # True if this is a directory or an indexfile.
    # @return [Bool]
    def has_children?
      type == "directory" || indexfile?
    end

  end
end
