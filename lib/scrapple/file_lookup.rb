require 'pathname'

module Scrapple
  # Utility class that finds files for you.
  class FileLookup

    @base_paths = []

    class << self
      # The base paths that FileLookup will search in by default.
      # This is meant to be mutated.
      # @return [Array]
      def base_paths; @base_paths; end

      # Find a file within any of the base paths. Return the first one found.
      # @param file    [String] Relative or full filename/path of what you want.
      # @param options [Hash] Options hash.
      #
      # @option options [Bool]  :raise      (false) Raise an exception if file not found.
      # @option options [Array] :base_paths (FileLookup.base_paths) Supply a list of base paths
      #                                     to look in.
      # 
      # @return [String, nil]             Full path of the file found first.
      # @raise  [Scrapple::FileNotFound]  When :raise option is true and specified file was
      #                                   not found in any of the base paths
      def find(file, options = {})
        options = {
          :raise => false,
          :base_paths => self.base_paths
        }.merge!(options)

        if absolute?(file)
          base = parent_base_path(file, :base_paths => options[:base_paths])
          file = relative_path(file, base)
          options[:base_paths] = [base]
        end

        found = nil
        options[:base_paths].each do |base_path|
          break if found = find_in_base_path(file, base_path); 
        end

        raise FileNotFound, "Couldn't find \"#{file}\" in any of the base paths" if options[:raise] && found.nil?
        return found
      end


      # Find a file within one base path.
      # @param file    [String] Relative filename/path of what you want.
      # @param options [Hash]   Options hash.
      #
      # @option options [Boolean] :raise (false)  Raise an exception if file not found.
      #
      # @return [String, nil]             Full path of the file found, or nil if not found
      # @raise  [Scrapple::FileNotFound]  When :raise option is true and specified file was
      #                                   not found in the base path
      def find_in_base_path(file, base_path, options = {})
        options = { :raise => false }.merge!(options)

        found = nil
        try = File.join(base_path, file)
        found = try if File.file?(try)

        if found.nil?
          file_with_ext_glob = file + ".*"
          try = Dir[File.join(base_path, file_with_ext_glob)].first
          found = try if try && File.file?(try)
        end

        if found.nil?
          try_dir = File.join(base_path, file)
          if File.directory?(try_dir)
            try = Dir[File.join(try_dir, "index.*")].first
            found = try if try && File.file?(try)
          end
        end

        raise FileNotFound, "Couldn't find \"#{file}\" in #{base_path}" if options[:raise] && found.nil?
        return found
      end


      # Find a file, starting next to "near", and going up.
      # Search will continue until it hits one of the {.base_path}s.
      # Return the first file found.
      # @param file    [String]  Relative filename/path of what you want.
      # @param near    [String]  Absolute path of directory to starting looking in, or file to start looking next to.
      # @param options [Hash]    Options hash.
      #
      # @option options [Bool]  :raise      (false) Raise an exception if file not found.
      # @option options [Array] :base_paths Supply a list of base paths to use instead of {.base_paths}.
      #
      # @return [String]                  Full path of first file found
      # @raise  [Scrapple::FileNotFound]  When :raise option is true and specified file was not found
      # @raise  [ArgumentError]           When near is not a descendant of any of the base paths
      # @raise  [ArgumentError]           When near doesn't exist
      def find_first_ascending(file, near, options = {})
        options = {
          :raise => false,
          :base_paths => self.base_paths
        }.merge!(options)

        found = find_all_ascending(file, near, options.merge(:raise => false))

        raise FileNotFound, "Couldn't find \"#{file}\" anywhere between #{near} and #{base_path}" if options[:raise] && found.empty?
        return found.first
      end


      # Find matching files, starting next to "near", and going up.
      # Search will continue until it hits one of the of the {.base_paths}.
      # Return all that are found.
      # @param file    [String]  Relative filename/path of what you want.
      # @param near    [String]  Absolute path of directory to starting looking in, or file to start looking next to.
      # @param options [Hash]    Options hash.
      #
      # @option options [Bool]   :raise      (false) Raise an exception if file not found.
      # @option options [Array]  :base_paths Supply a list of base paths to use instead of {.base_paths}.
      #
      # @return [Array<String>]           Full paths of all file found
      # @raise  [Scrapple::FileNotFound]  When :raise option is true and specified file was not found
      # @raise  [ArgumentError]           When near is not a descendant of any of the base paths
      # @raise  [ArgumentError]           When near doesn't exist
      def find_all_ascending(file, near, options = {})
        options = {
          :raise => false,
          :base_paths => self.base_paths
        }.merge!(options)

        base_path = options[:base_paths].find { |base| near[0, base.length] == base }
        raise ArgumentError, "#{near} is not a descendant of any of the base paths" if base_path.nil?

        raise ArgumentError, "#{near} does not exist" unless File.exist?(near)

        look_in = File.file?(near) ? File.dirname(near) : near
        found = []
        found << find_in_base_path(file, look_in)

        if look_in != base_path
          look_in = File.dirname(look_in)
          found << find_first_ascending(file, look_in, {:raise => false, :base_paths => [base_path]})
        end

        raise FileNotFound, "Couldn't find \"#{file}\" anywhere between #{near} and #{base_path}" if options[:raise] && found.nil?
        return found.compact
      end


      # Check if a path is an absolute path
      def absolute?(path)
        Pathname.new(path).absolute?
      end


      # Relative path to a base path
      def relative_path(path, base_path)
        return nil unless absolute?(path)
        Pathname.new(path).relative_path_from(Pathname.new(base_path)).to_s
      end


      # Check if an absolute path is within any of the {.base_paths}.
      # If it is, returns that base path.
      # If not, returns nil.
      # @param path [String]
      # @param options [Hash]
      # @option options :base_paths [Array]  Base paths to use instead of {.base_paths}.
      # @return [String]
      def parent_base_path(fullpath, options = {})
        options = {
          :base_paths => self.base_paths
        }.merge!(options)

        return nil unless absolute?(fullpath)

        return options[:base_paths].find { |base| fullpath[0, base.length] == base }
      end

    end
  end
end
