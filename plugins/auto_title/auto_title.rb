Scrapple::Page.hook(:after_initialize) do |page|
  break if page['title']

  #page['title'] = File.basename(page.fullpath, ".*").split(" ").map {|t| t[0] = t[0].upcase; t }.join(" ")
end
