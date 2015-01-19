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

If you are using Google Universal Analytics, make sure that you edit the
corresponding snippet at the bottom to include your analytics ID.

如果，想要使用Google的通用分析，确保将底部的代码片段，修改为自己的分析ID。

**humans.txt**

编辑该文件，告知团队，其中所使用的技术。

**robots.txt**

编辑该文件，使其包含不想被搜索引擎找到的页面。

**crossdomain.xml**

关于如何处理跨域请求的问题的模板。更多参考misc章节。

**Icons**

Replace the default `favicon.ico`, `tile.png`, `tile-wide.png` and Apple 
Touch Icon with your own.

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


## Language attribute

通过给`<html>`元素添加`lang`属性，从而考虑为内容指定语言属性。

```html
<html class="no-js" lang="en">
```

### The order of the `<title>` and `<meta>` tags

The order in which the `<title>` and the `<meta>` tags are specified is
important because:

`<title>`和`<meta>`标签的顺序非常的重要。

1) the charset declaration (`<meta charset="utf-8">`):

   * must be included completely within the [first 1024 bytes of the
     document](https://www.whatwg.org/specs/web-apps/current-work/multipage/semantics.html#charset)

   * should be specified as early as possible (before any content that could
     be controlled by an attacker, such as a `<title>` element) in order to
     avoid a potential [encoding-related security
     issue](https://code.google.com/p/doctype-mirror/wiki/ArticleUtf7) in
     Internet Explorer

2) the meta tag for compatibility mode
   (`<meta http-equiv="X-UA-Compatible" content="IE=edge">`):

   * [needs to be included before all other tags except for the `<title>` and
     the other `<meta>`
     tags](http://msdn.microsoft.com/en-us/library/cc288325.aspx)


### `X-UA-Compatible`

Internet Explorer 8/9/10 support [document compatibility
modes](http://msdn.microsoft.com/en-us/library/cc288325.aspx) that affect the
way webpages are interpreted and displayed. Because of this, even if your site's
visitor is using, let's say, Internet Explorer 9, it's possible that IE will not
use the latest rendering engine, and instead, decide to render your page using
the Internet Explorer 5.5 rendering engine.

Specifying the `X-UA-Compatible` meta tag:

```html
<meta http-equiv="X-UA-Compatible" content="IE=edge">
```

or sending the page with the following HTTP response header

```
X-UA-Compatible: IE=edge
```

will force Internet Explorer 8/9/10 to render the webpage in the highest
available mode in [the various cases when it may
not](https://hsivonen.fi/doctype/#ie8), and therefore, ensure that anyone
browsing your site is treated to the best possible user experience that
browser can offer.

If possible, we recommend that you remove the `meta` tag and send only the
HTTP response header as the `meta` tag will not always work if your site is
served on a non-standard port, as Internet Explorer's preference option
`Display intranet sites in Compatibility View` is checked by default.

If you are using Apache as your webserver, including the
[`.htaccess`](https://github.com/h5bp/server-configs-apache) file takes care of
the HTTP header. If you are using a different server, check out our [other
server config](https://github.com/h5bp/server-configs).

Starting with Internet Explorer 11, [document modes are
deprecated](http://msdn.microsoft.com/en-us/library/ie/bg182625.aspx#docmode).
If your business still relies on older web apps and services that were
designed for older versions of Internet Explorer, you might want to consider
enabling [Enterprise Mode](http://blogs.msdn.com/b/ie/archive/2014/04/02/stay-up-to-date-with-enterprise-mode-for-internet-explorer-11.aspx) throughout your company.


## Mobile viewport

There are a few different options that you can use with the [`viewport` meta
tag](https://docs.google.com/present/view?id=dkx3qtm_22dxsrgcf4 "Viewport and
Media Queries - The Complete Idiot's Guide"). You can find out more in [the
Apple developer docs](https://developer.apple.com/library/safari/documentation/AppleApplications/Reference/SafariWebContent/UsingtheViewport/UsingtheViewport.html).
HTML5 Boilerplate comes with a simple setup that strikes a good balance for general use cases.

```html
<meta name="viewport" content="width=device-width, initial-scale=1">
```

## Favicons and Touch Icon

The shortcut icons should be put in the root directory of your site. HTML5
Boilerplate comes with a default set of icons (include favicon and one Apple
Touch Icon) that you can use as a baseline to create your own.

Please refer to the more detailed description in the [Extend section](extend.md)
of these docs.

## Modernizr

HTML5 Boilerplate uses a custom build of Modernizr.

[Modernizr](http://modernizr.com) is a JavaScript library which adds classes to
the `html` element based on the results of feature test and which ensures that
all browsers can make use of HTML5 elements (as it includes the HTML5 Shiv).
This allows you to target parts of your CSS and JavaScript based on the
features supported by a browser.

In general, in order to keep page load times to a minimum, it's best to call
any JavaScript at the end of the page because if a script is slow to load
from an external server it may cause the whole page to hang. That said, the
Modernizr script *needs* to run *before* the browser begins rendering the page,
so that browsers lacking support for some of the new HTML5 elements are able to
handle them properly. Therefore the Modernizr script is the only JavaScript
file synchronously loaded at the top of the document.

## What about polyfills?

If you need to include [polyfills](https://remysharp.com/2010/10/08/what-is-a-polyfill)
in your project, you must make sure those load before any other JavaScript. If you're
using some polyfill CDN service, like [cdn.polyfill.io](http://cdn.polyfill.io/),
just put it before the other scripts in the bottom of the page:

```html
    <script src="//cdn.polyfill.io/v1/polyfill.min.js"></script>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
    <script>window.jQuery || document.write('<script src="js/vendor/jquery-1.11.2.min.js"><\/script>')</script>
    <script src="js/plugins.js"></script>
    <script src="js/main.js"></script>
</body>
```

If you like to just include the polyfills yourself, you could include them in
`js/plugins.js`. When you have a bunch of polyfills to load in, you could
also create a `polyfills.js` file in the `js/vendor` directory. Also using
this technique, make sure the polyfills are all loaded before any other
Javascript.

There are some misconceptions about Modernizr and polyfills. It's important
to understand that Modernizr just handles feature checking, not polyfilling
itself. The only thing Modernizr does regarding polyfills is that the team
maintains [a huge list of cross Browser polyfills](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills).

## The content area

The central part of the boilerplate template is pretty much empty. This is
intentional, in order to make the boilerplate suitable for both web page and
web app development.

### Browser Upgrade Prompt

The main content area of the boilerplate includes a prompt to install an up to
date browser for users of IE 6/7. If you intended to support IE 6/7, then you
should remove the snippet of code.

### Google CDN for jQuery

The Google CDN version of the jQuery JavaScript library is referenced towards
the bottom of the page using a protocol-independent path (read more about this
in the [FAQ](faq.md)). A local fallback of jQuery is included for rare instances
when the CDN version might not be available, and to facilitate offline
development.

The Google CDN version is chosen over other [potential candidates (like the
jQuery CDN](https://jquery.com/download/#using-jquery-with-a-cdn)) because
it's fast in absolute terms and it has the best overall
[penetration](http://httparchive.org/trends.php#perGlibs) which increases the
odds of having a copy of the library in your user's browser cache.

While the Google CDN is a strong default solution your site or application may
require a different configuration. Testing your site with services like
[WebPageTest](http://www.webpagetest.org/) and browser tools like
[PageSpeed Insights](https://developers.google.com/speed/pagespeed/insights/) or
[YSlow](https://developer.yahoo.com/yslow/) will help you examine the real
world performance of your site and can show where you can optimize your specific
site or application.


### Google Universal Analytics Tracking Code

Finally, an optimized version of the Google Universal Analytics tracking code is
included. Google recommends that this script be placed at the top of the page.
Factors to consider: if you place this script at the top of the page, you’ll
be able to count users who don’t fully load the page, and you’ll incur the max
number of simultaneous connections of the browser.

Further information:

* [Optimizing the Google Universal Analytics
  Snippet](https://mathiasbynens.be/notes/async-analytics-snippet#universal-analytics)
* [Introduction to
  Analytics.js](https://developers.google.com/analytics/devguides/collection/analyticsjs/)
* [Google Analytics Demos & Tools](https://ga-dev-tools.appspot.com/)

**N.B.** The Google Universal Analytics snippet is included by default mainly
because Google Analytics is [currently one of the most popular tracking
solutions](https://trends.builtwith.com/analytics/Google-Analytics) out there.
However, its usage isn't set in stone, and you SHOULD consider exploring the
[alternatives](https://en.wikipedia.org/wiki/List_of_web_analytics_software)
and use whatever suits your needs best!

## css
HTML5 Boilerplate's CSS includes:

* [Normalize.css](#normalizecss)
* [Useful defaults](#useful-defaults)
* [Common helpers](#common-helpers)
* [Placeholder media queries](#media-queries)
* [Print styles](#print-styles)

This starting CSS does not rely on the presence of
[conditional class names](http://www.paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/),
[conditional style sheets](http://css-tricks.com/how-to-create-an-ie-only-stylesheet/),
or [Modernizr](http://modernizr.com/), and it is ready to use no matter what
your development preferences happen to be.


## Normalize.css

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


## Useful defaults

Several base styles are included that build upon `Normalize.css`. These
styles:

* provide basic typography settings that improve text readability
* protect against unwanted `text-shadow` during text highlighting
* tweak the default alignment of some elements (e.g.: `img`, `video`,
  `fieldset`, `textarea`)
* style the prompt that is displayed to users using an outdated browser

You are free and even encouraged to modify or add to these base styles as your
project requires.


## Common helpers

Along with the base styles, we also provide some commonly used helper classes.

#### `.hidden`

The `hidden` class can be added to any element that you want to hide visually
and from screen readers. It could be an element that will be populated and
displayed later, or an element you will hide with JavaScript.

#### `.visuallyhidden`

The `visuallyhidden` class can be added to any element that you want to hide
visually, while still have its content accessible to screen readers.

See also:

* [CSS in Action: Invisible Content Just for Screen Reader
  Users](http://www.webaim.org/techniques/css/invisiblecontent/)
* [Hiding content for
  accessibility](http://snook.ca/archives/html_and_css/hiding-content-for-accessibility)
* [HTML5 Boilerplate - Issue #194](https://github.com/h5bp/html5-boilerplate/issues/194/).

#### `.invisible`

The `invisible` class can be added to any element that you want to hide
visually and from screen readers, but without affecting the layout.

As opposed to the `hidden` class that effectively removes the element from the
layout, the `invisible` class will simply make the element invisible while
keeping it in the flow and not affecting the positioning of the surrounding
content.

__N.B.__ Try to stay away from, and don't use the classes specified above for
[keyword stuffing](https://en.wikipedia.org/wiki/Keyword_stuffing) as you will
harm your site's ranking!

#### `.clearfix`

The `clearfix` class can be added to any element to ensure that it always fully
contains its floated children.

Over the years there have been many variants of the clearfix hack, but currently,
we use the [micro clearfix](http://nicolasgallagher.com/micro-clearfix-hack/).


## Media Queries

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


## Print styles

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

## main.js

This file can be used to contain or reference your site/app JavaScript code.
For larger projects, you can make use of a JavaScript module loader, like
[Require.js](http://requirejs.org/), to load any other scripts you need to
run.

## plugins.js

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


## vendor

This directory can be used to contain all 3rd party library code.

Minified versions of the latest jQuery and Modernizr libraries are included by
default. You may wish to create your own [custom Modernizr
build](http://www.modernizr.com/download/).

## 其他

* [.gitignore](#gitignore)
* [.editorconfig](#editorconfig)
* [Server Configuration](#server-configuration)
* [crossdomain.xml](#crossdomainxml)
* [robots.txt](#robotstxt)
* [browserconfig.xml](#browserconfigxml)

--

## .gitignore

HTML5 Boilerplate includes a basic project-level `.gitignore`. This should
primarily be used to avoid certain project-level files and directories from
being kept under source control. Different development-environments will
benefit from different collections of ignores.

OS-specific and editor-specific files should be ignored using a "global
ignore" that applies to all repositories on your system.

For example, add the following to your `~/.gitconfig`, where the `.gitignore`
in your HOME directory contains the files and directories you'd like to
globally ignore:

```gitignore
[core]
    excludesfile = ~/.gitignore
```

* More on global ignores: https://help.github.com/articles/ignoring-files
* Comprehensive set of ignores on GitHub: https://github.com/github/gitignore


## .editorconfig

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


## Server Configuration

H5BP includes a [`.htaccess`](#htaccess) file for the Apache HTTP server. If you are not using
Apache as your web server, then you are encouraged to download a
[server configuration](https://github.com/h5bp/server-configs) that corresponds
to your web server and environment.


### Servers and Stacks

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


### .htaccess

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


## crossdomain.xml

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


## robots.txt

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


## browserconfig.xml

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

发现h5bp好像是相当厉害的开源团队。
