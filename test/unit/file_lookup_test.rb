require File.expand_path("../../test_helper", __FILE__)

describe Scrapple::FileLookup do

  before do
    Scrapple::FileLookup.roots.clear
    Scrapple::FileLookup.roots << @content_root
  end

  
  describe "find_in_root" do
    it "should find a file" do
      assert File.exist?(@content_root + "/index.md")

      found = Scrapple::FileLookup.find_in_root("index.md", @content_root)
      found.must_equal @content_root + "/index.md"
    end


    it "should find a file by adding extension" do
      assert File.exist?(@content_root + "/index.md")

      found = Scrapple::FileLookup.find_in_root("index", @content_root)
      found.must_equal @content_root + "/index.md"
    end


    it "should find an index file in the matching directory" do
      assert File.exist?(@content_root + "/john/index.md")

      found = Scrapple::FileLookup.find_in_root("john", @content_root)
      found.must_equal @content_root + "/john/index.md"
    end


    it "should return extended file if both that and dir index are present" do
      assert File.exist?(@content_root + "/frank.textile")
      assert File.exist?(@content_root + "/frank/index.textile")

      found = Scrapple::FileLookup.find_in_root("frank", @content_root)
      found.must_equal @content_root + "/frank.textile"
    end


    it "should return directory if there is no index file" do
      assert File.directory?(@content_root + "/tony")

      found = Scrapple::FileLookup.find_in_root("tony", @content_root)
      found.must_equal @content_root + "/tony"
      File.directory?(found).must_be :==, true
    end


    describe "when given a fullpath" do
      it "should find it" do
        assert File.exists?(@content_root + "/john/index.md")

        found = Scrapple::FileLookup.find_in_root(@content_root + "/john/index.md", @content_root)
        found.must_equal @content_root + "/john/index.md"
      end

      it "should be nil if fullpath is outside the root" do
        found = Scrapple::FileLookup.find_in_root(@content_root + "/john/index.md", @content_root + "/frank")
        found.must_be_nil
      end
    end


    describe "when file not found" do
      it "should return nil" do
        found = Scrapple::FileLookup.find_in_root("owjkdkqpfwo", @content_root)
        found.must_be_nil
      end
    end
  end # find_in_root



  #================================================================================
  describe "find" do

    before do
      Scrapple::FileLookup.roots.clear
      Scrapple::FileLookup.roots << @content_root + "/frank"
      Scrapple::FileLookup.roots << @content_root + "/john"
    end


    it "should find the first file in all base paths" do
      assert File.exist?(@content_root + "/frank/index.textile")
      assert File.exist?(@content_root + "/john/index.md")

      found = Scrapple::FileLookup.find("index")
      found.must_equal @content_root + "/frank/index.textile"
    end


    describe "when file not found in any of the base paths" do
      it "should return nil" do
        found = Scrapple::FileLookup.find("pwcmepweiue")
        found.must_be_nil
      end
    end

  end # find


  #================================================================================
  describe "find_first_ascending" do

    it "should find the file next to near" do
      assert File.exist?(@content_root + "/john/private/_config.yml")

      found = Scrapple::FileLookup.find_first_ascending("_config", @content_root + "/john/private/index.md")
      found.must_equal @content_root + "/john/private/_config.yml"
    end


    it "should find the file in base path" do
      assert File.exist?(@content_root + "/frank.textile")

      found = Scrapple::FileLookup.find_first_ascending("frank", @content_root + "/john/private/index.md")
      found.must_equal @content_root + "/frank.textile"
    end

    
    describe "when not found" do
      it "should return nil" do
        found = Scrapple::FileLookup.find_first_ascending("salkfupaow", @content_root + "/john/private/index.md")
        found.must_be_nil
      end
    end
  end # find_first_ascending


  #================================================================================
  describe "find_all_ascending" do

    before do
      Scrapple::FileLookup.roots.clear
      Scrapple::FileLookup.roots << @content_root
    end

    it "should find all files in between" do
      found = Scrapple::FileLookup.find_all_ascending("_config", @content_root + "/john/private/index.md")
      found.must_equal [@content_root + "/john/private/_config.yml",
                        @content_root + "/_config.yml"]
    end

    describe "with bad args" do
      it "should raise if near is not part of base paths" do
        proc { Scrapple::FileLookup.find_all_ascending("frank", File.expand_path(__FILE__)) }.must_raise ArgumentError
      end

      it "should raise if near doesn't exist" do
        proc { Scrapple::FileLookup.find_all_ascending("frank", "/boogiewoogiewundaland!") }.must_raise ArgumentError
      end
    end
    
    describe "when not found" do
      it "should return emtpy array" do
        found = Scrapple::FileLookup.find_all_ascending("salkfupaow", @content_root + "/john/private/index.md")
        found.must_equal []
      end
    end

  end # find_all_ascending


  #================================================================================
  describe "parent_root" do
    it "should return which basepath a fullpath is the descendant of" do
      Scrapple::FileLookup.roots.clear
      Scrapple::FileLookup.roots << @content_root + "/john"
      Scrapple::FileLookup.roots << @content_root + "/frank"

      root = Scrapple::FileLookup.parent_root(@content_root + "/john/index.md")
      root.must_equal @content_root + "/john"
    end
  end


  #================================================================================
  describe "descendant?" do
    it "should be true if a fullpath is a descendant of another fullpath" do
      assert Scrapple::FileLookup.descendant? "/a/b/c", "/a/b"
      assert Scrapple::FileLookup.descendant? "/a/b/", "/a/b/"
    end
  end


end
