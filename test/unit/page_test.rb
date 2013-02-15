require File.expand_path("../../test_helper", __FILE__)

describe Scrapple::Page do
  before do
    SUT ||= Scrapple::Page
    Scrapple::FileLookup.roots.clear
    Scrapple::FileLookup.roots << @content_root
  end
  
  describe "for" do
    it "should return an instance for a relative path" do
      page = SUT.for "index.md"
      page.fullpath.must_equal @content_root+"/index.md"
      page.path.must_equal "index.md"
    end

    it "should return an instance for a relative directory" do
      page = SUT.for "john"
      page.fullpath.must_equal @content_root+"/john/index.md"
    end

    it "should return an instance for an absolute path" do
      page = SUT.for @content_root+"/index.md"
      page.fullpath.must_equal @content_root+"/index.md"
      page.path.must_equal "index.md"
    end

    it "should return an instance for an absolute directory" do
      page = SUT.for @content_root+"/john"
      page.fullpath.must_equal @content_root+"/john/index.md"
    end

    it "should return nil if file doesn't exist" do
      page = SUT.for "purewater"
      page.must_be_nil
    end

    it "should return Page for directory if directory exists but no index file" do
      page = SUT.for "tony"
      page.fullpath.must_equal @content_root+"/tony"
      page.type.must_equal "directory"
    end

    it "should fetch if :fetch => true option passed" do
      page = SUT.for "john/private/passwords.md", :fetch => true
      page.settings['category'].must_equal 'security'
      page.settings['readable'].must_equal 'john'
      page.content.must_match /Thought you'd find something here\?/
    end
  end


  describe "fetch" do
    it "should populate settings and content to be rendered" do
      page = SUT.for "john/private/passwords.md"
      page.fetch

      page.settings['category'].must_equal 'security'
      page.settings['readable'].must_equal 'john'
      page.content.must_match /Thought you'd find something here\?/
    end
  end

end
