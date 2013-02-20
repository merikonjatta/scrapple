title: Using Macros

Using macros
============

Macros are short commands you can write in your page content that will
expand into something useful.

A quick example would be

    \[[index]]

which will expand into a list of child pages.

If you're a rubyist, you can write any ruby code inside those brackets and
they will be executed.

    \[[Time.now]]

Will result in: [[Time.now]]

Whether or not macros will be expanded depends on which [handler](/scrapple_help/handlers)
rendered the page. The "default" and "markdown" handlers do support macros.

List of known macros
--------------------

[[index :of => "."]]


Disabling macros
----------------

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
