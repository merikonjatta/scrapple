require File.expand_path("../../test_helper", __FILE__)

require "core/settings_parser.rb"

class Scrapple::SettingsParserTest < MiniTest::Unit::TestCase

  context "parse" do
    should "parse a string and return the content body and settings hash" do
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
      assert_equal expected_hash, hash
      assert_match expected_body, body
    end

    should "parse keys to lowercase" do
      text = "Foo: bar"
      sp = Scrapple::SettingsParser.new
      (body, hash) = sp.parse(text)

      expected_hash = {"foo" => "bar"}
      assert_equal expected_hash, hash
    end


    should "parse comma-separated values to array if specified as such" do
      text = %Q{
        foo: bar
        tags: tech, ruby
      }

      sp = Scrapple::SettingsParser.new({}, :array_fields => ['tags'])
      (body, hash) = sp.parse(text)

      expected_hash = {"foo" => "bar", "tags" => ["tech", "ruby"]}
      assert_equal expected_hash, hash
    end
  end


  context "parse_and_merge" do
    should "parse, then merge into result hash" do
      initial = {"layout" => "voodoo", "foo" => "bar"}
      text = %Q{
        foo: BAZ!
        hoge: piyo
      }

      sp = Scrapple::SettingsParser.new(initial)
      sp.parse_and_merge(text)

      expected_hash = {"layout" => "voodoo", "foo" => "BAZ!", "hoge" => "piyo"}
      assert_equal expected_hash, sp.result
    end
  end

end
