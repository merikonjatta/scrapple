Scrapple To-Do
==============

* Remove theme slab
* Edit new files
* Image uploads
* Respond to write in json
* Authorization
* Think of a way to test plugins
* Some Rack::Tests
* Write sass cache to temp dir
* Editor should use a Page

----

* Make sure \\[[ ... ]] macro syntax doesn't conflict with templating languages
* 日本語ファイル名が化けたり化けなかったりする
* When and how is html escaped?

----

* self['key'] is kinda dull

----

Document

* How to write config.yml/_config.yml
* Webapp config keys
* Plugin authoring
    * Basic architecture
        * Page attributes and settings: attributes are inherent
    * Macros
        * Are Page mixins
    * Handlers
        * Macro support: should be expanded before template language processing
        * Layout support
    * Rack Middleware
    * Auth
    * Hooks
    * Content
    * Themes
        * Page settings conventions
            * javascripts, stylesheets
            * body_class default, full
    * Mixin Modules
    * Namespacing
    * Placement
    * Content dir
    * Gemfiles
* Rack middleware stack
    * Use same sinatra version

----

Authentication

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
