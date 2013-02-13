require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)

require 'minitest/autorun'
require 'minitest/pride'

# Add the "webapp" directory to load path
$: << File.expand_path("../../lib", __FILE__)

require 'scrapple'

class MiniTest::Spec
  before do
    @content_root = File.expand_path("../test_content", __FILE__)
  end
end
