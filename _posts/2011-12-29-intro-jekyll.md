---
layout: post
category : note
tagline: "Supporting tagline"
tags : [intro, beginner, jekyll, tutorial]
---
{% include JB/setup %}

本指南介绍什么是Jekyll以及如何使用，深入阅读将了解Jekyll的工作原理。

## Overview

### What is Jekyll?

Jekyll是封装为ruby的gem的解析引擎，用来从诸如模板，部分视图，liquid代码，markdown的。Jekyll是"a simple, blog aware, static site generator"。

Jekyll是一个前端开发框架。

### Examples

This website is created with Jekyll. [Other Jekyll websites](https://github.com/mojombo/jekyll/wiki/Sites).

### What does Jekyll Do?

Jekyll作为Ruby gem安装在本地系统中(这意味着需要安装ruby和rubygems)。只要在某个目录中提供jekyll期望的目录结构，然后运行`jekyll --server`，jekyll
将会解析markdown/textile文件，计算目录，tags，永久链接，然后，从布局模板和部分视图中构建页面。

一旦解析完成，Jekyll将结果存放在自包含的静态`_site`目录中， 这意味着，可以将`_site`目录下的内容作为静态web服务器的内容。

简单来说，Jekyll一次将内容，模板，tag生成静态缓存(HTML)，然后用作静态文件服务。

### Jekyll is Not Blogging Software

**Jekyll是解析引擎**

Jekyll不包含任何内容，模板或设计元素。刚起步时，很容易迷惑，因为Jekyll不提供任何在网站上得到的东西，你得自己动手去创建。

### Why Should I Care?

Jekyll迷你且高效。最重要的事情是: Jekyll创建站点的静态表现，从而仅需静态web服务器。传统的动态博客，比如Wordpress，需要数据库和服务器端代码。
大流量的动态博客必须部署缓存层，从而提供静态内容的服务，这就同Jekyll做的差不错了。

所以，如果想保持简单，且钟爱命令行而不是管理界面UI，尝试一下Jekyll。


**像写代码一样写内容**

- 用你最爱的编辑器写markdown或textile，比如，vim
- 本地预览写作内容
- 无需网络链接
- git推送
- 只需静态服务器
- 可免费搭建在GitHub Pages.
- 无需数据库

**注**: 突然想起，将静态资源全用缓存的话，没网时，就不能进行本地测试。当然，没网也不能提交，网都没了，还玩个妹啊！！


## How Jekyll Works

以下是Jekyll完善且简洁的概述，介绍了Jekyll如何工作的。本指南并不面面俱到，而是尝试给出一个关于Jekyll的全景式的认识。

学习这些核心概念将帮助你避免挫折，最终帮助你理解`Jekyll-Bootstrap`中的代码样例。

## Initial Setup

在安装Jekyll之后，使用命令`jekyll new xxxx`创建新的jekyll项目。`Jekyll-bootstrap`则默认提供这样的目录格式。

### The Jekyll Application Base Format

Jekyll期望的网站目录格式如下:

    .
    |-- _config.yml
    |-- _includes
    |-- _layouts
    |   |-- default.html
    |   |-- post.html
    |-- _posts
    |   |-- 2011-10-25-open-source-is-good.markdown
    |   |-- 2011-04-26-hello-world.markdown
    |-- _site
    |-- index.html
    |-- assets
        |-- css
            |-- style.css
        |-- javascripts


- **\_config.yml**
	 存放配置数据

- **\_includes**
	部分视图所在的目录

- **\_layouts** 
  该目录是内容插入其中的主要模板，可以为不同的页面或页面区域设定不同的模板。

- **\_posts**
	该目录包含动态内容/post，其命名格式必须是`@YEAR-MONTH-DATE-title.MARKUP@`

- **\_site**
	This is where the generated site will be placed once Jekyll is done transforming it.
  Jekyll存放转换后的站点文件的目录。

- **assets**
  该目录并不属于标准的jekyll结构。assets目录表示任何在根目录创建的目录。目录和文件并不会被Jekyll格式化
  也不能被访问。

(更多参考: <https://github.com/mojombo/jekyll/wiki/Usage>)

### Jekyll Configuration

Jekyll支持很多配置选项，全部列出如下:
(<https://github.com/mojombo/jekyll/wiki/Configuration>)

## Content in Jekyll

Jekyll中的内容可以是post或这page。内容对象可以插到一个或多个模板中，从而构建最终输出的静态页面。

### Posts and Pages

所有的posts和pages都因该以markdown，textile或HTML编写，并且其中包含Liquid模板语法。posts和pages都因该具备标题、url路径以及定制化的元数据等页面的基本属性。

### Working With Posts

**Creating a Post**
Posts以恰当的格式创建，并放置在`_posts`目录下。

**Formatting**
post必须具备有效的文件名格式(`YEAR-MONTH-DATE-title.MARKUP`)，并放置在`_posts`目录下。如果名字不合法，就不会被看作post。标题和日期会自动从post文件名中解析出。
此外，每个文件必须具备[YAML Front-Matter](https://github.com/mojombo/jekyll/wiki/YAML-Front-Matter) 。YAML Front-Matter是通过YAML语法指定给定文件的元数据。

**Order**
定序是Jekyll中重要的部分，但其策略很难指定。Jekyll仅支持正年代顺序和逆年代顺序。

由于日期是直接硬编码到文件中，为了改变顺序，需要修改文件名的日期。

**Tags**
Posts can have tags associated with them as part of their meta-data.
Tags may be placed on posts by providing them in the post's YAML front matter(扉页).
You have access to the post-specific tags in the templates. These tags also get added to the sitewide collection.

**Categories**
Posts may be categorized by providing one or more categories in the YAML front matter.
Categories offer more significance over tags in that they can be reflected in the URL path to the given post.
Note categories in Jekyll work in a specific way.
If you define more than one category you are defining a category hierarchy "set".
Example:

    ---
    title :  Hello World
    categories : [lessons, beginner]
    ---

This defines the category hierarchy "lessons/beginner". Note this is _one category_ node in Jekyll.
You won't find "lessons" and "beginner" as two separate categories unless you define them elsewhere as singular categories.

### Working With Pages

**Creating a Page**
Pages are created by properly formatting a file and placing it anywhere in the root directory or subdirectories that do _not_ start with an underscore.

**Formatting**
In order to register as a Jekyll page the file must contain [YAML Front-Matter](https://github.com/mojombo/jekyll/wiki/YAML-Front-Matter).
Registering a page means 1) that Jekyll will process the page and 2) that the page object will be available in the `site.pages` array for inclusion into your templates.

**Categories and Tags**
Pages do not compute categories nor tags so defining them will have no effect.

**Sub-Directories**
If pages are defined in sub-directories, the path to the page will be reflected in the url.
Example:

    .
    |-- people
        |-- bob
            |-- essay.html

This page will be available at `http://yourdomain.com/people/bob/essay.html`


**Recommended Pages**

- **index.html**
  You will always want to define the root index.html page as this will display on your root URL.
- **404.html**
  Create a root 404.html page and GitHub Pages will serve it as your 404 response.
- **sitemap.html**
  Generating a sitemap is good practice for SEO. 备注: sitemap.txt中记录了站点中，所有可访问URL。
- **about.html**
  A nice about page is easy to do and gives the human perspective to your website.


## Templates in Jekyll

模板是用来包含page或post内容的。所有的模板都可以通过全局站点对象变量和页面对象访问: `site`以及`page`。
站点变量(`site`)存放这所有与站点相关的、可访问的内容和元数据。
页面变量(`page`)存放着给定页面访问的数据或者post所渲染的位置。

**Create a Template**
模板以特定格式创建，并存放在`_layouts`目录中。

**Formatting**
模板以HTML编码且包含YAML Front Matter。所有的模板都包含带有站点数据的Liquid代码。

**Rending Page/Post Content in a Template**
模板中存在一个特殊的变量: `content`。`content`变量中包含 page/post内容，以及先前定义的子模板内容。无论在渲染内容变量，
都需要将内容注入到模板中：

{% capture text %}...
<body>
  <div id="sidebar"> ... </div>
  <div id="main">
    |.{content}.|
  </div>
</body>
...{% endcapture %}
{% include JB/liquid_raw %}

注: 这里使用`capture`捕获变量。 

### Sub-Templates

Sub-templates are exactly templates with the only difference being they
define another "root" layout/template within their YAML Front Matter.
This essentially means a template will render inside of another template.

子模板是和模板的唯一的区别在于，他们定义在另一个根目录下。这意味着，一个模板可以另一个模板内渲染。

### Includes

Jekyll中在`_includes`目录中，定义include文件。Includes并不是模板，而仅仅只是包含在模板中代码片段。
这些代码片段可以看作部分视图。includes中可以包含任何有效的模板代码。

## Using Liquid for Templating

模板是Jekyll中最令人迷惑且沮丧的部分。这部分是由于Jekyll模板必须是用Liquid模板语言。

### What is Liquid?

[Liquid](https://github.com/Shopify/liquid) 是由[Shopify](http://shopify.com)开发的安全的模板语言。Liquid作为一门终端用户使用的，带逻辑且对服务器无风险的模板语言。

Jekyll使用Liquid生成带有页面布局结构以及站点元数据的post页面。

### Why Do We Have to Use Liquid?

GitHub使用Jekyll提供[GitHub Pages](http://pages.github.com/). 
GitHub 不能承受在其服务器上运行任意代码，所以，他们通过Liquid限制开发者。

### Liquid is Not Programmer-Friendly.

liquid本身并不是真整的代码，其不能执行真正的代码。这意味着，只能访问已经明确传递给模板的数据结构，不能对其进行hack。

GitHub Pagesd提供的Jekyll环境中，不能修改和运行定制插件。

作为程序员而言，这令人沮丧。

但是不要吹毛求疵，正确看待Jekyll提供的限制，并调整客户端解决方案。

**旁白**
不建议hack liquid。如果想要运行定制化插件的能力，最好坚持使用ruby。此外，可以使用[Mustache-with-Jekyll](http://github.com/plusjade/mustache-with-jekyll)

## Static Assets

静态资源可以在根目录下的任何文件，或不以`_`开头的目录。总之，不会被看著Jekyll Pages。静态资源可以是图片，css，js文件。

## How Jekyll Parses Files

Jekyll是一个解析引擎，主要解析lianghzong类型的文件：

- **Content parsing.** markdown或者textile
- **Template parsing.** liquid模板语言解析

存在两种主要类型的文件格式需要解析: 

- **Post and Page files.**
  All content in Jekyll is either a post or a page so valid posts and pages are parsed with markdown or textile.
- **Template files.**
	These files go in `_layouts` folder and contain your blogs **templates**. They should be made in HTML with the help of Liquid syntax.
	Since include files are simply injected into templates they are essentially parsed as if they were native to the template.

**Arbitrary files and folders.**
不是有效的页面的文件将被看作静态内容，Jekyll不对其进行处理。

### Formatting Files for Parsing.

We've outlined the need for valid formatting using **YAML Front Matter**.
模板，post以及pagas都需要提供有效的YAML Front Matter，即使Matter为空。这是Jekyll知道如果处理文件的唯一方法。

YAML Front Matter必须放置在template/post/page文件的顶部：

    ---
    layout: post
    category : pages
    tags : [how-to, jekyll]
    ---

    ... contents ...

YAML Front-Matter包裹在三个连字符的新行之间。预定义的配置选项有: layout, permalink, published, category, categories, tags。更多内容参考: <http://jekyllrb.com/docs/frontmatter/>

#### Defining Layouts for Posts and Templates Parsing.

The `layout` parameter in the YAML Front Matter defines the template file for which the given post or template should be injected into.
If a template file specifies its own layout, it is effectively being used as a `sub-template.`
That is to say loading a post file into a template file that refers to another template file with work in the way you'd expect; as a nested sub-template.

YAML Front Matter中的`layout`参数定义给定的post或模板应该插入的模板。如果，模板文件中指定了布局，则其称为子模板。嵌套子模板。

## How Jekyll Generates the Final Static Files.

Jekyll的任务是生成站点的静态表示。以下，是Jekyll的处理的步骤: 

1. **Jekyll collects data.**
  Jekyll扫描posts目录，并将post文件收集为post对象，然后扫描并收集布局资源，最后，从扫描其他目录查找pages。

2. **Jekyll computes data.**
  Jekyll接受这些对象，并计算其中的元数据(permalinks, tags, categories, titles, dates)，然后构建一个巨大的`site`对象。该对象包含所有的posts, pages, 布局以及对应的元数据。
  此时，站点就是一个巨大的ruby对象。

3. **Jekyll liquifies posts and templates.**
  下一步，Jekyll循环每个post文件(markdown或者textile)，转换并**liquifies**post中的表示的布局。一旦post被解析并揉合到恰当的布局结构中，布局自生也将被liquified。**Liquification**的定义如下:
  Jekyll初始化一个Liquid模板，然后传递站点对象的简单hash表示以及post的对象的hash表示。这些简化的数据就是可在模板中访问的数据结构。

3. **Jekyll generates output.**
  最后，liquid模板被渲染， 随后解析模板中出现的liquid语法，并将其保存为最终的、静态的文件表示。

**Notes.**
因为，Jekyll在一次计算整个站点对象，每个模板都可以访问`site` hash中的数据。这些数据用来遍历、格式化并最终渲染到给定的页面中。

Remember, in Jekyll you are an end-user. Your API has only two components:
记住，Jekyll将你看作终端用户，可用的API只有两个：

1. 设置的目录关系
2. liquid语法以及传递给liquid模板的变量

所有模板中可用的数据对象都列在JB的**API Section**中，可从这里看到原始的文档: <http://jekyllrb.com/docs/variables》


## Conclusion

但愿读者看明白了Jekyll到底干了啥。注意，主要的编程约束是：仅仅只能通过Liquid，Liquid的限制挺大的。

Jekyll-bootstrap提供辅助方法和策略，从而使其更具交互且更易操作=)

花了，好几天的时间看完，还是不知道如何设置我想要的部分视图。我想要的就是，将js放置到HTML的body的底部时，还能正确的处理js之间的依赖关系，以及响应的js能够执行。
看来，这么简单的事情都很难做到，在liquid中果然很难处理。
