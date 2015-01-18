---
layout: post
title: html5-boilerplate and Bootstrap的关系
---

## 前言

我又搞懂了两个看起来不错的东西之间的关系: html5-boilerplate和Bootstrap。具体的内容来自[Quora](https://www.quora.com/Is-Bootstrap-a-complement-or-an-alternative-to-HTML5-Boilerplate-or-viceversa/answer/Nicolas-Gallagher)。

## 正文

HTML5 Boilerplate and Twitter Bootstrap are doing different things but it is relatively easy to combine them.

HTML5 Boilerplate和Twitter Bootstrap处理的问题不同，但很容易组合两者。

The HTML5 Boilerplate (H5BP) is a starting project template that is designed to be adapted to your needs. Bootstrap is a specialised, modular, HTML/CSS/JS toolkit.

HTML5 Boilerplate (H5BP)是用来启动项目的模板，其被设计成适应你的需求。Bootstrap则是一个专门的，模块化的，HTML/CSS/JS工具箱。


H5BP contains a number of best practices or common inclusions for your initial HTML template, which is more like the generic "default" template you would use as server-side global template. Bootstrap does not provide anything like this (nor does it need or aim to). So in this regard, H5BP is perfectly suited to including HTML components from anywhere else (e.g. those from Bootstrap).

H5BP包含了一组最佳实践，以及用来初始化HTML模板的通用指令，其非常适合用作服务器端默认的全局模板。Bootstrap并不提供任何HTML模板相关的功能，其既不需要、也不打算这么做。所以，在这一方面，H5BP特别适合包含其他组件(比如Bootstrap)。

The H5BP project also contains a comprehensive set of server configs to help provide an optimised experience. Again, this is unique to H5BP and can be used alongside Bootstrap to improve site performance, among other things.

H5BP也包含一组服务器端的配置，提供优化过的配置经验。这同样是H5BP特有的，并且可以用来提高站点的性能，以及其他相关事物。

The H5BP CSS is a starting point that is largely based on [Normalize.css](https://github.com/necolas/normalize.css) (see the Normalize.css and H5BP wikis for comprehensive documentation on each line of CSS). It is there to get you started from a consistent and explained base, but is designed to be interchangeable if that is what you need to do. This means that you can easily switch the default H5BP CSS for the whole Bootstrap Less/CSS toolkit. The Bootstrap Less/CSS uses parts of Normalize.css, so you will still get some of the benefits packaged with the H5BP CSS when using Bootstrap's CSS.

H5BP的css基于著名的[Normalize.css](https://github.com/necolas/normalize.css)，并做了一些扩展。这使得我们有一个一致的，可扩展的基础。其内容被设计成可随意的替换，这意味着，可以将默认的H5BP的css替换为Bootstrapdd的 Less/CSS 组件工具。Bootstrap中也使用了部分Normalize.css，所以，在使用Bootstrap的css时，混用H5BP CSS也不错。

There are a few things in the H5BP CSS that you might want to add to Bootstrap - the print styles and some of the CSS helper classes.

当然，也有一些你可能想要添加到Bootstrap中的H5BP CSS - 打印样式以及一些CSS辅助样式类。

All the Bootstrap JS plugins are built to work with jQuery, which is included by default with HTML5 Boilerplate, so their inclusion is also not a problem.

所有Bootstrap的js插件都构建在jQuery之上，而H5BP中已默认包含了jQuery，所以，混合使用也不是个问题。

I hope this has explained how the CSS/JS of both projects is designed to be self-contained, making it easy to switch the CSS/JS subset of H5BP for the CSS/JS that forms the core of Bootstrap.

H5BP和Bootstrap这两个项目都将CSS/JS都被设计成自包含的， 这样可以方便的切换H5BP和Bootstrap核心的CSS/JS。

The Initializr project - http://www.initializr.com/ - helps you to automatically integrate H5BP and Twitter Bootstrap.

Initializr项目帮助你自动整合H5BP和Twitter Bootstrap。

> 注: <http://www.initializr.com/> 网站没能打开，项目找到了: https://github.com/verekia/initializr

Mickael Daniel (aka mklabs) - a contributor to H5BP who has done all sorts of work on the build scripts - has also put together a script that automates the combination of H5BP and Bootstrap: https://gist.github.com/1422879

Mickael Daniel (aka mklabs) 做了自动化组合H5BP和Bootstrap的构建脚本，具体参考: <https://gist.github.com/1422879>。

> 注:  带gist前缀的github网址似乎都打不开。

## 后记

翻译完成后，发现，这两者是可以整合的，并且部分可以替换。下一项目中，有增加了一个起步的筹码。
