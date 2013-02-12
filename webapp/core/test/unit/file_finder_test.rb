require File.expand_path("../../test_helper", __FILE__)

require "core/file_finder.rb"

class Scrapple::FileFinderTest < ActiveSupport::TestCase
  
  context "find" do
    should "find a file in the root path" do
      assert_equal File.join(@content_root, "index.md"), Scrapple::FileFinder.find("index.md", @content_root)
    end

    should "find the root index file if given an empty string" do
      assert_equal File.join(@content_root, "index.md"), Scrapple::FileFinder.find("", @content_root)
    end

    should "find the subdirectory index file if given a subdirectory path" do
      assert_equal File.join(@content_root, "john/index.md"), Scrapple::FileFinder.find("john", @content_root)
    end

    should "find a file with extension if given a basename" do
      assert_equal File.join(@content_root, "john/profile.md"), Scrapple::FileFinder.find("john/profile", @content_root)
    end
  end


  context "find_in_ancestors" do
    should "find all _settings.txt files, next to leaf first, root last" do
      expected = [File.join(@content_root, "john/private/_settings.txt"),
                  File.join(@content_root, "_settings.txt")]
      assert_equal expected, Scrapple::FileFinder.find_in_ancestors("_settings.txt", File.join(@content_root, "john/private/index.md"), @content_root)
    end
  end


  context "find_nearest_in_ancestors" do
    should "find the nearest matching file, next to leaf first, root last" do
      expected = File.join(@content_root, "john/private/_settings.txt")
      assert_equal expected, Scrapple::FileFinder.find_nearest_in_ancestors("_settings.txt", File.join(@content_root, "john/private/index.md"), @content_root)
    end
  end

end
