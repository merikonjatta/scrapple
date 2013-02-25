# This is a sample compass.rb for theme plugins that want to use compass-bootstrap.

# Require any additional compass plugins here.
require 'compass_twitter_bootstrap'

# Set this to the root of your project when deployed:
http_path       = "/"
sass_dir        = "scss"
css_dir         = "content/css"
images_dir = nil
http_images_path          = http_path + "img"
images_path               = File.expand_path("../../compass-bootstrap/content/img", __FILE__)
generated_images_path     = File.expand_path("../../compass-bootstrap/content/img", __FILE__)

# You can select your preferred output style here (can be overridden via the command line):
# output_style = :expanded or :nested or :compact or :compressed

# To enable relative paths to assets via compass helper functions. Uncomment:
# relative_assets = true

# To disable debugging comments that display the original location of your selectors. Uncomment:
# line_comments = false


# If you prefer the indented syntax, you might want to regenerate this
# project again passing --syntax sass, or you can uncomment this:
# preferred_syntax = :sass
# and then run:
# sass-convert -R --from scss --to sass plugins/bootstrap-sass/scss scss && rm -rf sass && mv scss sass
