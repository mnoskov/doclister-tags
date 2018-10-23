# DocLister + Tags

After install create `tags` parameter and add mmrule:
```php
mm_widget_tags('tags', ',');
```

Show popular tags:
```php
[[popularTags?
   &parameter=`tag`
   &count=`10`
   &tv=``
   &url=`[~[*id*]~]`
   &tpl=`@CODE:<a href="[+url+]"[+class+]>[+name+]</a>`
   &ownerTPL=`@CODE:<div class="socials">[+wrap+]</div>`
]]
```

Filter results by tag:
```php
[[DocLister? 
   &controller=`site_content_tags`
   &tagsTV=`1`
   &tagsData=`get:tag`
]]
```

Source: http://modx.im/blog/addons/374.html
