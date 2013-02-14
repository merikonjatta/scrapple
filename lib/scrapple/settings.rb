require 'active_support/core_ext'

module Scrapple
  class Settings
    attr_reader :hash

    @array_fields = []
    def self.array_fields; @array_fields; end

    # Get a new instance specifying a starting hash of settings
    def initialize(hash = {}, options = {})
      @hash = hash
    end

    def keys
      @hash.keys
    end

    def values
      @hash.values
    end

    def each(&block)
      @hash.each(&block)
    end

    def [](key)
      @hash[key]
    end

    def []=(key, value)
      @hash[key] = value
    end

    # Parse a settings file and merge the results with existing settings.
    # Return the remaining body section of the file as a String.
    def parse_and_merge_file(file)
      parse_and_merge(File.read(file))
    end


    # Parse a settings text and merge the results with existing settings.
    # Return the remaining body section of the text as a String.
    def parse_and_merge(text)
      (body, hash) = parse(text)
      merge(hash)
      return body
    end


    # Merge a parsed hash to the results hash
    def merge(hash)
      hash = Settings.hash if hash.is_a? Settings
      @hash.merge!(hash)
    end


    # Parse a settings text and return the resulting body and directives.
    def parse(text)
      num_noncontent_lines = 0
      directives = {}
      rdirective = /\A(.*?):(.*)\Z/

      text.each_line do |line|
        if md = line.match(rdirective)
          directives[md[1]] = md[2]
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

      directives = normalize(directives)
      body = text.lines.to_a[num_noncontent_lines..-1].join
      return [body, directives]
    end


    # Normalize and type-cast keys and values of a parsed hash
    def normalize(hash)
      result = {}
      hash.each do |key, value|
        key = key.strip.downcase
        value = value.strip
        if self.class.array_fields.include? key
          result[key] = value.split(",").map(&:strip)
        else
          result[key] = value
        end
      end
      result
    end

  end
end