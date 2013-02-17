title: Using Macros

Using macros
============

Macros are short commands that you write in your page content.

A quick example would be

    \[[index]]

which will expand into a list of child pages.

If you're a rubyist, you can write any ruby code inside those brackets and
they will be executed.

    \[[Time.now]]

Will result in: [[Time.now]]

Be aware that you could destroy your computer using this.

List of known macros
--------------------

[[index :of => "."]]


Macro settings
--------------

You can limit what macros may be expanded.  In your `_settings.txt` file, put

    macros: index, breadcrumbs, disqus

to allow only those macros. To disallow everything, put

    macros: none

(`no` or `false` will work, too.)

If you want to allow a macro but still write something in double brackets
(like we do on this page), put a `\` (backslash) before it.

    \\[[index]]


Creating new macros
-------------------

Coming soon...
