Code Highlighting

```ruby
# See if the last path component was a handler
if page.nil? && md = path.match(/^(.*)\/([-a-zA-Z_]+)/)
  page = Page.for(md[1], :fetch => true)
  params['handler'] = md[2]
end
```

```css
ul.breadcrumb      { margin:0px; padding:0px; display:inline-block; list-style:none; background:none; font-size: $baseFontSize * 0.85; color: #999; }
ul.breadcrumb li   { margin:0px 3px 0px 0px; padding:0px; display:inline-block; list-style:none; }
ul.breadcrumb      { a:link, a:visited { color: $linkColor; } }
ul.action-links    { margin:0px; padding:0px; display:inline-block; list-style:none; background:none; font-size: $baseFontSize * 0.85; color: #999; }
ul.action-links li { margin:0px 0px 0px 5px; padding:0px; display:inline-block; list-style:none; }
ul.action-links    { a:link, a:visited { color: $linkColor; } }
```

Hard
Wrap
Text