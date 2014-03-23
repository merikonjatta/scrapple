require 'pathname'

module Scrapple
  # Utility class that finds files for you.
  class FileLookup

    # The base paths that FileLookup will search in by default.
    # This is meant to be mutated.
    # @return [Array]
    attr_reader :roots

    def initialize
      @roots = []
    end

    # Find a file within any of the roots. Return the first one found.
    #
    # @param file [String]   Relative or full filename/path of what you want.
    # @return [String, nil]  Full path of the file found first.
    def find(file)
      found = nil

      if rewt = parent_root(file)
        file = relative_path(file, rewt)
        rewts = [rewt]
      else
        rewts = roots
      end

      rewts.each do |root|
        break if found = find_in_root(file, root); 
      end

      return found
    end


    # Find a file within one root.
    #
    # @param file [String]   Relative filename/path of what you want.
    # @return [String, nil]  Full path of the file found, or nil if not found
    def find_in_root(file, root)
      found = nil

      if descendant?(file, root)
        file = relative_path(file, root)
      end

      try = File.join(root, file)
      found = try if File.file?(try)

      if found.nil?
        file_with_ext_glob = file + ".*"
        try = Dir[File.join(root, file_with_ext_glob)].first
        found = try if try && File.file?(try)
      end

      if found.nil?
        try_dir = File.join(root, file)
        if File.directory?(try_dir)
          try = Dir[File.join(try_dir, "index.*")].first
          found = try if try && File.file?(try)
        end
      end

      if found.nil?
        try_dir = File.join(root, file)
        if File.directory?(try_dir)
          found = try_dir
        end
      end

      return found ? Pathname.new(found).cleanpath.to_s : found
    end


    # Find a file, starting next to "near", and going up.
    # Search will continue until it hits one of the {.root}s.
    # Return the first file found.
    #
    # @param file    [String]  Relative filename/path of what you want.
    # @param near    [String]  Absolute path of directory to starting looking in, or file to start looking next to.
    #
    # @return [String]                  Full path of first file found
    # @raise  [ArgumentError]           When near is not a descendant of any of the {.roots}
    # @raise  [ArgumentError]           When near doesn't exist
    def find_first_ascending(file, near)
      find_all_ascending(file, near).first
    end


    # Find matching files, starting next to "near", and going up.
    # Search will continue until it hits one of the of the {.roots}.
    # Return all that are found.
    # @param file    [String]  Relative filename/path of what you want.
    # @param near    [String]  Absolute path of directory to starting looking in, or file to start looking next to.
    #
    # @return [Array<String>]           Full paths of all file found
    # @raise  [ArgumentError]           When near is not a descendant of any of the {.roots}
    # @raise  [ArgumentError]           When near doesn't exist
    def find_all_ascending(file, near)
      found = []
      root = parent_root(near)

      raise ArgumentError, "#{near} is not a descendant of any of the base paths" if root.nil?
      raise ArgumentError, "#{near} does not exist" unless File.exist?(near)

      look_in = File.file?(near) ? File.dirname(near) : near

      found << find_in_root(file, look_in)

      if relative_path(look_in, root) != "."
        look_in = File.dirname(look_in)
        found += find_all_ascending(file, look_in)
      end

      return found.compact
    end


    # Calculates the relative path from `path` to `root`.
    # Returns nil if it can't be calculated.
    # @param path [String] Absolute path
    # @param root [String] Absolute path
    def relative_path(path, root)
      Pathname.new(path).relative_path_from(Pathname.new(root)).to_s
    rescue ArgumentError
      return nil
    end



    # Check if a path is an absolute path.
    # Same as {parent_root}, except this one returns a Bool.
    # So if given something like "/etc/init.d" and /etc nor /etc/init.d is in the {.roots},
    # then that's a relative path AFAIC (returns false).
    # @param path [String]
    # @return [Bool]
    def absolute?(path)
      roots.any? { |root| descendant?(path, root) }
    end


    # Check if an absolute path is a descendant any of the {.roots}.  In
    # other words, if the path starts with one of the {.roots}.  If it is,
    # returns that base path.  If not, returns nil.
    # @param path [String]
    # @return [String]
    def parent_root(fullpath)
      return roots.find { |root| descendant?(fullpath, root) }
    end


    # Check if one absolute `path` looks like it's a descendant of `root`.
    # Note that this doesn't actually look for the file, it only compares path strings.
    # @param path [String]
    # @param root [String]
    # @return [Bool]
    def descendant?(path, root)
      relative = relative_path(path, root)
      return false if relative.nil?
      relative !~ /\.\./
    end

  end
end
