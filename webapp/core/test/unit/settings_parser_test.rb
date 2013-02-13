require File.expand_path("../../test_helper", __FILE__)

require "core/settings_parser.rb"

describe Scrapple::SettingsParser do
  describe "parse" do
    it "should parse a string and return the content body and settings hash" do
      text = %Q{
        layout: mobile
        category: notes
        future: bright

        Content starts here.
      }

      sp = Scrapple::SettingsParser.new
      (body, hash) = sp.parse(text)

      expected_hash = {"layout"=> "mobile", "category" => "notes", "future"=> "bright"}
      expected_body = /\A\s+Content starts here\.\s+\Z/
      hash.must_equal expected_hash
      body.must_match expected_body
    end

    it "should parse keys to lowercase" do
      text = "Foo: bar"
      sp = Scrapple::SettingsParser.new
      (body, hash) = sp.parse(text)

      expected_hash = {"foo" => "bar"}
      hash.must_equal expected_hash
    end


    it "should parse comma-separated values to array if specified as such" do
      text = %Q{
        foo: bar
        tags: tech, ruby
      }

      sp = Scrapple::SettingsParser.new({}, :array_fields => ['tags'])
      (body, hash) = sp.parse(text)

      expected_hash = {"foo" => "bar", "tags" => ["tech", "ruby"]}
      hash.must_equal expected_hash
    end
  end


  describe "parse_and_merge" do
    it "should parse, then merge into result hash" do
      initial = {"layout" => "voodoo", "foo" => "bar"}
      text = %Q{
        foo: BAZ!
        hoge: piyo
      }

      sp = Scrapple::SettingsParser.new(initial)
      sp.parse_and_merge(text)

      expected_hash = {"layout" => "voodoo", "foo" => "BAZ!", "hoge" => "piyo"}
      sp.result.must_equal expected_hash
    end
  end
end
