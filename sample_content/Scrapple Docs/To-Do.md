Scrapple To-Do
==============

* Better support for _secret.txt
* Stop relying on body.each
* Remove settings parsing section from webapp.rb
* Support slim
* Support layout for non-page requests
* Edit new files
* Image uploads
* 日本語ファイル名が化けたり化けなかったりする
* Make sure \[[ ... ]] macro syntax doesn't conflict with templating languages
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

### Authentication: Todo

* Return to previous location (/auth/twitter?origin=http://...)
* Make rack env available in Pages?

### Authentication: Specs

* Where and how to store user data?
    * There has to be some kind of persistent storage
    * Need to store usernames (to be specified in autho), OmniAuth identities
    * Text or Sqlite?
        * Text files are easier for the user
        * Databases are easier for the system
    * Cannot store this in the content dir, because it will be totally insecure
      if shared over Dropbox or git or whatever
    * Outside the content dir means not editable locally
* Where and how to store API keys and tokens?
    * It's a security risk for users of the app to know these keys
    * That means outside the content dir
    * A central config file?

* There probably should be a central login page
    * Plugins should be able to place their login links on this page
* The callback action should be provided by the core
* Most plugins will need config like App Token. Where to store these
  safely?
* We need a User model class (doesn't have to connect to a db, though)
* We need a user profile page where already logged in users can add other
  provider accounts
* When an existing (but not logged in) user logs in with an unknown
  provider/account, either...
    * Ask for a username
        * Some setups will allow all existing usernames to be shown to make
          things easier
    * Or add links to other provider logins
        * The first auth info has to be stored temporarily. This info will
          probably not fit in the cookie. Using a file session store will
          make this easier
        * When the next auth is known, the accounts will be merged
        * If unknown, repeat
* For setups that don't want open registrations, the admin must first
  add accounts. This should be done in a file-based manner. The admin is
  probably going to edit this file manually. If so, the identifying keys
  should not be long numeric uids, but rather something like nicknames or
  emails that's more easy to put down. It does have the drawback that
  if a user changes his Twitter nick or email, this file has to be edited
  manually again.
* Even if Twitter's uid IS the nick (which is unlikely), other providers
  might use more bizzare uids. Thus each plugin should be able to specify
  which field to put down in the users data.
* Should I use a different App for auth-related stuff? (probably yes)
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
