module Scrapple
  class FileFinder

    class << self
      # Find a file by relative path to a root path
      def find(path, root)
        file = File.join(root, path)
        
        # If the path is a directory, try to find a index file
        if File.directory?(file)
          if index_file = Dir[File.join(file, "index.*")].first
            file = index_file
          end
        end

        # Still not a valid file, so try to add some extensions
        unless File.file?(file)
          if file_with_extension = Dir[File.join(root, "#{path}.*")].first
            file = file_with_extension
          end
        end

        # Still not a valid file, so give up
        raise FileNotFound, "File not found: #{file} for #{path}" unless File.file?(file)

        return file
      end


      # Find all files in leaf's parent directories, stopping at root.
      # Returns all files, in order of nearest to leaf -> farthest from leaf.
      def find_in_ancestors(path, leaf, root)
        leaf = File.expand_path(leaf)
        leaf = File.dirname(leaf) if File.file?(leaf)
        root = File.expand_path(root)
        raise ArgumentError, "leaf must be a descendant of root" unless leaf[0, root.length] == root
        found = []
        found << find(path, leaf)
        if leaf != root
          found = found + find_in_ancestors(path, File.dirname(leaf), root)
        end
        found
      end

    end
  end
end
