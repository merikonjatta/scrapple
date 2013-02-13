Scrapple::Page.hook(:before_render) do |page|
  if page['title'].blank?
    page.settings['title'] = File.basename(page.file, ".*").split(/\s+/).map{|t| t[0] = t[0].upcase; t }.join(" ")
  end
end
