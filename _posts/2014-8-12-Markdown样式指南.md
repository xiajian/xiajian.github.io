---
layout: post
title: Markdown样式指南
---
译自：[Markdown Style Guide](http://www.jekyllnow.com/Markdown-Style-Guide/)

本文是Jekyll Now中的使用的样式的demo, 原文件在[这里](https://raw.githubusercontent.com/barryclark/www.jekyllnow.com/gh-pages/_posts/2014-6-19-Markdown-Style-Guide.md)

这是一个段落，被空格所包围(就是上下都要空行分隔的意思)。下面介绍一些标题头，这些样式来自Github的Markdown样式。

## 这是一个H2的标题（H1 被文章的标题抢去了）

### 这是一个H3的标题 (注意，空行分隔)

#### H4标题

我用JekyllNow搭建博客[邪王真眼的夏](http://xiajian.github.io)。大屁股的超链接<http://xiajian.github.io>

位于/images目录下的图片，这里里献给了Github的404了。
![github 404](../images/404.jpg)
当然，你可以这样写图片的连接
![an image alt text]({{ site.baseurl }}/images/jekyll-logo.png "你造吗，这是图片的标题")

喜欢子弹头的列表不，可以告诉你的小伙伴，哥有三种子弹头的列表的写法：*,-,+

* 这是一个子弹头

- 这是另一个

+ 这也是一个子弹头
  - 这是珍藏多年的...二级子弹头

这里是有序，列表：

1. 一，一

2. 二

3. 三

正常字体样式，这里有斜的，粗的和暗的：  
- _斜的来的_  
- **水桶那么粗**  
- `淡淡的水影`   

有时，需要引用别人的话，比如

> 子曰:  子是个骗子，别相信他说的
>  ---语出《邪王真眼之万劫不复》

可以使用Liquid标签来高亮你的代码，亮瞎他的钛合金狗眼：
{% highlight javascript %}
/* 这是一段JQuery代码 */
$.each(lists,function(){
	$(this).children('li:gt(4)').hide();
});
$(".view_all_arts").click(function(){
	$(this).siblings(".article_list").children("li:gt(4)").slideToggle("fast");
	$(this).parent(".article_category").toggleClass("open");
	if ($(this).parent(".article_category").hasClass("open")){
		$(this).html('收起'+'<span class="icon open_icon">▼</span>');
	} else {
		$(this).html('更多'+'<span class="icon open_icon">▼</span>');
	}
});
{% endhighlight %}

接下来，给你支个招，如何断。。行，只要在行未加上  
两个空格  
不信，带上你的放大镜，看，这里有个空格  

最后，祭上巨大的水平线

----
****

# 后记 

最后，上面的这些就是介绍的Markdown的样式语法，感觉不太全，但是够常用了。

# 参考文献
1. [Mastering Markdown](https://guides.github.com/features/mastering-markdown/)
