Code Highlighting

```ruby
  # See if the last path component was a handler
  if page.nil? && md = path.match(/^(.*)\/([-a-zA-Z_]+)/)
    page = Page.for(md[1], :fetch => true)
    params['handler'] = md[2]
  end
```

Hard
Wrap
Text
