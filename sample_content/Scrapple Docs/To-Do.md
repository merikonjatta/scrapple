Scrapple To-Do
==============

* Support slim
* Support layout for non-page requests
* Edit new files
* Image uploads
* 日本語ファイル名が化けたり化けなかったりする
* Make sure \\[[ ... ]] macro syntax doesn't conflict with templating languages
* self['key'] is kinda dull
* Validate presence of content_dir (and plugin-dir?)
* ymlでいいやん（Part 2)
* Respond to write in json
* Authorization
* Think of a way to test plugins
* Some Rack::Tests
* Find pages across roots
* Write sass cache to temp dir
* Document
    * How to write settings.txt
    * Webapp config keys
    * Plugin authoring
    * Kinds (Handler, Macro, mixin module, Rack middleware, hook, content)
        * Namespacing
        * Placement
        * content dir
        * Gemfiles
        * Rack middleware stack
            * Use same sinatra version

----

* Return to previous location (/auth/twitter?origin=http://...)
* For setups that don't want open registrations, the admin must first
  add accounts. This should be done in a file-based manner. The admin is
  probably going to edit this file manually. If so, the identifying keys
  should not be long numeric uids, but rather something like nicknames or
  emails that's more easy to put down. It does have the drawback that
  if a user changes his Twitter nick or email, this file has to be edited
  manually again.
* How to tell the local app which user I am?
    * If I edit files locally, then who edited it? How will the server know?
        * If using dropbox, could query the API to find out

----

* Plugin: impress.js
* Plugin: rak search
* Plugin: gist

----

* Handler aliases
* Think about caching
* EUC-JP and SJIS

[[include "/remindme.md"]]
