---
layout: post
title: html5-boilerplate
---

## 前言

最近，主攻前端开发，研究前端开发框架，看《HTML5和CSS3实例教程》。涉及了这样的项目: sass, compass, bootstrap/ratchet, html5-boilerplate。
我的目的是搞懂这些坑爹的东西，理清其间的关系，提高自己的能力，最终，组合这些能力，用来干点别的有趣的事情。

以下，是对其的[官方站点](https://github.com/h5bp/html5-boilerplate)的介绍的翻译。

## 简介

HTML5 Boilerplate(样板库)是一个专业的前端模板，可以用来构建快速的，健壮的，适应性强的web app或者站点。

该项目是多年迭代开发的产物，并组合了很多的社区经验。其中并未体现特定的开发哲学或框架，所以你爱咋折腾就咋折腾。

## 特性

* 设置好HTML5. 可以自信的使用新的元素.
* 检查浏览器兼容(Chrome, Firefox, IE8+, Opera, Safari).
* 以渐进增强的方式设计Designed with progressive enhancement in mind.
* 包含了[Normalize.css](http://necolas.github.com/normalize.css/) 以及一些公共bug的消除
* 最新[jQuery](https://jquery.com/)的cdn源
* 用作特定探测的最新[Modernizr](http://modernizr.com/)
* Placeholder样式以及媒体查询
* 有用的css辅助方法
* 默认的优化过的打印css样式
* 避免任何旧浏览器中的`console`引起js错误 
* 优化过的Google分析脚本
* Apache服务器缓存，压缩，以及其他的默认A级性能的默认配置
* "友好删除 ." 可以很容易的剥离不需要的部分.
* 广泛的内联和附赠的文件。

[HTML5 Boilerplate v4提供了遗留浏览器的支持](https://github.com/h5bp/html5-boilerplate/tree/v4) (IE 6+, Firefox
3.6+, Safari 4+), 但不再继续开发了。

## 目录

* [Usage](usage.md) — 项目内容的概述
* [FAQ](faq.md) — 频繁提及的问题及其相关答案

### HTML5 Boilerplate core

* [HTML](html.md) — 默认HTML的指南
* [CSS](css.md) — 默认css的指南
* [JavaScript](js.md) — 默认js的指南
* [Everything else](misc.md) - 其他

### Development

* [扩展和定制HTML5 Boilerplate](extend.md) — 深入研究样板

### Related projects

[H5BP组织](https://github.com/h5bp) 维护了一些与HTML5 Boilerplate互为补充的项目，这些项目可以
帮助你改善web站点/app的不同方面(例如: 性能，安全性等)。

这些项目是:

* [Ant Build Script](https://github.com/h5bp/ant-build-script) — 基于Apache Ant的构建脚本。
* [Server Configs](https://github.com/h5bp/server-configs) — 品种繁多的web服务器配置库

## 使用

Once you have cloned or downloaded HTML5 Boilerplate, creating a site or app
usually involves the following:

下载或克隆HTML5 Boilerplate，然后，按照如下的步骤创建站点或app: 

1. 设置站点的基本结构
2. 添加一些内容，样式和功能
3. 本地运行站点，并进行预览Run your site locally to see how it looks.
4. (可选的，运行构建脚本，从而自动优化站点 - 例如: [ant build script](https://github.com/h5bp/ant-build-script))
5. 部署站点


### 基本结构

基本的HTML5代码库初始化的结构如下: 

```
.
├── css
│   ├── main.css  
│   └── normalize.css  重置浏览器样式
├── doc
├── img
├── js
│   ├── main.js
│   ├── plugins.js
│   └── vendor
│       ├── jquery.min.js
│       └── modernizr.min.js
├── .editorconfig
├── .htaccess
├── 404.html
├── apple-touch-icon.png
├── browserconfig.xml
├── index.html
├── humans.txt
├── robots.txt
├── crossdomain.xml
├── favicon.ico
├── tile-wide.png
└── tile.png
```

下面将逐个的介绍每个主要的部件，以及如何使用这些组件。

**css目录**

包含了项目中所有的css文件。其中包含了一些初始化的css。更多内容，参考下面的css章节。

**doc**

该目录包含了所有HTML5的代码库的文档。可以将其用作为个人项目的文档的位置。

**js**

该目录包含项目中所有的js文件。库，插件，以及定制化的代码都因该放置这里。这里同样包含一些
基础的js文件。更多内容参考js章节。

**.htaccess**

Apache服务器的默认配置。更多信息，参考[Apache Server Configs repository](https://github.com/h5bp/server-configs-apache)。

将站点放置在其他的服务器上，而不是Apache？ 可以在[Server Configs](https://github.com/h5bp/server-configs/blob/master/README.md)
中找到对应的服务器配置。

**404.html**

404辅助页面。备注: 404页面中，样式内联了，这算是一个重最佳实践！！

**browserconfig.xml**

包含了所有关于IE11配置文件。更多关于该话题的讨论，参考[MSDN](http://msdn.microsoft.com/en-us/library/ie/dn455106.aspx).

**.editorconfig**

`.editorconfig`提供并鼓励团队在不同的编辑器和IDE之间，维护一致性的代码风格 [更多阅读并参考misc文件](misc.md#editorconfig).

**index.html**

针对网站所有页面的默认HTML结构。如果使用服务器端模板框架，可将HTML作为起步的布局模板。

在修改目录结构时，确保更新所有引用的css和js的URL。

如果，想要使用Google的通用分析，确保将底部的代码片段，修改为自己的分析ID。

**humans.txt**

编辑该文件，告知团队，其中所使用的技术。

**robots.txt**

编辑该文件，使其包含不想被搜索引擎找到的页面。

**crossdomain.xml**

关于如何处理跨域请求的问题的模板。更多参考misc章节。

**Icons**

将默认的`favicon.ico`, `tile.png`, `tile-wide.png` 以及Apple Touch Icon 替换成自己站点的。

如果针对不同的分辨率使用不同的Apple Touch Icons，可以参考extend章节。


## html 

默认情况下， HTML5 Boilerplate提供两个`html`页面: 

* [`index.html`](#indexhtml) - 默认的HTML骨架，可以用作站点所有页面的基准
* [`404.html`](#404html) -  一个预占位的404错误页面

### `index.html`

**`no-js`类**

`no-js`类基于js是否被禁用，从而更加容易且显式的添加特定的样式。使用该技术，可以帮助[避免FOUC](http://paulirish.com/2009/avoiding-the-fouc-v3/)

> 注: FOUC, 是Flash of unstyled content, 翻译过来，就是未样式化的内容的崩溃。


### 语言属性

通过给`<html>`元素添加`lang`属性，从而考虑为内容指定语言属性。

```html
<html class="no-js" lang="en">
```

**`<title>`和`<meta>`标签的顺序**

`<title>`和`<meta>`标签的顺序非常的重要，这是因为: 

1) 字符集申明(`<meta charset="utf-8">`):

   * 必须完整的包含在文档的[前1024个字节前](https://www.whatwg.org/specs/web-apps/current-work/multipage/semantics.html#charset)
   * 需要尽可能早的指定(在任何可能被攻击者控制的内容之前，比如`<title>`元素)，从而避免IE中潜在的[编码相关的问题](https://code.google.com/p/doctype-mirror/wiki/ArticleUtf7) 

2) 兼容模式meta标签(`<meta http-equiv="X-UA-Compatible" content="IE=edge">`):

   * [需要被包含在除了`<title>`和其他`<meta>`之前的标签](http://msdn.microsoft.com/en-us/library/cc288325.aspx)


**`X-UA-Compatible`**

IE 8/9/10 支持[文档兼容模式](http://msdn.microsoft.com/en-us/library/cc288325.aspx)，该模式影响页面的解释和显示。
由于这个原因，即使站点的访问者使用了IE，但他可能不使用最新的渲染引擎。而且，有可能决定使用IE 5.5的渲染引擎渲染页面。

指定`X-UA-Compatible`的meta标签: 

```html
<meta http-equiv="X-UA-Compatible" content="IE=edge">
```

或者，发送页面时，包含如下的HTTP响应头: 

```
X-UA-Compatible: IE=edge
```

这样，将强迫IE 8/9/10[在大多数情况下](https://hsivonen.fi/doctype/#ie8)以最高可用的模式渲染页面，
从而迫使每个人浏览器页面时，使用浏览器可提供的最佳用户体验。

如果有可能，推荐使用HTTP响应头，而不是`meta`标签。这是因为`meta`标签在站点不是通过标准接口提供时，
IE的`在内部网络中使用兼容模式`选项将会被勾选。

如果，使用Apache作为web服务器，[`.htaccess`](https://github.com/h5bp/server-configs-apache)文件
将接管HTTP头部。如果使用了其他的服务器，参考[其他服务器配置](https://github.com/h5bp/server-configs)。

自从IE11，[文档模式被遗弃了](http://msdn.microsoft.com/en-us/library/ie/bg182625.aspx#docmode)。如果业务
依然依赖为老版本的IE开发设计的web app和服务，可能需要考虑使用[企业模式](http://blogs.msdn.com/b/ie/archive/2014/04/02/stay-up-to-date-with-enterprise-mode-for-internet-explorer-11.aspx)

### Mobile viewport

使用[`viewport`元标签](https://docs.google.com/present/view?id=dkx3qtm_22dxsrgcf4)具有多个不同的选项。更多关于viewport的，
参考[Apple的开发者文档](https://developer.apple.com/library/safari/documentation/AppleApplications/Reference/SafariWebContent/UsingtheViewport/UsingtheViewport.html)。
HTML5 Boilerplate使用了一个相对简单的设置，作为针对理论和使用的较好权衡。

```html
<meta name="viewport" content="width=device-width, initial-scale=1">
```

**Favicons和Touch Icon**

快捷图标可以放置在站点的根目录处。HTML5 Boilerplate自带了一系列默认的图标(包括favicon以及Apple
Touch Icon)，可以以此作为基准，从而创建自己的。

更多细节描述参考扩展章节。

### Modernizr

HTML5 Boilerplate使用了定制化构建的[Modernizr](http://modernizr.com)。

[Modernizr](http://modernizr.com)是一个Javascirpt类库，其基于特性测试的结果给`html`元素添加类，
并通过使用HTML5 Shiv确保所有的浏览器都可以使用HTML5的元素。该类库允许基于浏览器支持的特性，从而
使用特定的css或js。

一般而言，为了保证加载时间最小化，最好在页面结束时调用javascript。这是因为从外部服务器加载
脚本，会导致页面加载阻塞。但是，Modernizr**必须**要在**浏览器开始渲染页面之前**运行，从而，使得缺乏
HTML5元素支持的浏览器可以正常工作。所以，Modernizr的是必须要在文档顶部同步加载的js文件。

> 需要放在文档顶部的原因，其实和HTML5 Shiv有莫大的关系。HTML5的支持也是Shiv的效果。

### polyfills如何？

如果需要在项目中使用[polyfills](https://remysharp.com/2010/10/08/what-is-a-polyfill)，确保其在
其他js加载之前加载。如果使用诸如[cdn.polyfill.io](http://cdn.polyfill.io/)这样的cdn服务，只需要
在页面底部，将polyfill的应用放在其他js之前。

```html
<script src="//cdn.polyfill.io/v1/polyfill.min.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
<script>window.jQuery || document.write('<script src="js/vendor/jquery-1.11.2.min.js"><\/script>')</script>
<script src="js/plugins.js"></script>
<script src="js/main.js"></script>
```

如果，想要包含polyfills，需要在`js/plugins.js`中添加。当你有一打polyfills需要加载时，可在`js/vendor`
创建一个`polyfills.js`，然后在`js/plugins.js`中包含。注意，确保polyfills在其他js之前加载。

关于Modernizr和polyfills，存在一些误解。有一点很重要，Modernizr只处理特性检查，而不提供填充特性(polyfilling)的功能。
Modernizr所做的唯一关于polyfills的是，其团队维护了[跨浏览器的polyfills列表](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills)。

### 内容区域

代码库的模板的主要部分都是空白。这是故意的，为了使得代码库适合web页面和web appd的开发。

**浏览器升级提示**

代码库的主要区域包含了包含了提示IE6/7的用户安装新的浏览器的弹出提示框。如果，你想要支持IE 6/7,
你就需要移除这段代码。

**Google CDN for jQuery**

Google的CDN源在国内不能访问，就不必讨论了。

可以使用如下的工具对站点进行测试: 

* web服务: [WebPageTest](http://www.webpagetest.org/)
* 浏览器工具: [PageSpeed Insights](https://developers.google.com/speed/pagespeed/insights/)和
  [YSlow](https://developer.yahoo.com/yslow/)

注： 在无网络时，可以使用本地jQuery库。

**Google全局分析追踪代码**

Finally, an optimized version of the Google Universal Analytics tracking code is
included. Google recommends that this script be placed at the top of the page.
Factors to consider: if you place this script at the top of the page, you’ll
be able to count users who don’t fully load the page, and you’ll incur the max
number of simultaneous connections of the browser.

Further information:

* [Optimizing the Google Universal Analytics Snippet](https://mathiasbynens.be/notes/async-analytics-snippet#universal-analytics)
* [Introduction to Analytics.js](https://developers.google.com/analytics/devguides/collection/analyticsjs/)
* [Google Analytics Demos & Tools](https://ga-dev-tools.appspot.com/)

**N.B.** The Google Universal Analytics snippet is included by default mainly
because Google Analytics is [currently one of the most popular tracking
solutions](https://trends.builtwith.com/analytics/Google-Analytics) out there.
However, its usage isn't set in stone, and you SHOULD consider exploring the
[alternatives](https://en.wikipedia.org/wiki/List_of_web_analytics_software)
and use whatever suits your needs best!

## css

HTML5 Boilerplate的CSS包含了: 

* [Normalize.css](#normalizecss) - 重置浏览器样式
* [Useful defaults](#useful-defaults) -  有用的默认设置
* [Common helpers](#common-helpers) - 公共辅助方法
* [Placeholder media queries](#media-queries) 媒体查询
* [Print styles](#print-styles) - 打印样式

This starting CSS does not rely on the presence of
[conditional class names](http://www.paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/),
[conditional style sheets](http://css-tricks.com/how-to-create-an-ie-only-stylesheet/),
or [Modernizr](http://modernizr.com/), and it is ready to use no matter what
your development preferences happen to be.


### Normalize.css

In order to make browsers render all elements more consistently and in line
with modern standards, we include
[Normalize.css](https://necolas.github.io/normalize.css/) — a modern, HTML5-ready
alternative to CSS resets.

As opposed to CSS resets, Normalize.css:

* targets only the styles that need normalizing
* preserves useful browser defaults rather than erasing them
* corrects bugs and common browser inconsistencies
* improves usability with subtle improvements
* doesn't clutter the debugging tools
* has better documentation

For more information about Normalize.css, please refer to its [project
page](https://necolas.github.com/normalize.css/), as well as this
[blog post](http://nicolasgallagher.com/about-normalize-css/).


### Useful defaults

Several base styles are included that build upon `Normalize.css`. These
styles:

* provide basic typography settings that improve text readability
* protect against unwanted `text-shadow` during text highlighting
* tweak the default alignment of some elements (e.g.: `img`, `video`,
  `fieldset`, `textarea`)
* style the prompt that is displayed to users using an outdated browser

You are free and even encouraged to modify or add to these base styles as your
project requires.


### Common helpers

Along with the base styles, we also provide some commonly used helper classes.

**`.hidden`**

The `hidden` class can be added to any element that you want to hide visually
and from screen readers. It could be an element that will be populated and
displayed later, or an element you will hide with JavaScript.

**`.visuallyhidden`**

The `visuallyhidden` class can be added to any element that you want to hide
visually, while still have its content accessible to screen readers.

See also:

* [CSS in Action: Invisible Content Just for Screen Reader
  Users](http://www.webaim.org/techniques/css/invisiblecontent/)
* [Hiding content for
  accessibility](http://snook.ca/archives/html_and_css/hiding-content-for-accessibility)
* [HTML5 Boilerplate - Issue #194](https://github.com/h5bp/html5-boilerplate/issues/194/).

**`.invisible`**

The `invisible` class can be added to any element that you want to hide
visually and from screen readers, but without affecting the layout.

As opposed to the `hidden` class that effectively removes the element from the
layout, the `invisible` class will simply make the element invisible while
keeping it in the flow and not affecting the positioning of the surrounding
content.

__N.B.__ Try to stay away from, and don't use the classes specified above for
[keyword stuffing](https://en.wikipedia.org/wiki/Keyword_stuffing) as you will
harm your site's ranking!

**`.clearfix`**

The `clearfix` class can be added to any element to ensure that it always fully
contains its floated children.

Over the years there have been many variants of the clearfix hack, but currently,
we use the [micro clearfix](http://nicolasgallagher.com/micro-clearfix-hack/).


### Media Queries

HTML5 Boilerplate makes it easy for you to get started with a
[_mobile first_](http://www.lukew.com/presos/preso.asp?26) and [_responsive web
design_](http://www.alistapart.com/articles/responsive-web-design/) approach to
development. But it's worth remembering that there are [no silver
bullets](http://www.cloudfour.com/css-media-query-for-mobile-is-fools-gold/).

We include placeholder media queries to help you build up your mobile styles for
wider viewports and high-resolution displays. It's recommended that you adapt
these media queries based on the content of your site rather than mirroring the
fixed dimensions of specific devices.

If you do not want to take the _mobile first_ approach, you can simply edit or
remove these placeholder media queries. One possibility would be to work from
wide viewports down, and use `max-width` media queries instead (e.g.:
`@media only screen and (max-width: 480px)`).

For more features that can help you in your mobile web development, take a look
into our [Mobile Boilerplate](https://github.com/h5bp/mobile-boilerplate).


### Print styles

Lastly, we provide some useful print styles that will optimize the printing
process, as well as make the printed pages easier to read.

At printing time, these styles will:

* strip all background colors, change the font color to black, and remove the
  `text-shadow` — done in order to [help save printer ink and speed up the
  printing process](http://www.sanbeiji.com/archives/953)
* underline and expand links to include the URL — done in order to allow users
  to know where to refer to<br>
  (exceptions to this are: the links that are
  [fragment identifiers](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a#attr-href),
  or use the
  [`javascript:` pseudo protocol](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/void#JavaScript_URIs))
* expand abbreviations to include the full description — done in order to allow
  users to know what the abbreviations stands for
* provide instructions on how browsers should break the content into pages and
  on [orphans/widows](https://en.wikipedia.org/wiki/Widows_and_orphans), namely,
  we instruct
  [supporting browsers](https://en.wikipedia.org/wiki/Comparison_of_layout_engines_%28Cascading_Style_Sheets%29#Grammar_and_rules)
  that they should:

  * ensure the table header (`<thead>`) is [printed on each page spanned by the
    table](http://css-discuss.incutio.com/wiki/Printing_Tables)
  * prevent block quotations, preformatted text, images and table rows from
    being split onto two different pages
  * ensure that headings never appear on a different page than the text they
    are associated with
  * ensure that
    [orphans and widows](https://en.wikipedia.org/wiki/Widows_and_orphans) do
    [not appear on printed pages](http://css-tricks.com/almanac/properties/o/orphans/)

The print styles are included along with the other `css` to [avoid the
additional HTTP request](http://www.phpied.com/delay-loading-your-print-css/).
Also, they should always be included last, so that the other styles can be
overwritten.

## js

Information about the default JavaScript included in the project.

### main.js

This file can be used to contain or reference your site/app JavaScript code.
For larger projects, you can make use of a JavaScript module loader, like
[Require.js](http://requirejs.org/), to load any other scripts you need to
run.

### plugins.js

This file can be used to contain all your plugins, such as jQuery plugins and
other 3rd party scripts.

One approach is to put jQuery plugins inside of a `(function($){ ...
})(jQuery);` closure to make sure they're in the jQuery namespace safety
blanket. Read more about [jQuery plugin
authoring](http://docs.jquery.com/Plugins/Authoring#Getting_Started)

By default the `plugins.js` file contains a small script to avoid `console`
errors in browsers that lack a `console`. The script will make sure that, if
a console method isn't available, that method will have the value of empty
function, thus, preventing the browser from throwing an error.


### vendor

This directory can be used to contain all 3rd party library code.

Minified versions of the latest jQuery and Modernizr libraries are included by
default. You may wish to create your own [custom Modernizr
build](http://www.modernizr.com/download/).

## 其他

* [.gitignore]()
* [.editorconfig]()
* [Server Configuration]()
* [crossdomain.xml]()
* [robots.txt]()
* [browserconfig.xml]()


### `.gitignore`

HTML5 Boilerplate includes a basic project-level `.gitignore`. This should
primarily be used to avoid certain project-level files and directories from
being kept under source control. Different development-environments will
benefit from different collections of ignores.

OS-specific and editor-specific files should be ignored using a "global
ignore" that applies to all repositories on your system.

For example, add the following to your `~/.gitconfig`, where the `.gitignore`
in your HOME directory contains the files and directories you'd like to
globally ignore:

```
[core]
    excludesfile = ~/.gitignore
```

* More on global ignores: https://help.github.com/articles/ignoring-files
* Comprehensive set of ignores on GitHub: https://github.com/github/gitignore


### .editorconfig

The `.editorconfig` file is provided in order to encourage and help you and
your team define and maintain consistent coding styles between different
editors and IDEs.

By default, `.editorconfig` includes some basic
[properties](http://editorconfig.org/#supported-properties) that reflect the
coding styles from the files provided by default, but you can easily change
them to better suit your needs.

In order for your editor/IDE to apply the
[properties](http://editorconfig.org/#supported-properties) from the
`.editorconfig` file, you will need to [install a
plugin]( http://editorconfig.org/#download).

__N.B.__ If you aren't using the server configurations provided by HTML5
Boilerplate, we highly encourage you to configure your server to block
access to `.editorconfig` files, as they can disclose sensitive information!

For more details, please refer to the [EditorConfig
project](http://editorconfig.org/).


### Server Configuration

H5BP includes a [`.htaccess`](#htaccess) file for the Apache HTTP server. If you are not using
Apache as your web server, then you are encouraged to download a
[server configuration](https://github.com/h5bp/server-configs) that corresponds
to your web server and environment.


**Servers and Stacks**

A comprehensive list of web servers and stacks are beyond the scope of this
documentation, but some common ones include:

* [Apache HTTP Server](https://httpd.apache.org/docs/trunk/getting-started.html)
 * [LAMP](https://en.wikipedia.org/wiki/LAMP_%28software_bundle%29)
(Linux, Apache, MySQL, and PHP).
Other variants include [MAMP](https://www.mamp.info/en/index.html),
[WAMP](http://www.wampserver.com/en/),
or [XAMPP](https://www.apachefriends.org/index.html).
 * LAPP uses PostgreSQL instead of MySQL
* [Nginx](http://wiki.nginx.org/GettingStarted)
 * [LEMP](http://www.chrisjohnston.org/ubuntu-tutorials/setting-up-a-lemp-stack-ubuntu-904)
is similar to the LAMP stack but uses Nginx
* [IIS](https://en.wikipedia.org/wiki/Internet_Information_Services)
 * [ASP.NET](http://www.asp.net/get-started)
* [MEAN](http://mean.io/) (MongoDB, Express, AngularJS, Node.js)


**.htaccess**

A `.htaccess` (hypertext access) file is a
[Apache HTTP server configuration file](https://github.com/h5bp/server-configs-apache).
The `.htaccess` file is mostly used for:

* Rewriting URLs
* Controlling cache
* Authentication
* Server-side includes
* Redirects
* Gzipping

If you have access to the main server configuration file (usually called
`httpd.conf`), you should add the logic from the `.htaccess` file in, for
example, a <Directory> section in the main configuration file. This is usually
the recommended way, as using .htaccess files slows down Apache!

To enable Apache modules locally, please see:
https://github.com/h5bp/server-configs-apache/wiki/How-to-enable-Apache-modules.

In the repo the `.htaccess` is used for:

* Allowing cross-origin access to web fonts
* CORS header for images when browsers request it
* Enable `404.html` as 404 error document
* Making the website experience better for IE users better
* Media UTF-8 as character encoding for `text/html` and `text/plain`
* Enabling the rewrite URLs engine
* Forcing or removing the `www.` at the begin of a URL
* It blocks access to directories without a default document
* It blocks access to files that can expose sensitive information.
* It reduces MIME type security risks
* It forces compressing (gzipping)
* It tells the browser whether they should request a specific file from the
  server or whether they should grab it from the browser's cache

When using `.htaccess` we recommend reading all inline comments (the rules after
a `#`) in the file once. There is a bunch of optional stuff in it.

If you want to know more about the `.htaccess` file check out
https://httpd.apache.org/docs/current/howto/htaccess.html.

Notice that the original repo for the `.htaccess` file is [this
one](https://github.com/h5bp/server-configs-apache).


### crossdomain.xml

The _cross-domain policy file_ is an XML document that gives a web client —
such as Adobe Flash Player, Adobe Reader, etc. — permission to handle data
across multiple domains, by:

 * granting read access to data
 * permitting the client to include custom headers in cross-domain requests
 * granting permissions for socket-based connections

__e.g.__ If a client hosts content from a particular source domain and that
content makes requests directed towards a domain other than its own, the remote
domain would need to host a cross-domain policy file in order to grant access
to the source domain and allow the client to continue with the transaction.

For more in-depth information, please see Adobe's [cross-domain policy file
specification](https://www.adobe.com/devnet/articles/crossdomain_policy_file_spec.html).


### robots.txt

The `robots.txt` file is used to give instructions to web robots on what can
be crawled from the website.

By default, the file provided by this project includes the next two lines:

 * `User-agent: *` -  the following rules apply to all web robots
 * `Disallow:` - everything on the website is allowed to be crawled

If you want to disallow certain pages you will need to specify the path in a
`Disallow` directive (e.g.: `Disallow: /path`) or, if you want to disallow
crawling of all content, use `Disallow: /`.

The `/robots.txt` file is not intended for access control, so don't try to
use it as such. Think of it as a "No Entry" sign, rather than a locked door.
URLs disallowed by the `robots.txt` file might still be indexed without being
crawled, and the content from within the `robots.txt` file can be viewed by
anyone, potentially disclosing the location of your private content! So, if
you want to block access to private content, use proper authentication instead.

For more information about `robots.txt`, please see:

  * [robotstxt.org](http://www.robotstxt.org/)
  * [How Google handles the `robots.txt` file](https://developers.google.com/webmasters/control-crawl-index/docs/robots_txt)


### browserconfig.xml

The `browserconfig.xml` file is used to customize the tile displayed when users 
pin your site to the Windows 8.1 start screen. In there you can define custom 
tile colors, custom images or even [live tiles](http://msdn.microsoft.com/en-us/library/ie/dn455106.aspx#CreatingLiveTiles).

By default, the file points to 2 placeholder tile images:

* `tile.png` (558x558px): used for `Small`, `Medium` and `Large` tiles.
  This image resizes automatically when necessary.
* `tile-wide.png` (558x270px): user for `Wide` tiles.

Notice that IE11 uses the same images when adding a site to the `favorites`.

For more in-depth information about the `browserconfig.xml` file, please
see [MSDN](http://msdn.microsoft.com/en-us/library/ie/dn320426%28v=vs.85%29.aspx).

## 后记

发现h5bp好像是相当厉害的开源团队，此外，也发现一些知名的有趣的项目和网站，感觉，干前端还是挺有趣的。
