---
layout: page
title: 邪王真眼的夏
---

## 简介
----
{% include JB/setup %}

这里是邪王正眼的夏(读作:jia wang jing yan的sunmmer)的魔法基地-- 暗黑魔境之电子海湾，召唤方式: <http://xiajian.github.io>。

暗焰魔图谐阵：三次天元破幻之星空立体魔法咒符

<div class="site-avatar">
  <img src="assets/images/face.jpg">
</div> 
<br/>

> 备注：若见此咒，如见其人，如临其境，所谓人图一体。


## 详细介绍
----

本电子海湾利用高阶魔法[Jekyll Bootstrap](http://jekyllbootstrap.com)锻造七七四十九周天。

以下，言归正传:

文档和使用可以参考[Jekyll](http://jekyllrb.com/)以及[Jekyll Bootstrap](http://jekyllbootstrap.com)。

具体操作而言，Jekyll要会配置_config.yml，要会启动服务器等。Jekyll Bootstrap可能需要一点Bootstrap的知识。

最重要的一步是，先将代码从Github上clone下来，然后捋起袖子开始狠狠的干。

## 后记
----

起初，不太熟悉的时候使用[Jekyll Now](https://github.com/barryclark/jekyll-now)搭建自己的Github电子海湾。

随着，自己的写的魔法扎记的增多，都显示在一页，实在是不太好。就尝试了一下[Jekyll Bootstrap](http://jekyllbootstrap.com)，有些不太满意的地方，比如字体的颜色和大小，修改并询问他人废去了不少魔力。终于，在魔力快要枯竭时，完成了。

[Jekyll Bootstrap](http://jekyllbootstrap.com)优点很多，比如，下面的这个循环：

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>

突然，想到，如果之前的博客的index页面中，只显示标题就就可以缓解条目过多的问题。好不容易走到这一步，还是继续走下去吧！！

Markdown的文件中，是可以直接使用HTML+css进行控制的，静态HTML的动态效果可以通过bootstrap的js提供。

尝试了一下，手机访问<http://xiajian.github.io>，发现不能自适应，果然是直接给定宽度的问题，自己又想不到好的解决方案。
