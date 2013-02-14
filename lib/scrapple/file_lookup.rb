module Scrapple
  class FileLookup

    @base_paths = []

    class << self
      # The base paths that FileLookup will search in by default.
      def base_paths; @base_paths; end

      # Find a file within any of the base paths. Return the first one found.
      # @param file    [String] Relative filename/path of what you want.
      # @param options [Hash] Options hash.
      #
      # @option options [Boolean] :raise      (false)       Raise an exception if file not found.
      # @option options [Array]   :base_paths (@base_paths) Supply a list of base paths to look in.
      # 
      # @return [String, nil]             Full path of the file found first.
      # @raise  [Scrapple::FileNotFound]  When :raise option is true and specified file was not found in any of the base paths
      def find(file, options = {})
        options = {
          :raise => false,
          :base_paths => self.base_paths
        }.merge!(options)

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
      # @return [String, nil]             Full path of the file found.
      # @raise  [Scrapple::FileNotFound]  When :raise option is true and specified file was not found in the base path
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


      # Find a file, starting next to "near", and in directories ascending up to one of the {.base_path}s.
      # Return the first file found.
      # @param file    [String]  Relative filename/path of what you want.
      # @param near    [String]  Absolute path of directory to starting looking in, or file to start looking next to.
      # @param options [Hash]    Options hash.
      #
      # @option options [Boolean] :raise (false)            Raise an exception if file not found.
      # @option options [Array]   :base_paths (@base_paths) Supply a list of base paths to stop at.
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


      # Find matching files, starting next to "near", and in directories ascending up to one of the {.base_path}s.
      # Return all that are found.
      # @param file    [String]  Relative filename/path of what you want.
      # @param near    [String]  Absolute path of directory to starting looking in, or file to start looking next to.
      # @param options [Hash]    Options hash.
      #
      # @option options [Boolean] :raise (false)            Raise an exception if file not found.
      # @option options [Array]   :base_paths (@base_paths) Supply a list of base paths to stop at.
      #
      # @return [String]                  Full path of first file found
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

    end
  end
end
