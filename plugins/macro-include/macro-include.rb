module Scrapple::Plugins
  # Include other pages in your page.
  module Include

    def include(other)
      page = (other.is_a? Scrapple::Page) ? other : Scrapple::Page.for(other, :fetch => true)

      if page.nil?
        "Couldn't find #{other} to include"
      else
        MacroExpander.new(page.content, page['macros']).expand(page)
      end
    end

  end
end

Scrapple::Page.send(:include, Scrapple::Plugins::Include)
