class Scrapple
  class FileSystemBag
    
    attr_reader :root

    def self.instance(path)
      self.new(path) if Pathname.new(path).cleanpath.directory?
    end

    def initialize(path)
      @root = Pathname.new(path).cleanpath
    end
    
    # Get a file.
    def get(path)
      Page.for(@root + path, self)
    end

    # Get the text content of a file as string.
    def content(path)
      if directory?(path)
        # TODO: get index file
        "index"
      else
        File.read(root + path)
      end
    end

    # Get the type of a file.
    def type(path)
      get(path).type
    end

    # Get the config hash for a path.
    def rc(path)
      get(path).rc
    end

    # Whether a path is a directory
    def directory?(path)
      (root + path).directory?
    end

    # Whether a path has children or not.
    def has_children?(path)
      type(path) == "directory" || get(path).indexfile?
    end

    # Get the children of a file.
    def ls(path)
      return [] unless has_children?(path)

      base = (type(path) == "directory") ? path : path.dirname

      pages = Dir[base + "/*"].map { |entry| Page.for(entry, self) }.compact

      # Sort indexfiles-first, directories-first, then by name. (A Shwartzian transform)
      # Got idea from http://bit.ly/d4UaMM
      sh = pages.map do |page|
        sortkey = ""
        sortkey << ((page.indexfile?) ? "1/" : "2/" )
        sortkey << ((page.type == "directory") ? "1/" : "2/")
        sortkey << page.path
        [sortkey, page]
      end
      sh.sort{|a,b| a.first <=> b.first }.map { |a| a.last }
    end

  end
end
