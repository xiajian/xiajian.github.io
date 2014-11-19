---
layout: post
title: Scaling Rails Site
category: rails
---

## 前言

本文打算将[XDite](http://wp.xdite.net)博客上关于Scaling Rails Site相关的摘录过来。恰好，近来研究Web性能相关的内容，看看XDite怎么看待Rails站点性能的。

原文地址: <http://wp.xdite.net/?cat=91>

## 正文 

目前，市面上没有专门介绍Scaling Rails Application, 但是，关于这个话题，可以讨论的东西很多。

性能优化的大体方向如下: 

1. Rails performance
2. Front-end web performance(Javascript和css)
3. Caching & HTTP Reverse Proxy Caching
4. Asynchrony Processing (Message queue)
5. Partition Component using SOA
6. Distributed Filesystem / Database , Database Optimization, NoSQL

## 1. Rails (Application) performance

Rails 这个框架本身的 Performance 并不在这个议题讨论之内。原因是 Rails 本身的 req/s 已经在 framework 界的表现算是不错，还干掉一堆 PHP framework，而且对于 Rails 本身的表现，很多时候 Application 纯开发者是没有什么作为能力的。Tuning 的原则建立在于认定 Rails 能够有一定的效率表现，因此，优化著重于避免设计出烂架构、写出烂 code 造成效率低落，以较为良好的架构设计达到避免将压力加诸于 Rails 身上的目标。

* 换掉 Ruby 实现

如果要提升 Rails framework 的速度，换掉 Ruby VM 是最快的。但如果还是希望使用纯 C 写的 Ruby (gem compatible 问题)，可考虑使用 [Ruby Enterprise Edition (REE)](http://www.rubyenterpriseedition.com/)。光换成 REE，内存用量马上就少上 1/3，而速度也快上 1/3。

关于 REE 能够做到这件事的原理，已经写在 [FAQ](http://www.rubyenterpriseedition.com/faq.html) 里，而REE的实现者在 2009 年底也在 Google Tech Talk 上给了一场相关的 talk。其原理简单来说就是：利用了Unix进程的Copy on write技术。

[关键字: Ruby VM ]

* 抓出 slow action / slow ruby code，并针对这些部分改善

slow action / slow ruby code可以通过[NewRelic RPM](www.newrelic.com)来查找。

很多时候，Rails Application 的缓慢，并不是 Rails 这个 framework 产生的问题。而是开发者 *完全* 不熟 Rails API 或者是 Ruby 这个语言 本身，或者是滥用 Rails 而写出烂架构所造成的问题。常见的情形有以下几种状况：

- **不熟 Ruby**。可以用 Ruby 本身提供的 method 一行就解决的事情，自己写了回圈处理，造成了 object 大量的被 clone 出来浪费记忆体。

> 解法：阅读 [Writing Efficient Ruby Code](http://ihower.tw/blog/archives/1691)，以及阅读 [The Well-Grounded Rubyist](http://www.manning.com/black2/)（ Ruby for Rails 的新版）、[Refactoring: Ruby Edition](http://www.informit.com/store/product.aspx?isbn=0321604180)

- **不熟 Rails API**。比如说：不熟 ActiveRecord，导致一个简单 action，就产生了极大量的 query。或者是不懂做 counter cache，造成了 database 极大的压力；大量使用 render :partial，却不知道 render :partial 是极其昂贵的，应该把常用的 partial cache 住。

> 解法：阅读 [Advanced ActiveRecord](http://peepcode.com/products/advanced-activerecord) 、[Advanced Active Record Techniques: Best Practice Refactoring](http://en.oreilly.com/rails2008/public/schedule/detail/2032)、[That’s Not a Memory Leak, It’s Bloat](http://www.engineyard.com/blog/2009/thats-not-a-memory-leak-its-bloat/)、[Rails Code Review](http://peepcode.com/products/rails-code-review-pdf)、[Railsrescue Handbook](http://www.railsrescuebook.com/toc)

- **plugin 的问题**。plugin 作者并不是全知全能，他们开发 plugin 只是为了顺手解决自己手边遇到的问题。你安装的 plugin 若是热门 plugin，效能上应该可能没什么问题，因为大多已经在许多人在生产环境中实践过，出现的问题也几乎被解决掉了。但若是比较冷门或比较新的，可能这个 plugin 就是造成你 performance 低落的元凶。

- **特殊 action 造成的效能低落**。在 Rails Application 上，有一个常见功能是开发者的痛，就是上传档案的问题。上传档案这个行为，常常会造成阻塞整个站的现象。而 Merb(Ruby web框架，已和Rails合并)，当初就是设计来解决 Upload File 的问题的。很痛的还有寄信的这个功能，Rails 的 AR Mailer 真的颇废 :/ ，它原始的设计初衷是要让开发者在 Framework 轻松写出寄信功能之用的，不过总会有天兵开发者会写出在 action 里一次寄一千封这种会死人的事….

> 解法：将效率低落的 action，诸如 upload 功能。利用 [Metal](http://railscasts.com/episodes/150-rails-metal) 的机制，bypass 到其他 framework 或者是直接用 [Rack middleware](http://blog.xdite.net/?p=1557) 做掉。如果你的 Web Server 最前面是 Nginx 的话，有人写了一个十分有用的[upload module](brainspl.at/articles/2008/07/20/nginx-upload-module)，解决了这个问题。至于寄信或者需要耗费大量资源的 action（如截图、缩图、缩影片），应该用 queue + worker 加上 第三方服务(3rd party service) 做掉。比如说寄信的方式，我就会推荐用 [Delayed Job](http://github.com/tobi/delayed_job) + [Madmimi gem](http://developer.madmimi.com/) 解决。网站截图就直接丢 [bluega](http://webthumb.bluga.net/home) 处理。

- **API 不应该直接使用 Rails 实现**。API 通常多属于逻辑简单但 Request 数量又很大的行为，request 打进 Rails 本身就会造成一定量的负担。这部分的实作部分也建议 bypass 到其他 framework 、直接用 Rack middleware 做掉，或干脆切出去用其他语言/架构 implement。

> 关于API的实现，前一段时间接触了一下。可以考虑使用[Grape gem](https://github.com/intridea/grape)然后配合[Sinatra](https://github.com/sinatra/sinatra)实现，当然，也可以直接在Rails中使用Grape。

至于更多 profiling memory usage 以及 measure code efficiency 的工具，[ihower](http://ihower.tw/) 将在 [Ruby Tuesday #10](http://ihower.tw/blog/archives/3890) 讲到，这方面就交给他了，它的主题是 [Rails Performance](http://www.slideshare.net/ihower/rails-performance)。

更多关于Rails性能方面的可以参考[Wen-Tien Chang](http://www.slideshare.net/ihower)的演示文稿。

**备注**: Ruby Tuesday是Ruby台湾社区的聚会活动。[slideshare](http://www.slideshare.net)是一个PPT上传共享的网站，国内访问速度不佳，但是，从个人体会的角度来看，感觉好想很多人在用，而且是以网页片段的方式。一段跨域请求的js，插入页面的div，具体例子有Github，Disqus。Slideshare等。

## 2. Front-end web performance

一般来说，在测量用网页开一张网页需要多少时间时，其实会发现瓶颈大多是落于 loading 页面上所需要的 data，而非 Server 产生页面的速度上。开一张网页，loading 页面所需要的东西要花 3 秒，可是 loading 页面本身只需要 0.2 秒，加起来需要 3.2 秒。tune Rails Application tune 了老半天，才将 0.2 秒降低成 0.1 秒。但是针对 Client Side 部分随便 Tuning 一下，本来需要 3 秒可能马上降到 1 秒不到。所以有时候先 Tune 这部分反而是比较合算的。

而使用 [YSlow](http://yslow.org/) 这个工具，基本上就能帮忙检测出很多网站上的问题和给出实际的建议。Firefox中有YSlow的相关插件，配合FireBug使用，效果更佳。

阅读[Best Practices for Speeding Up Your Web Site](/web/2014/11/16/Best Practices for Speeding Up Your Web Site/)

以下是XDite基于 YSlow ，能利用 Rails 本身或网路上已有的工具 / 技术给出的实现建议：

### **Minimize HTTP Requests**

过多的 http request 是 loading page 效率低落的主要原因之一，造成这种问题的原因多半出自于打开页面需要下载的静态档案太多(css 和 js 太多支、css 里用到的 images 太多张)

**解法**：

在一般网站架构的情形，可用 [YUI Compressor](http://developer.yahoo.com/yui/compressor/) 做到打包多支 css / js 成一支档案的目标，减少 http request，但是每次在 production 的现实操作中，deploy code 都要手动做一次，忘了做就会有灾难发生，一般的解法可能是利用 [vim 的 script 做到编辑完自动打包](http://blog.othree.net/log/2009/09/08/vim-js-yuicompressor/) 。而在 rails 里，helper 可以帮你自动做到打包的动作。

```erb
<%= javascript_include_tag , "product", "cart" ,"chckecout" , :cache => "shop" %>
<%= stylesheet_link_tag :all , :cache => true %>
```

### **Optimize CSS Sprites**

 CSS Sprites，是一种技巧，将原本很多张的小图合并成一张图，再利用 CSS 定位切割，用来解决 css 里 images 太多张的问题。网路上搜寻 auto css sprite 就有一大堆相关的工具。不过这里要特别讲一个最近才新出的 Ruby Gem：[Auto Sprite](http://github.com/sblackstone/auto_sprite)，可搭配 Rails 自动处理这件事 .. 

### **Use a Content Delivery Network** , **Split Components Across Domains**

Serve Static File 对一些 httpd 是一件很痛的事。通常会以拆不同 domain、不同 server 的技巧，将静态档案 Server 与 Application Server 拆开。反向代理(Reverse Proxy)静态档案 或使用 CDN 处理。使用CDN 除了可以减轻对 httpd 的压力，还可以更多其他明显的好处：提供 delivery 档案的速度品质（尤其是服务的对象是 global）、有的厂商会帮忙上 gzip（甚至多帮忙处理 IE6 下 gzip 的问题）等。但使用CDN价格不菲，所以需要量力而行。

但是切换 static file 的 server，如果在架构上面没设计好，换 server 就要大幅改写 application 里的 code，是很伤开发成本的一件事。

**解法**： 

这一点 Rails 很聪明的帮开发者想到了，只要在 config 里设定

    config.action_controller.asset_host = ‘http://asset.example.org"

静态档案的来源通通都会自动改成 asset.example.org。更进阶的，browser 同时间只能对同一域名最多两个持久链接(persistent connections)，所以实际上还要将静态档案 server 拆成多个 domain，加速平行下载。这一点 Rails 也想到了, 通过`config.action_controller.asset_host = ‘http://asset%d.example.org"`，就可以同时分散到 asset0-3 去。

另外，上了 CDN 后，静态档案在 client-side 的 flush 又是一个问题。这一点 Rails 也是自动处理好了，一般 Rails Application 所产生的 html，静态档案档名的部分通常会有一串数字 ?123456，这就是用来解决 browser cache 住静态档案的问题，利用后面 query string 的不同，让 browser 以为跟原先之前 cache 住的档案不同而重新下载。由 Rails 的 helper 自动加上，数字是最后修改时间的 unixtime。

备注: 有人建议上面的`config.action_controller.asset_host = ‘http://asset%d.example.org"`和asset0-3之间存在笔误。asset0-3因该对应如下的配置: 

```ruby
ActionController::Base.asset_host = Proc.new { |source|
  "http://assets#{rand(2) + 1}.example.org"
}
```

### Add an Expires or a Cache-Control Header，Configure ETags

这是 Client Caching 技巧之一。`header["Cache-Control"] = "max-age=600"`表明 Content 在 600 秒内都是 valid 的，600 秒内都不用重抓。除非 broswer 送出 refresh 指令。要做到这件事：只要在 action 里简单的添加一行：

```ruby
expires_in 10.minutes
```

至于如果最前面的 web server 是 apache 的话，还有一招是在 public/stylesheets 和 public/javascripts 下放置一个有以下内容的 .htaccess 。

    Header add Cache-Control "max-age=86400″

至于 etag 以及 last-modified，参考XDite以前编写的 Scaling Rails 。

### Minify JavaScript and CSS

在 Minimize HTTP Requests 这章里，已经提过了 Rails 的 helper 内建了打包功能，但这个打包功能只有纯打包没有帮压。于是有人开发了一个 plugin： [Smurf](http://github.com/thumblemonks/smurf) 搭配 Rails helper 原有的机制，做到打包并压缩这件事。

最后，关于 Rails Front-end web performance 的 Scaling 的阅读材料，推荐如下:

* Yehuda 的 [Making Rails Even Faster by Default](http://cdn.oreillystatic.com/en/assets/1/event/42/Making%20Rails%20Even%20Faster%20by%20Default%20Presentation.pdf)
* Scaling Rails : Client-side Caching
* Scaling Rails : Advanced HTTP Caching

**备注**: Scaling系列是由NewRelic提供的相关优化的建议，有空进一步研究研究。

至于一般 General 的 Front-end web performance scaling 我推荐的是：

* [High Performance Web Pages](http://www.slideshare.net/stoyan/high-performance-web-pages-20-new-best-practices) 
* Steve Souders 的两本书：[High Performance Web Sites](http://oreilly.com/catalog/9780596529307)以及 [Even Faster Website](http://oreilly.com/catalog/9780596522308/)，以及他老人家的 [blog](http://www.stevesouders.com/blog/)
* [High Scalability](http://highscalability.com/)

## 3. Caching & HTTP Reverse Proxy Caching

不管是用什么语言什么架构做出来的网站，Scaling 很重要的一点的原则: **缓存一切**。让每个 request 都去 hit db、用程序即时去产生页面，对整体资源来说是相当昂贵的一件事。因此这两个部分要尽量都用 Cache 做掉。但是，一旦引入缓存，就必须要靠刷新过期和时效性的问题。

Caching 可粗分为 **DB Caching** 和 **Webpage Caching**。

### DB Caching

DB缓存又可分为数据库内部的缓存和ORM层的缓存。MySQL 本身就有 Query Cache 的机制，不过这里主要介绍如何用 [memcache](http://memcached.org/) cache 住 query result，减轻对 DB 的压力。PS: 先好像流行memcache的替代者 - Redis。

基本的想法是，要做 Read-Through 和 Write-Through，即`读写分离`。Read-Through 的意思是：程序要拿 result set 必须要先去问 memcache 有没有资料，有的话直接使用用，没有的话才从 DB 直接拿资料，然后 cache 在 memcache 里。而 Write-Thorugh 的作法是，当 object 被 新建、更新、删除时，被 cache 住的部分也要同步被更新到。

听起来很简单，具体如何实现，就如同陷入细节的泥潭之中。幸而有 [cache money](http://github.com/nkallen/cache-money) 这一套 plugin。它是一套 write-through and read-through caching library for ActiveRecord，可以避免自己动手。

还有一套 Rails Community 常用的 cache library 是 [cache_fu](http://github.com/defunkt/cache_fu) ，作用主要是可以对 cache 加上 expire time 的处理。

另外，Rails 有 API 可支援直接对 Cache ( memcache ）的读写操作。请阅读：Scaling Rails – 第八章 Memcached 

###  Webpage Caching

Webpage Caching 又分三种：Page Caching（整页）、Action Caching、Fragment Caching。

Page Caching 谈的就是把整页的内容，cache 成 html / xml / json，塞进 Cachestore（是的，Rails 有 Cachestore 的设计，你可以在 config 里指定 cache 是塞到 filestore、memory 还是memcahe 等等…）。

[ 推荐阅读：Scaling Rails - 第二章 Page Caching 、Scaling Rails - 第五章 Advanced Page Caching ]

但是只要是 Cache 就会有 Cache Expiration 的问题，如果在 controller 里，针对资料变动的 action 做 page 的 expiration，程序很快的就会变脏。比较好的方式是引进 Sweeper 的设计。Sweeper 是 Observer 的一种，可以同时 Observe controller 和 model。

[推荐阅读：Scaling Rails - 第三章 Cache Expiration ]

Action Caching 和 Page Caching 有什么不一样呢？ Page Caching 通常是用在同一页面，但须要吐针对不同条件式需要不同结果的 action，比如说身份判别。当该页针对 一般 user 和 anonymous 是吐出不同资讯时，就需要用到 Action Caching 。Action Caching 是配合 filter 去实做。在这个 case 中，如果没登入就直接吐已经 cache 过的结果或将 client 重导到 Login 页，通过验证的再向 mongrel 要。

[推荐阅读：Scaling Rails - 第六章 Action Caching ]

那什么时候会用到 Fragment Caching 呢？当这个页面很多区块需要分别 Cache 起来时，比如说导航栏和侧边栏。网站中很多侧边栏是用 partial 实现的，同时，不少列表部分也是用 partial 搭配 collection 去做的，此时就可使用 Fragment Caching。

[延伸阅读：Scaling Rails - 第七章 Fragment Caching ]

一样的，只要是 Cache 就会遇上 Expiration 的问题。这实在相当棘手。不过我在 Fragment Caching 这一块，是改用了不同于 Scaling Rails 系列的作法，我用了 ihower 写的 [Handcache](http://github.com/ihower/handcache) 和 Yehuda 的 [Moneta](http://github.com/wycats/moneta) 来做到对 cache 加上 expire time 的机制，使用 Moneta 也可以扩充使用更多不同的 cache backend，而不仅止于 memcache。

以上谈的都是程序里内部做的 Cache，接下来要谈的是外部的 Cache。一般实务上的作法都是用使用**Load Balancer** 加上 **HTTP Reverse Proxy** 实现。

穷人版的作法有几种：

1. 使用 mongrel 做 web server, 利用 apache 做 [rond-robbin](http://en.wikipedia.org/wiki/Round-robin) 以及 Reverse Proxy。
2. 使用 mongrel 做 web server, 利用 ngninx 做 load balancer（有个 module 叫 fair proxy） 以及 Reverse Proxy。
3. 利用 [Passenger](http://www.modrails.com/) (mod_rails）本身可以做到类似的架构，它有个 global queueing 的机制，蛮多设定可以调的，建议直接看 [Passenger 的 document](http://www.modrails.com/documentation/Users%20guide%20Apache.html#PassengerUseGlobalQueue)。
4. 架 [HAProxy](http://haproxy.1wt.eu/) 当 load balancer（[教学](http://plog.longwin.com.tw/my_note-unix/2009/03/23/haproxy-ha-load-balance-2009)），后面自己架 [Squid](http://www.squid-cache.org/) 或 [Varnish](http://varnish-cache.org/) 当 Reverse Proxy。ps: 小小困惑，用缓存服务器做方向代理是啥意思！！

[延伸阅读：Scaling Rails - 第十二章 Jesse Newland & Deployment]

不过，其实如果如果你的量已经够大了。每个月净赚几百万，但是苦在于 RD 不够或者是 SA 不够强能堆出/维护日渐庞大的架构。应该做的事是买一台 [F5](https://f5.com/) 比较实际…。

## 4. Asynchrony Processing (Message queue)

想法是将需要耗费大量资源或耗费大量时间的 job 都丢到 backgroud 去非同步执行。比如：寄信、缩图、转影片等等….

[@ihower](http://ihower.tw/) 在上次的 RubyTuesday 已经针对 [Distributed Ruby and Rails](http://ihower.tw/blog/archives/3589) 做了一次很好的 presentation。基本上看这份投影片就差不多了。

书籍推荐： [Distributed Programming in Ruby](http://www.informit.com/store/product.aspx?isbn=0321638360)

网路文章部分，关键字建议使用：

[Background processing Ruby Rails]

## 5. Partition Component using SOA

关于使用SOA划分组件，也推荐阅读同上的[投影片](http://ihower.tw/blog/archives/3589)。什么是 SOA 呢？SOA 的全名是 服务导向架构(Service Oriented Architectures)，其具体定义如下: 

* SOA is a way to design complex applications by splitting out major components into individual services and communicating via APIs。A service is a vertical slice of functionality: database, application code and caching layer 。
* SOA是一种来用开发复杂应用程序的方法，其主要思想是将应用的中主要模块分割成单独的服务，并通过API进行通信。服务通常是水平划分的功能层: 数据库，应用程序层和缓存层。

为什么谈 Scaling 要扯上 SOA 呢？

1. 当一套系统日渐庞大时，一定会开始出现需要将各样 Component 做水平拆分的动作。就比如说，为了 Scale DB 方面的表现，可能就会做 Database Sharding。但 DB Sharding 会造成新的问题，Application 必须配合 DB Sharding 做处理，也许当初用自己写的 ORM 可以处理掉这个问题。但是系统更大了以后，需要以 其他语言/ Framework / 架构去扩充 Application，另外一个问题就产生了：原先的 ORM 可能不能直接使用，这时候要直接 access db ？还是用新语言重写一套 ORM？但是，ORM 维护的不同步性会不会造成灵异现象呢？ 重新刻第二套第三套轮子是否有必要呢？

2. 我有一套 Bussiness Web Application，做的还不赖，想要拿来再外面架一套当分站，action 和 view 的架构大致上都不变，model 有一些关于 buisness 的部分 稍稍不同。这个不同说大不大，但说小也不小。比如说我开个卖电子书的网站好了，A 站收费是 a 模式，老板突然说想开个 B 站，计价采 b 模式。也许为了赶上线，我们用了大量的 copy code 办到了这件事。但是因为这网站实在太赚钱了，又要开 C 站….请问是要继续 copy code 吗？

遇上这两种场景，我想读者应该都会想哭。如果真的继续造轮子 / copy code 下去，扩充 + 维护难度会变得相当的高。

3. 假如今天外部厂商想要与我们合作，我们为了合作，必须开放部分资料让对方可进行读写。能让他直接读写我们的 DB 吗？当然不行。给他们我们的 ORM Lib 吗？也不行，ORM 可能也是商业机密。而且 ORM 可能也没有关于 Security 和 权限方面的控管。那我要针对这次合作案，写出一次性的 API 让他使用吗？好像也不对，有点太昂贵了….

4. 我今天想对 DB query 出来的 result 做 cache，到底是要在 cache 在哪里呢？application 层？ORM 层？混合在以上场景里，好像在哪里做都不对…..

所以这就是为什么做 Scaling 也要配合做出 SOA 的架构，以 API 和 WebServices 的模式，降低不同系统介接的难度，提供一致性的存取介面，并且在这一层就可以把该做的 Cache 和Security 做上去。如果不做 SOA，很多系统根本想 Scale 都 Scale 不上去….

坊间关于 SOA 的书籍和资料很多，因为 SOA 已经是一门独立的学问了。这里推荐SOA for Rails相关的书籍：

* [Service Oriented Design With Ruby and Rails](http://www.informit.com/store/product.aspx?isbn=0321700104)
* [Enterprise Rails](http://oreilly.com/catalog/9780596515201)
* [Enterprise Recipes with Ruby and Rails](http://www.pragprog.com/titles/msenr/enterprise-recipes-with-ruby-and-rails)


## 6. Distributed Filesystem / Database , Database Optimization, NoSQL

基本上如果你的网站规模不到一定规模（这边的定义是，用到几十台机器），是不需要去研究 Distributed Filesystem / Distributed Database 的。不过我还是稍微聊一下它们的使用情境好了。

Distributed Filesystem 我们在做完网站后，可以使用 Load Balancer 把 request 分散到各台 web-front 机器上，但随之就会产生一个问题，全站上的静态档案要怎样让这么多台的 web-front 存取呢？基本想法当然是用 NFS，但是随著网站成长，很快的 NFS 就不够担当这种重责大任了。于是另一种简单的作法又出现了，用大量的 rsync + script 将档案复制到多台 来*暂时* 解决 NFS 不够用的情况。这个方法勉强够用，但是会随之产生架构维护上的难度缺乏整体的管理与监控…。而且在有大量小档案需要同步，或者是档案数量到达了百万级、千万级时，纯用 rsync 非常的伤心...

所以这时候才会用上 Distributed Filesystem 来解决这个问题。DFS 的作用是让 Application 不用理会档案资源实际会存在哪里，往里扔就对了，接下来的事情 DFS 会自己处理掉。Opensource 中比较出名的 Distributed Filesystem 当属 Hadoop Distributed File System(HDFS)。

HDFS 想做到的是 Google File System (GFS）能提供的：

1. 易于扩充的分散式文件系统
2. 可运作于廉价的普通硬体上，又可以提供硬体错误容忍能力
3. 给大量的用户提供总体性能较高的服务

解决以上情景会遇到的问题，同时又提供扩充性、移植性、资料一致性，而且支援相当大的资料规模（Perabytes）。Facebook 本身也是用 HDFS。

有关于这部分的阅读资料，可参考[Hadoop Distributed File System](http://trac.nchc.org.tw/cloud/attachment/wiki/NCHCCloudCourse100127/1-4.pdf) 这份投影片。

而 Distributed Database 这个主题 可以参考[DK的文章](https://blog.gslin.org/archives/2009/07/25/2065/)。最重要的目标是 CAP theorem 的 Eventual Consistent（资料最终一致性）。比较知名的 Distributed Database 有 HBase 、Cassandra、Voldemort 等等….

### Database Optimization

这方面的主题能谈的非常多。而且每个主题也都相当博大精深。既然这系列的重点是 Reading Martrial，我就挑重点讲好了。

首先是：[MySQL 的设置 (软硬体、版本、设定)](http://blog.gslin.org/archives/2009/09/13/2088/)，这一段 DK 也已经专门整理过一篇文章了。内容是有关于机器、硬盘的挑选，架构的设计。挑选适合 MySQL 使用的 FileSystem ，my.cnf 的设置。

而跟 MySQL 各方面都不是很熟，看原文书又觉得很痛苦的人。推荐看简朝阳写的 [MySQL 性能调优与架构设计](http://www.china-pub.com/195636) 这一本书。基本上如果想了解 MySQL 的各样基础知识甚至进阶知识，这本书大部分都含括了，而且写的相当深入浅出….

架构设计上的需求，可直接看这本书的第三篇 (Ch12-Ch18)，以及 [High Performance MySQL](http://oreilly.com/catalog/9780596003067) 这本书。追求极致的 Performance Optimizaion 可追 [MySQL Performance Blog](http://www.mysqlperformanceblog.com/) 这个 blog …

DB 永远是 Web Application 的瓶颈。而使用 ActiveRecord 想对 query optimize 的几个 tips 是：

1. 不要忘记打 index，这一点很常在写 model code ，写著写嗨了就忘记了，忘记打 index 可能会造成 slow query，可用 [rails_indexes](http://github.com/eladmeidar/rails_indexes) 这个 plugin。
2. 只 SELECT 你要的资料，而非 SELECT *。这一点可以透过 scrooge 这个 plugin 办到。
3. 避免产生 n+1 query。
4. 记得加 counter_cache。 3、4两条都可用 [bullet](http://github.com/flyerhzm/bullet) 这个 plugin 抓出来
5. 记得打开 [my.cnf 里面记录 slow query log](http://plog.longwin.com.tw/post/1/234) 的选项，然后善用 EXPLAIN 抓出真正的原因。
6. 尽量使用 find_in_batch，而不要使用回圈跑 find(i)
7. 少用 join，多用几次 select 做到相同的事。
8. 必要的时候，使用 SQL Antipattern 技巧，denormalize，实作 eav 等等….这方面可以看 [SQL Antipaatern](http://www.pragprog.com/titles/bksqla/sql-antipatterns) 这本书。 

### NoSQL

对岸 JavaEye 的站长 Robbin 写过一篇「[NoSQL数据库探讨之一 － 为什么要用非关系数据库？](http://robbin.javaeye.com/blog/524977)」。整理了为什么世界上比较大型的 Web 2.0 Site 要舍弃 RDBMS 转而开发/使用 NoSQL 的原因：

1. High performance – 对数据库高并发读写的需求
2. Huge Storage – 对海量数据的高效率存储和访问的需求
3. High Scalability && High Availability- 对数据库的高可扩展性和高可用性的需求

这些 production 网站，对 DBMS 特性的要求 ：

1. 数据库事务一致性需求
2. 数据库的写实时性和读实时性需求
3. 对复杂的SQL查询，特别是多表关联查询的需求

以及市面上满足这些需求的各种 NoSQL （依照分类）以及简单介绍，相当值得一看。

另外 High Scalability 出了一篇 [Paper: High Performance Scalable Data Stores](http://highscalability.com/blog/2010/2/25/paper-high-performance-scalable-data-stores.html)

而我个人比较有在玩的是 MongoDB，他比较贴近 MySQL 的用法，但速度上也比 MySQL 快些。MongoDB 贴近 MySQL 的用法和一些其它的 feature，也比较满足我在开发网站上的需求，比如说我就相当喜欢它以下的特色：

* Document-oriented # BSON ( Binary JSON)
* schema-less
* full index support
* dynaminc query ([MongoDB – Ruby document store that doesn’t rhyme with ouch](http://www.slideshare.net/pengwynn/mongodb-ruby-document-store-that-doesnt-rhyme-with-ouch) P.34)
* MM replication & auto sharding
* 可用来做 Real-Time Analytics …# upsert 特性
* subdocument 甚至是 [nested document](http://www.mongodb.org/display/DOCS/MongoDB+Data+Modeling+and+Rails#MongoDBDataModelingandRails-Nested%2CEmbeddedComments) # 做巢状 comment 特别简单。知名留言系统 Disqus （支援 Nested Comment ）的 backend 就是 Mongodb。 

2009 的 Rubyconf 就有一个关于 MongoDB 的 Talk: [Getting Non-Relational with MongoDB](http://rubyconf2009.confreaks.com/19-nov-2009-16-20-getting-non-relational-with-mongodb-michael-dirolf.html)，相当值得一看。

## 后记

粗略了看一下，顺带补上链接和调整格式。谈谈几点见解: 首先，xdite的6-7年RoR经验值得学习; 其次，xdite阅读面相当的宽泛，书籍以及相关的会议; 最后，xdite 2006年开始写博。而我，是2013年8月开始写博。综上所述，一年后，我应该会很NB。之所以要这么自恋，是为了给自己鼓励，毕竟看到别人很NB自己很CB，怕自己情绪低落，影响士气。
