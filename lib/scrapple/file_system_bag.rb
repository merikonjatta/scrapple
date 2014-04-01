class Scrapple
  class FileSystemBag
    
    attr_reader :root

    REGEX_INDEXFILE = %r{(^|/)index\..+$}

    def self.instance(root_path)
      raise Bag::PathNotFound.new unless Pathname.new(root_path).cleanpath.directory?
      self.new(root_path)
    end


    def initialize(root_path)
      @root = Pathname.new(root_path).cleanpath
    end


    # Does that path exist?
    def exist?(path)
      path = rewrite(path)
      (@root + path).exist?
    end
    

    # Get a file as a Page.
    def get(path, do_raise: true)
      path = rewrite(path)
      if exist?(path)
        Page.for(path, self)
      elsif do_raise
        raise Bag::PathNotFound.new
      else
        nil
      end
    end


    # Get the text content of a file as string.
    def content(path)
      path = rewrite(path)
      raise Bag::PathNotFound.new unless exist?(path)
      if directory?(path)
        ""
      else
        File.read(@root + path)
      end
    end


    # Get the type of a file.
    def type(path)
      path = rewrite(path)
      directory?(path) ? "directory" : path.extname[1..-1]
    end


    # Whether a path is an indexfile
    def indexfile?(path)
      path = rewrite(path)
      path.to_s =~ REGEX_INDEXFILE
    end


    # Whether a path is a directory
    def directory?(path)
      path = rewrite(path)
      (@root + path).directory?
    end


    # Whether a path has children or not.
    def has_children?(path)
      path = rewrite(path)
      directory?(path) || indexfile?(path)
    end


    # Get the paths of the children of a path
    def ls(path)
      path = rewrite(path)
      return [] unless has_children?(path)

      base = directory?(path) ? path : path.dirname
      paths = Pathname.glob((@root + base) + "/*")

      # Sort indexfiles-first, directories-first, then by name. (A Shwartzian transform)
      # Got idea from http://bit.ly/d4UaMM
      sh = paths.map do |pa|
        sortkey = ""
        sortkey << indexfile?(pa) ? "1/" : "2/"
        sortkey << directory?(pa) ? "1/" : "2/"
        sortkey << pa
        [sortkey, pa]
      end
      sh.sort{|a,b| a.first <=> b.first }.map { |a| a.last.relative_path_from(@root) }
    end

    
    # Get the parent path
    def parent(path)
      path = rewrite(path)
      if indexfile?(path)
        path.dirname.dirname
      else
        path.dirname
      end
    end


    # The list of rc files for a page
    def rc_files(path)
      path = rewrite(path)
      rcs = []
      Pathname.new("/"+path.to_s).ascend { |pa| rcs << (pa + Scrapple.config['rc_file']) }
      rcs.map { |rc| relative(rc) }.select { |rc| exist?(rc) }
    end


    private
    # Rewrite the path to find a matching file.
    # /dir => /dir/index.*
    # /file => /file.*
    def rewrite(path)
      rel = relative(path)

      if (@root + rel).directory?
        indexfile = Pathname.glob(@root + (rel.to_s + "/index.*")).first
        return indexfile.relative_path_from(@root) if indexfile
      end

      ext_appended = Pathname.glob(@root + (rel.to_s + ".*")).first
      return ext_appended.relative_path_from(@root) if ext_appended

      return rel
    end


    # Remove preceding slash if exsists.
    def relative(path)
      if path.relative?
        path
      else
        path.relative_path_from(Pathname.new("/"))
      end
    end

  end
end
