class Scrapple
  class FileSystemSource
    
    attr_reader :root

    def self.instance(path)
      self.new(path) if Pathname.new(path).cleanpath.directory?
    end

    def initialize(path)
      @root = Pathname.new(path).cleanpath
    end
    
    # Get a file.
    def get(path)
      Page.new(@root + path)
    end

  end
end
