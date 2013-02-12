require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)

require 'active_support/test_case'
require 'shoulda'
require 'minitest/pride'

# Add the "webapp" directory to load path
$: << File.expand_path("../../../", __FILE__)

class ActiveSupport::TestCase
  setup do
    @content_root = File.expand_path("../test_content", __FILE__)
  end
end
