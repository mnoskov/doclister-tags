# DocLister + Tags

After install create `tags` parameter and add mmrule:
```php
mm_widget_tags('tags', ',');
```

Show popular tags:
```php
[[Tags?
   &from=`popular`
]]
```

Filter results by tag:
```php
[[DocLister? 
   &controller=`site_content_tags`
   &tagsData=`get:tag`
]]
```

Source: http://modx.im/blog/addons/374.html
