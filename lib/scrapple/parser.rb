class Scrapple
  class Parser

    attr_reader :body, :rc

    REGEX_YAML_LINE = %r{^.+:.+$}
    REGEX_EMPTY_LINE = %r{^\s*$}

    def initialize(str)
      @str = str
      @body = ""
      @rc = {}
    end

    def parse
      yaml = ""
      yaml_done = false
      has_yaml = false

      @str.each_line do |line|
        begin
          if yaml_done
            @body << line
          elsif line =~ REGEX_EMPTY_LINE
            yaml_done = true
          elsif line =~ REGEX_YAML_LINE
            has_yaml = true
            yaml << line
          else
            yaml_done = true
            @body << line
          end
        rescue ArgumentError
          yaml_done = true
          @body << line
        end
      end

      @rc = YAML.load(yaml) if has_yaml

      self
    end
  end
end
