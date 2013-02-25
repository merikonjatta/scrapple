#!/usr/bin/env ruby
exec "compass watch -c compass.rb" if ($0 == __FILE__)

# See http://compass-style.org/help/tutorials/configuration-reference/ for a
# complete list of config options.

require 'compass_twitter_bootstrap'

# Set this to the root of your project when deployed:
http_path        = "/"
sass_dir         = "scss"
css_dir          = "content/css"
images_dir       = "content/img"
http_images_path = "/img"
javascripts_dir  = "content/js"
