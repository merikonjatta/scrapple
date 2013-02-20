Scrapple -- The nothing-to-waste CMS
====================================

Scrapple is yet another "simple" "lightweight" CMS that focuses on "usability". (Yeah whatever)

Actually, Scrapple is a file-based wiki-like CMS specifically designed to be suitable as your personal wiki.
Kind of like Evernote.

*Warning: Nobody should use this software under any circumstances.*


Try it out
----------

* Clone the repo
* `$ bundle install`
* `$ bundle exec rackup`
* Go to http://localhost:9292/ to see the site running with sample content


### What Scrapple is good at

* Can render lots of templates (anything supported by Tilt).
* Can just serve some plain HTMLs.
* In fact, it can serve any kind of file, if you care to put it in your content directory.
* Can use different layouts/stylesheets for specific subdirectories or files
* Very easy to configure
* Can be mounted as a part of a Rails app (it's rack-based)
* Coming soon...
  * Can authenticate users for specific subdirectories or files
  * Can transform your html into a impress.js presentation (just add "/as/impress" to the url)
  * Can transform a directory of markdowns into an epub book (just add "/as/epub" to the url)
  * Can zip your directory and let you download it (just add "/as/zip" to the url)
  * and more, by adding plugins
  * Full text search


### Where Scrapple falls short

* Totally insecure if used as publicly editable wiki
* Not tuned for performance
* Does not scale well
* Not tested well enough


### Will it work on my system?

* Runs on Unicorn, Thin, Mongrel, Webrick, etc
* Runs on Ruby 1.9.2 (Other implementations might work, but MRI 1.8 can't take it)
* No database needed (entirely file-based)

### How to hack scrapple

* Run `$ bundle exec shotgun` or `$ bundle exec rerun --background rackup`
  instead of just rackup, so that your code will reload on change
* Run `$ yard` to see core API docs (at `doc/index.html`)
* Look at the code in `plugins/` to see how to implement them
* Hack away

Alternatives
------------

* Evernote
* Gollum
* Redmine
* Nesta CMS
* Jekyll
