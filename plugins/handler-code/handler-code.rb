module Scrapple::Plugins
	module HandlerCode
		class << self
			# List taken mostly from Ack
			def confidence(page)
				if %w(txt as mxml ada adb ads asm s bat cmd c h xs cfc cfm cfml clj cpp cc cxx m hpp hh h hxx
				cs pas int dfm nfm dof dpk dproj groupproj bdsgroup bdsproj el erl hrl f f77 f90 f95 f03 for ftn fpp
				go groovy gtmpl gpp grunit haml hs lhs h htm html shtml xhtml java properties 
				jsp jspx jhtm jhtml lisp lsp lua mk mak md markdown mas mhtml mpl mtxt md markdown
				m h mm h ml mli pir pasm pmc ops pod pg tg pl pm pm6 pod t php phpt php3 php4 php5 phtml
				pt cpt metadata cpy py py rake rb rhtml rjs rxml erb rake spec scss scala
				scm ss scss sh bash csh tcsh ksh zsh st sql ctl tcl itcl itk tex cls sty
				textile tt tt2 ttml bas cls frm ctl vb resx v vh sv vhd vhdl vim xml dtd xsl xslt ent yaml yml
				Gemfile Rakefile Capfile ru json).include?(page.type)
					800
				elsif %w(css js).include?(page.type)
					200
				else
					100
				end
			end


			def handle(page)
				page['macros'] = false
				page['file_content'] = Rack::Utils.escape_html(File.read(page.fullpath))
				page['layout'] = false

				body = Tilt['haml'].new(File.expand_path("../content/__code.haml", __FILE__)).render(page)

				[200, {"Content-Type" => "text/html"}, [body]]
			end
		end
	end

	Scrapple::PageApp.register_handler(HandlerCode, :name => "code")
end
