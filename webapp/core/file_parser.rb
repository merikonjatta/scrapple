module Compund
  class FileParser
    class << self

      def parse_file(file)
        parse(file.read(file))
      end

      def parse(text)
        num_noncontent_lines = 0
        directives = {}
        rdirective = /\A(.*?):(.*)\Z/

        text.each_line do |line|
          if md = line.match(rdirective)
            directives[md[1].strip] = md[2].strip
            num_noncontent_lines += 1
          else
            if line.strip.blank? 
              if directives.count == 0
                num_noncontent_lines += 1 and next
              else
                num_noncontent_lines += 1 and break
              end
            else
              break
            end
          end
        end

        content = text.lines.to_a[num_noncontent_lines..-1].join
        return [content, directives]
      end

    end
  end
end
