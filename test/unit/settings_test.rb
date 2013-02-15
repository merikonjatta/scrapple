require File.expand_path("../../test_helper", __FILE__)

describe Scrapple::Settings do
  
  it "should be enumerable" do
    s = Scrapple::Settings.new({"a" => "A", "b" => "B"})
    keys = ["a", "b"]
    values = ["A", "B"]

    s.each do |key, value|
      keys.delete key
      values.delete value
      value.must_equal key.upcase
    end

    keys.must_be_empty
    values.must_be_empty
  end


  describe "[] and []=" do
    it "should work like hash [] and []=" do
      s = Scrapple::Settings.new({"a" => "A", "b" => "B"})
      s["a"].must_equal "A"

      s["c"] = "C"
      s["c"].must_equal "C"
    end
  end


  describe "#parse" do
    it "should parse an IO and return the content body and settings hash" do
      text = <<-EOT.unindent
        layout: mobile
        category: notes
        future: bright

        Content starts here.
      EOT

      (body, hash) = Scrapple::Settings.new.parse(StringIO.new(text))

      hash.must_equal( {"layout"=> "mobile", "category" => "notes", "future"=> "bright"} )
      body.must_match /\AContent starts here\.\s+\Z/
    end


    it "should parse whole IO as directives if :dont_stop" do
      text = <<-EOT.unindent
        layout: mobile

        future: bright
      EOT

      (body, hash) = Scrapple::Settings.new.parse(StringIO.new(text), :dont_stop => true)
      hash.must_equal( {"layout" => "mobile", "future" => "bright"} )
    end


    it "should open and read from file if given a string" do
      assert File.exist?( @content_root+"/_settings.txt" )

      (body, hash) = Scrapple::Settings.new.parse(@content_root+"/_settings.txt")
      hash.must_equal( {"readable" => "public"} )
    end
  end


  describe "#parse_and_merge" do
    it "should parse, then merge into result hash" do
      initial = {"layout" => "voodoo", "foo" => "bar"}
      text = <<-EOT.unindent
        foo: BAZ!
        hoge: piyo
      EOT

      s = Scrapple::Settings.new(initial)
      s.parse_and_merge(StringIO.new(text))

      s.hash.must_equal( {"layout" => "voodoo", "foo" => "BAZ!", "hoge" => "piyo"} )
    end
  end


  describe "#normalize" do
    it "should downcase keys and strip whitespace" do
      hash = {" FiZz" => "Buzz  "}
      normalized = Scrapple::Settings.new.normalize(hash)
      normalized.must_equal( {"fizz" => "Buzz"} )
    end
  end

end
