require 'uri'
require 'pathname'

module Scrapple
  class Page
    # Local settings for this page. Includes directives found in file,
    # and directives found in _settings.txt in parent directories.
    # But can be used to store arbitrary data
    attr_accessor :settings

    # Normally, directives found in _settings.txt files are taken into locals.
    # Set this to false to ignore them.
    attr_accessor :ignore_settings_files

    attr_accessor :path
    attr_accessor :root
    attr_accessor :fullpath

    # The content body of the file this page represents.
    attr_accessor :content

    # Pass the request filename to get a new Page instance.
    # @param [String] path   Absolute or relative path to the page file or directory
    # @param [String] root   Absolute root path, determines lookup scope for parent pages and settings files
    # @param [Hash] options  Options for the instance
    # @option options [Boolean] :fetch (false)                 Whether to do a fetch after initialize
    # @option options [Boolean] :ignore_settings_files (false) Whether to ignore surrounding _settings.txt files
    #
    # @return [Page, nil] A Page if file is found, nil if not
    def self.for(path, root, options = {})
      options = {
        :fetch => false,
        :ignore_settings_files => false
      }.merge(options)

      path_pn = Pathname.new(path)
      root = File.expand_path(root)

      if path_pn.absolute?
        fullpath = FileFinder.find_absolute(path)
        path = path_pn.relative_path_from(Pathname.new(root)).to_s
      else
        fullpath = FileFinder.find(path, root)
      end

      return nil if fullpath.nil?

      instance = self.new do |page|
        page.path = path
        page.root = root
        page.fullpath = fullpath
        page.ignore_settings_files = options[:ignore_settings_files]
      end

      instance.fetch if options[:fetch]

      return instance
    end


    def initialize
      @settings = Settings.new
      yield(self) if block_given?
    end
    
    # Fetch content body and settings from this and its surrounding files.
    # @return [Page] self, for chainability
    def fetch
      unless @ignore_settings_files
        settings_files = FileFinder.find_in_ancestors("_settings", fullpath, root)
        settings_files.reverse_each do |settings_file|
          @settings.parse_and_merge_file(settings_file)
        end
      end

      @content = @settings.parse_and_merge(File.read(fullpath))

      return self
    end


    # Get variables from settings
    def [](key)
      @settings[key]
    end

  end
end
