require 'active_support/core_ext'

module Scrapple
  class Settings

    @array_fields = []
    def self.array_fields; @array_fields; end

    def self.directive_regexp; /^(.*?):(.*)$/; end

    # Get a new instance specifying a starting hash of settings.
    # @param hash [Hash, Settings]
    def initialize(hash = {})
      hash = hash.to_hash if hash.is_a? Settings
      @hash = hash
    end

    # Return the underlying hash. Not a copy, the hash itself.
    # If you mutate this, the Settings will reflect the changes.
    def hash;            @hash;              end

    # Some hash-like access methods
    def keys;            @hash.keys;         end
    def values;          @hash.values;       end
    def each(&block);    @hash.each(&block); end
    def [](key);         @hash[key];         end
    def []=(key, value); @hash[key] = value; end


    # Parse a settings file and merge the results with existing settings.
    # Return the remaining body section of the file as a String, unless
    # :dont_stop is true, in which case the whole file is treated as a set of
    # directives, and the body will be an empty string.
    # @param io [IO]        The file to parse. If a string is given, it is treated 
    #                       as a filename. If you want to parse the string itself,
    #                       you need to create and pass a StringIO.
    # @param options [Hash] Options hash. See {#parse}.
    def parse_and_merge(io, options = {})
      (body, hash) = parse(io, options)
      merge(hash)
      body
    end


    # Merge a parsed hash to the results hash.
    # @param hash [Hash, Settings]
    def merge(hash)
      hash = hash.hash if hash.is_a? Settings
      @hash.merge!(hash)
    end


    # Parse a settings file (or any other IO-ish) and return the resulting
    # body and directives hash. Directives are to be written at the top of
    # a file, unless :dont_stop is true, in which case the whole file is treated
    # as a set of directives, and the body will be an empty string.
    #
    # * One directive per line.
    # * A directive is in the form of ``key: value''.
    # * Keys and values are normalized (see {#normalize}).
    # * The first empty line after a set of directives marks the end of directives,
    #   and the rest is returned as file body.
    # * Any line that doesn't look like a directive finishes directive parsing,
    #   and the rest, including that line, is returned as file body.
    #
    # The IO is closed at the end.
    #
    # @param io [IO]         The file to parse. If a string is given, it is treated 
    #                        as a filename. If you want to parse the string itself,
    # @param options [Hash]  Options hash.
    # @option options [Bool] :dont_stop  (false) Treat the whole file as a set of directives,
    #                                    and just skip unappropriate lines instead of
    #                                    returning the rest as the body.
    def parse(io, options = {})
      options = {
        :dont_stop => false
      }.merge!(options)

      io = File.open(io) if io.is_a? String

      io.rewind
      directives = {}
      body = ""

      io.each_line do |line|
        if ma = line.match(self.class.directive_regexp)
          directives[ma[1]] = ma[2]
          next
        end

        next if options[:dont_stop]

        if line.strip.blank?
          (directives.count > 0) ? break : next
        else
          body << line
          break
        end
      end

      directives = normalize(directives)
      body << io.read
      io.close rescue NoMethodError
      return [body, directives]
    end


    # Normalize and type-cast keys and values of a parsed hash.
    # Returns a normalized copy.
    # * Whitespace is stripped from both ends of the keys and values.
    # * Keys are downcased.
    # * Values for keys specified as array keys are converted to arrays.
    def normalize(hash)
      result = {}

      hash.each do |key, value|
        key = key.strip.downcase
        value = value.strip

        if self.class.array_fields.include? key
          result[key] = value.split(",").map(&:strip).compact
        else
          result[key] = value
        end
      end

      result
    end

  end
end
