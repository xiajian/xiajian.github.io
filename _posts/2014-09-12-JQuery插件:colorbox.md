---
layout: post
title: JQuery插件:colorbox
---

## 缘起
----
本来想，不去了解Colorbox，也是可以直接使用的。结果遇到一些奇怪的问题，看来果然是没办法绕过这个槛的。

## 介绍
-----
Colorbox是一个jQuery的轻量级，可定制的lightbox插件。MIT条约，兼容jQuery 1.3.2+。其特性如下:

* 支持图片，分组，幻灯片播放，Ajax，内连以及iframed内容
* 轻量，10kb，压缩后少于5kb
* 样式可通过CSS重新定义
* 可通过回调和事件钩子进行扩展，而不需要修改源文件
* 相当自然，选项可通过JS设置，不需要更改已存在的HTML
* 对照片群组使用预加载

## 使用
----

jQuery使用CSS selector在DOM树选择其合适的元素，$('xxx').colorbox()。浏览器从头开始解析HTML文档，一旦遇到<script>，浏览器将文档解析挂起，先执行JS脚本，然后再解析文档。脚本在标签链接被添加到DOM之前执行(脚本在<head>中定义)。colorbox接受的设置选项是以逗号分隔的键值对。

Colorbox接受键值对的对象的设置，并可以被复制给任意HTML元素。

例子: 

    // 样例:
    // Image links displayed as a group
    $('a.gallery').colorbox({rel:'gal'});

    // Ajax
    $('a#login').colorbox();

    // Called directly, without assignment to an element:
    $.colorbox({href:"thankyou.html"});

    // Called directly with HTML
    $.colorbox({html:"<h1>Welcome</h1>"});

    // Colorbox can accept a function in place of a static value:
    $("a.gallery").colorbox({rel: 'gal', title: function(){
      var url = $(this).attr('href');
      return '<a href="' + url + '" target="_blank">Open In New Window</a>';
    }});

## 设置
----

colorbox中的参数设置详细参考具体的项目的具体页面。

相关资料

jQuery colorbox插件: http://www.open-open.com/lib/view/open1338084606042.html

官方地址: <http://www.jacklmoore.com/colorbox/>

介绍

jQuery Colorbox是一款非常好的内容播放插件。它集弹出层、幻灯片播放功能于一身，不仅于此，它还支持其它的内容格式：例如html, flash, iframe等，这些内容的显示方式都是Ajax的。更难能可贵的是，在压缩后它只有10K的大小，使用这款插件不会给你的网页带来过多的负担，而且还能 实现很棒的视觉效果，为用户体验增色不少。

每个例子中提供了以下的效果: 

-  Elastic Transition（弹性动画）
-  Fade Transition（淡入淡出动画）
-  No transition + fixed width and height  75% of screen size (无动画，宽高以屏幕的75%自适应)
-  Slideshow（幻灯片播放）
-  Other Content Types （其它类型：外部html, flash和视频，iframe的flash和视频，iframe的外部html，内部html）



## 后记
----
colorbox中真的提供了对Ajax的支持吗？


