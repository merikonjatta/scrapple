proc {
  css_path = File.expand_path("../content/css", __FILE__)
  Sass::Plugin.add_template_location(css_path, css_path)
}.call
