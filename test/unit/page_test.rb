require File.expand_path("../../test_helper", __FILE__)

describe Scrapple::Page do
  before do
    SUT ||= Scrapple::Page
  end
  
  describe "for" do
    it "should return an instance for a relative and root path" do
      page = SUT.for "index.md", @content_root
      page.fullpath.must_equal @content_root+"/index.md"
      page.path.must_equal "index.md"
    end

    it "should return an instance for a relative directory and root path" do
      page = SUT.for "john", @content_root
      page.fullpath.must_equal @content_root+"/john/index.md"
    end

    it "should return an instance for an absolute path" do
      page = SUT.for @content_root+"/index.md", @content_root
      page.fullpath.must_equal @content_root+"/index.md"
      page.path.must_equal "index.md"
    end

    it "should return an instance for an absolute directory" do
      page = SUT.for @content_root+"/john", @content_root
      page.fullpath.must_equal @content_root+"/john/index.md"
    end

    it "should return nil if file doesn't exist" do
      page = SUT.for "purewater", @content_root
      page.must_be_nil
    end

    it "should return nil if directory exists but no index file" do
      page = SUT.for "tony", @content_root
      page.must_be_nil
    end

    it "should fetch if :fetch => true option passed" do
      page = SUT.for "john/private/passwords.md", @content_root, :fetch => true
      page.settings['category'].must_equal 'security'
      page.settings['readable'].must_equal 'john'
      page.content.must_match /Thought you'd find something here\?/
    end
  end


  describe "fetch" do
    it "should populate settings and content to be rendered" do
      page = SUT.for "john/private/passwords.md", @content_root
      page.fetch

      page.settings['category'].must_equal 'security'
      page.settings['readable'].must_equal 'john'
      page.content.must_match /Thought you'd find something here\?/
    end
  end

end