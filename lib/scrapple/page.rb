require 'uri'
require 'pathname'

module Scrapple
  # Represents a single page (or file) in the filesystem and during a request.
  class Page
    include Hookable

    # Local settings for this page. Includes directives found in file,
    # and directives found in _settings.txt in parent directories.
    # But can be used to store arbitrary data.
    # @return [Settings]
    attr_accessor :settings

    # Set this to false to ignore _settings.txt files surrounding this Page's file.
    # @return [Bool]
    attr_accessor :ignore_settings_files

    # Canonical relative path that can be used to request this Page.
    # @return [String]
    attr_accessor :path

    # Base of the relative {#path}.
    # @return [String]
    attr_accessor :root

    # Full filesystem path of this Page.
    # @return [String]
    attr_accessor :fullpath

    # Type of this Page. The extension, or "directory"
    attr_accessor :type

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
    #                                               no looking for _settings.txt, so leave it as false
    #                                               unless you need the contents.
    # @option options [Bool] :ignore_settings_files (false) Whether to ignore surrounding _settings.txt files
    #
    # @return [Page, nil] A Page if file is found, nil if not
    def self.for(path, options = {})
      options = {
        :root => nil,
        :fetch => false,
        :ignore_settings_files => false
      }.merge(options)

      if options[:root]
        fullpath = FileLookup.find_in_root(path, options[:root])
      else
        fullpath = FileLookup.find(path)
      end

      return nil if fullpath.nil?

      root = FileLookup.parent_root(fullpath)
      path = "/" + FileLookup.relative_path(fullpath, root)
      type = File.directory?(fullpath) ? "directory" : File.extname(fullpath)[1..-1]

      instance = self.new do |page|
        page.path = path
        page.root = root
        page.fullpath = fullpath
        page.type = type
        page.ignore_settings_files = options[:ignore_settings_files]
      end

      instance.fetch if options[:fetch]

      return instance
    end

    # Manually create an instance. Note that {Page.for} is the recommended
    # way of getting new instances.
    def initialize
      @settings = Settings.new
      yield(self) if block_given?

      call_hooks(:after_initialize)
    end
    

    # Fetch content body and settings from this and its surrounding files.
    # @return [Page] self, for chainability
    def fetch
      unless @ignore_settings_files
        settings_files = FileLookup.find_all_ascending("_settings", fullpath)
        settings_files.reverse_each do |settings_file|
          @settings.parse_and_merge(settings_file, :dont_stop => true)
        end
      end

      @content = @settings.parse_and_merge(fullpath) unless self.type == "directory"

      return self
    end


    # Get variables from settings
    def [](key)
      @settings[key]
    end

    # Set settings value
    def []=(key, value)
      @settings[key] = value
    end

  end
end
