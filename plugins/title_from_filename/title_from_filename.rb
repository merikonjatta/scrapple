class TitleFromFilename
  def initialize(app=nil)
    @app = app
  end
  
  def call(env)
    if page['title'].blank?
      page.settings['title'] = File.basename(page.file, ".*").split(/\s+/).map{|t| t[0] = t[0].upcase; t }.join(" ")
    end
  end
end
