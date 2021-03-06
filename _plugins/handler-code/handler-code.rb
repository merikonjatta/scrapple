module Scrapple::Plugins
  module HandlerCode
    # List taken mostly from Ack
    EXTENSIONS = %w(txt as mxml ada adb ads asm s bat cmd c h xs cfc cfm cfml clj cpp cc cxx m hpp hh h hxx
      cs pas int dfm nfm dof dpk dproj groupproj bdsgroup bdsproj el erl hrl f f77 f90 f95 f03 for ftn fpp
      go groovy gtmpl gpp grunit haml hs lhs h java properties 
      jsp jspx jhtm jhtml lisp lsp lua mk mak md markdown mas mhtml mpl mtxt md markdown
      m h mm h ml mli pir pasm pmc ops pod pg tg pl pm pm6 pod t php phpt php3 php4 php5 phtml
      pt cpt metadata cpy py py rake rb rhtml rjs rxml erb rake spec scss scala
      scm ss scss sh bash csh tcsh ksh zsh st sql ctl tcl itcl itk tex cls sty
      textile tt tt2 ttml bas cls frm ctl vb resx v vh sv vhd vhdl vim xml dtd xsl xslt ent yaml yml
      Gemfile Rakefile Capfile ru json)

    class << self

      def confidence(page)
        if EXTENSIONS.include?(page.type)
          # Not 1000, because some have dedicated handlers
          800
        elsif %w(css js htm html shtml xhtml).include?(page.type)
          # Should give way to raw
          200
        else
          100
        end
      end


      def call(env)
        page = env['scrapple.page']
        page['macros'] = false
        page['file_content'] = Rack::Utils.escape_html(File.read(page.fullpath))

        body = Tilt['haml'].new(File.expand_path("../content/__code.haml", __FILE__)).render(page)

        body = Scrapple::Plugins::Layout.wrap(body, env)

        [200, {"Content-Type" => "text/html"}, [body]]
      end
    end
  end

  Scrapple::Webapp.register_handler(HandlerCode, :name => "code")
end
