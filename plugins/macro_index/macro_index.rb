module MacroIndex

  # Produce an HTML list of child pages.
  def index(options = {})
    options = {
      :of => nil,
      :depth => 1,
      :ignore_settings_files => true,
      :ignore_index_files => false,
      :index_files_at_top => true,
    }.merge!(options)

    # Start may be nil, relative, or absolute (against FileLookup.roots), or really absolute.
    # Normalize this to be the fullpath.
    start = options[:of]

    # Let's start with nil. Nil should be coerced into this Page's fullpath.
    start ||= self.fullpath
    
    # A relative path (like "./foo", "foo/bar", "../../") should be joined with
    # this Page's full path.
    if Pathname.new(start).relative?
      start = Pathname.new(File.join(self.fullpath, start)).cleanpath.to_s
    end

    # A virtual absolute path (like "/index.md") should be turned into
    # a real absolute path.
    if Pathname.new(start).absolute? && Scrapple::FileLookup.parent_root(start).nil?
      start = Pathname.new(File.join(self.root, start)).cleanpath.to_s
    end

    # If start is a file, start at its parent dir
    start = File.dirname(start) unless File.directory?(start)

    # Now find its entries...
    entries = []
    Dir.entries(start)[2..-1].each do |entry|
      fullpath = File.join(start, entry)
      entries << {
        :fullpath => fullpath,
        :is_dir => File.directory?(fullpath),
        :page => Scrapple::Page.for(fullpath, :fetch => true, :ignore_settings_files => true),
      }
    end

    if options[:ignore_settings_files]
      entries.reject! { |entry| entry[:fullpath] =~ /\/_settings\..+$/ }
    end

    if options[:ignore_index_files]
      entries.reject! { |entry| entry[:fullpath] =~ /\/index\..+$/ }
    end

    # Sort directories-first, then by name.
    # Got idea from http://stackoverflow.com/questions/3895148/in-ruby-how-do-you-list-sort-files-before-folders-in-a-directory-listing
    entries = entries.map {|en| [(en[:is_dir] ? "0/" : "1/")+en[:fullpath], en] }.sort.map {|schw| schw[1] }

    if options[:index_files_at_top]
    end

    html = "<ul class=\"index\">\n"
    entries.each do |entry|
      html << "<li class=\""
      html << "active " if entry[:fullpath] == self.fullpath
      html << (entry[:is_dir] ? "directory" : "file")
      html << "\"><a href=\""
      html << entry[:page].link
      html << "\">"
      html << (entry[:page]['title'] || File.basename(entry[:fullpath]))
      html << "</a>"
      if entry[:is_dir] && options[:depth] > 1
        recurse_options = options.merge(:of => entry[:fullpath], :depth => options[:depth] -1)
        html << index(recurse_options)
      end
      html << "</li>\n"
    end
    html << "</ul>\n"
    html
  end
end


class Scrapple::Page
  include MacroIndex
end
