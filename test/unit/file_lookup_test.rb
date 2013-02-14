require File.expand_path("../../test_helper", __FILE__)

describe Scrapple::FileLookup do
  
  describe "find_in_base_path" do
    it "should find a file" do
      assert File.exist?(@content_root + "/index.md")

      found = Scrapple::FileLookup.find_in_base_path("index.md", @content_root)
      found.must_equal @content_root + "/index.md"
    end


    it "should find a file by adding extension" do
      assert File.exist?(@content_root + "/index.md")

      found = Scrapple::FileLookup.find_in_base_path("index", @content_root)
      found.must_equal @content_root + "/index.md"
    end


    it "should find an index file in the matching directory" do
      assert File.exist?(@content_root + "/john/index.md")

      found = Scrapple::FileLookup.find_in_base_path("john", @content_root)
      found.must_equal @content_root + "/john/index.md"
    end


    it "should return extended file if both that and dir index are present" do
      assert File.exist?(@content_root + "/frank.textile")
      assert File.exist?(@content_root + "/frank/index.textile")

      found = Scrapple::FileLookup.find_in_base_path("frank", @content_root)
      found.must_equal @content_root + "/frank.textile"
    end


    describe "when file not found" do
      it "should return nil" do
        found = Scrapple::FileLookup.find_in_base_path("owjkdkqpfwo", @content_root)
        found.must_be_nil
      end

      it "should raise if :raise => true" do
        proc {
          Scrapple::FileLookup.find_in_base_path("owjkdkqpfwo", @content_root, :raise => true)
        }.must_raise Scrapple::FileNotFound
      end

    end
  end # find_in_base_path



  describe "find" do

    before do
      Scrapple::FileLookup.base_paths.clear
      Scrapple::FileLookup.base_paths << @content_root + "/frank"
      Scrapple::FileLookup.base_paths << @content_root + "/john"
    end


    it "should find the first file in all base paths" do
      assert File.exist?(@content_root + "/frank/index.textile")
      assert File.exist?(@content_root + "/john/index.md")

      found = Scrapple::FileLookup.find("index")
      found.must_equal @content_root + "/frank/index.textile"
    end


    it "should look in base paths given as options" do
      found = Scrapple::FileLookup.find("index", :base_paths => [@content_root + "/john/private"])
      found.must_equal @content_root + "/john/private/index.md"
    end


    describe "when file not found in any of the base paths" do
      it "should return nil" do
        found = Scrapple::FileLookup.find("pwcmepweiue")
        found.must_be_nil
      end

      it "should raise if :raise => true" do
        proc { Scrapple::FileLookup.find("pwcmepweiue", :raise => true) }.must_raise Scrapple::FileNotFound
      end
    end

  end # find


  describe "find_first_ascending" do

    before do
      Scrapple::FileLookup.base_paths.clear
      Scrapple::FileLookup.base_paths << @content_root
    end


    it "should find the file next to near" do
      assert File.exist?(@content_root + "/john/private/_settings.txt")

      found = Scrapple::FileLookup.find_first_ascending("_settings", @content_root + "/john/private/index.md")
      found.must_equal @content_root + "/john/private/_settings.txt"
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


  describe "find_all_ascending" do

    before do
      Scrapple::FileLookup.base_paths.clear
      Scrapple::FileLookup.base_paths << @content_root
    end

    it "should find all files in between" do
      found = Scrapple::FileLookup.find_all_ascending("_settings", @content_root + "/john/private/index.md")
      found.must_equal [@content_root + "/john/private/_settings.txt",
                        @content_root + "/_settings.txt"]
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


end
