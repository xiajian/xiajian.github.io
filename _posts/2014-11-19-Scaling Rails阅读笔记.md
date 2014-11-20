---
layout: post
title: Scaling Rails笔记
---

## 前言

[New Relic](http://newrelic.com/)赞助Rails Envy，制作了13集的Scaling Rails，Xdite将其整理成13篇文章，我在<http://www.hksilicon.com>中Ruby on Rails上看到，阅读并做笔记如下: 

## 第一章 Page Responsiveness

可扩展的目标是：提高页面响应时间。关于响应涉及两个主题: **如何测量**，**如何改善**

测量工具: Firefox的Firebug，Safari的Advance , Firefox的YSlow。结果显示，页面加载时间占响应时间的大头。

改善思路: 

* 提高服务器端性能
* 减少浏览器加载时间

YSlow在测试页面后，会给出实际建议，具体可以参考Yahoo！的Best Practices for Speeding Up Your Web Site。一些建议如下: 

* 最小化HTTP请求, js/css的cache选项，例如: `<%= javascript_include_tag , :main , :cache => true %>`，不知和Asset Pipeline有何区别。
* 使用CDN(有很多CDN厂商)，需要的配置是: `ActionController::Base.asset_host = "assets.example.com"`, 然后使用`image_tag`辅助方法
* 添加Expires头部

Nginx中配置: 

```ruby
# Add expires header for static content
location ~* \.(jpg|gif|png|css|js)$ {
  if (-f $request_filename){
    expires max;
    break;
  }
}
```
更多参考建议参考[YSlow文档](http://developer.yahoo.com/yslow/help/)。

## 第二章 Page Caching

Rails中的cache: Page Caching, Action Caching, Fregrement Caching。

Mongrel(20-50 req/s) * 24h = 200万 pv。Page Caching - HTML - Apache 1000 req/s

在生产环境中设置: `config.action_controller.perform_caching = true`, caches_page方法。

cache页面默认放置在public目录下，可通过如下选项配置: 

    config.action_controller.page_cache_directory = RAILS_ROOT + "/public/cache"

Page Caching适合页面变动不频繁的页面：各种首页，参考页。

页面更新后，通过`expire_page`方法，强制过期页面，具体例子为: 

```ruby
def update
  @post = Post.find(params[:id])
  expire_page :action => :index
  expire_page :action => :show, :id => @post

  repsond_to do |format|
    ....
  end
end
```
Page Caching可以Cache HTML，xml，json等格式。

尝试一下，发现一个问题: 网站页面中，存在登录状态控制，登录前和登录后的页面不同的，页面缓存是不是办法。只好尝试片段和动作缓存了。

## 第三章 Cache Expiration

前一节中，使用`expire_page`，在update动作中，处理页面过期。如果动作比较多，代码就容易重复。


```ruby
def update
  ...
  expire_page :action => :index
  expire_page :action => :show, :id => @post
end

def show 
  ...
  expire_page :action => :index
  expire_page :action => :show, :id => @post
end

def create
  ...
  expire_page :action => :index
  expire_page :action => :show, :id => @post
end
```
此时，可以将其定义方法，然后使用`after_filter`过滤器。

```ruby
# posts_controller.rb
after_filter :clear_posts_cache, :only => [:create, :update, :destroy]

def clear_posts_cache
  expire_page :action => :index
  expire_page :action => :show, :id => @post
end
```

如果多个控制器都需要调用`clear_posts_cache`, 存在三种处理方法: 

* 将`clear_posts_cache`放到application.rb中
* 将`clear_posts_cache`设置为shared object, 然后include到那些使用的控制器中
* 使用sweeper监控(Rails提供)，可以Observes 控制器和模型，使用如下: 
  - 在`config.load_paths`中添加`#{RAILS_ROOT}/app/sweepers`
  - 在app/sweepers目录下，新建文件`post_sweeper.rb`, 然后在控制器中设置那些动作要调用sweeper

```ruby
# post_sweeper.rb
class PostSweeper < ActionController::Caching::Sweeper
  observe Post
  def after_save(post)
    clear_pass_cache(post)
  end

  def after_destroy(post)
    clear_pass_cache(post)
  end

  def clear_pass_cache(post)
    expire_page :controller => :posts, :action => :index
    expire_page :controller => :posts, :action => :show, id => post             
  end
end

# posts_controller
class PostController < ApplicationController
  caches_page :index, :show
  cache_sweeper :post_sweeper, :only => [:create, :update, :destroy]
  # ...
end
```
sweeper中可使用 ActiveRecord 的 callbacks， after / before 。

## New Relic RPM

New Relic可对服务器进行各项效能的监控，并提供详细数据，可以查看Action的效率。不过，令人在意是，如何做到的？

## 第五章 Advanced Page Caching

出现的问题: 

1. index中对象使用了paginate，永远返回第一页。解法: 为分页指定特殊路由`map.posts_with_pages '/posts/page/:page', :controller => 'posts', :action => 'index'`
2. 页面中的Dynamic Data， Cache如何处理。解法: 使用Ajax Dynamic Loading，大体思路时，静态页面渲染结束后，利用远程js脚本更新登录状态, 如下是一些代码片段: 

```ruby
# 在页面下方添加如下的代码
<%= remote_function :update => 'login_status', :url => login_status_path %>
# SessionsController中添加动作
def status
  render :inline => login_status
end
```

## 第六章 Action Caching

Page Caching存放在Disk中，Action & Fragment Caching则存放在Configure cache中。Cache Store方面提供了多种选项: mem_cache_store到redis_store，file_store等。

Action Caching需要配合filter，Rails 默认cache_store是memory_store, 其本身是一个 Hash{}。缺点: 进程之间不能共享，容易 out of memory，难以处理Cache Expiration。

Action Caching不需要Layout: 

```ruby
class PostsController
  before_filter :authenticate
  # Render the layout on each request, Not going to run the action
  caches_action :index, :show, :layout => false
  ....
end
```
带条件的Action Caching:

```ruby
class PostsController
  before_filter :authenticate
  # Disable the cache on certain requests, 这里的疑问是，传给action的变量是?
  caches_action :index, :show, :if => Proc.new { |controller| !controller.params[:no_cache]} 
  ....
end
```

Action Cahing的适合情景: 

* 不能使用Page Caching
* 需要在每个视图上都执行的代码，且结果一致

## 第七章 Fragment Caching

Fragment Caching：当页面不同区域都需要cache时，使用partial。实现方式有两种，区别就是将cache方法调用写到哪里，一种是写在调用的地方，还有一种是写在render的部分视图中，实例代码如下: 

```ruby
# index.html.erb
<%= render :partial => "recent_posts" %>

# _recent_posts.html.erb
<% cache(:recent_posts) do %>
  <div>
    <ul>xxxx</ul>
  </div>
<% end %>

# posts_controller.rb
def index
  @posts = Post.find(:all, :limit =>20)
  if !fragment_exist? :recent_posts
    @recent_posts = Post.find(:all, :order => "created_at")
  end

  respond_to do |f|
    f.html
    f.xml { render :xml => @posts }
  end
end

#posts_sweeper.rb - 处理缓存过期的问题
def after_destroy(post)
  clear_posts_cache(post)
end

def clear_posts_cache(post)
  expire_fragment :recent_posts
  expire_action :controller => :posts, :action => :show, :id => post
end
```
Fragment Method 在 controller layer 有这几种:

```ruby
write_fragment(key, content, options = nil)
read_fragment(key, options = nil)
fragment_exist?(key, options = nil)
expire_fragment(key, options = nil)
```

Fragment Method 在视图中的方法: 

```erb
<% cache(key) do %>
  ...
<% end %>
```

考虑memcache是键值数据库，这里需要认真对待的是key设置, key的取值可以是这样的: 

* `#{@city.name}-photos`
* `#{current_user.id}-panel`

使用时机: 不能使用 Page Caching 或 Action Caching 时, 多个用户中，页面中某些资讯是相同的。

> 计算科学的两大难题： 缓存失效和命名。Cache Expiration是很头疼的事。

## 第八章 Memcached

Cache的直觉感受: Page Caching。当Page Cache，Action Caching，Fragment Caching都不行了后，考虑使用memcache。使用示例: 

```ruby
def get_friends_posts
  value = Cache.get("friends")
  return value if value
  journal_posts = # Fetch form database
  Cache.set("friends", journal_posts)
  return journal_posts
end
```
** Memcached ** is a high-performance, distributed memory object caching system, generic in nature, but intended for use in speeding up dynamic web application by alleviating database load.

简而言之，就是{} in Memory。

在Rails中使用Memcache需要设置config: 

    config.cache_store = :mem_cache_store

设置结果后，存在两种使用方法: 

1. Object Store - 用来缓存数据库中的查询的结果，访问对象通过`Rails.cache`，提供的方法有: read, write, fetch, delete , exist? , increment, decrement, clear
2. Fragment Cache Store(Action & Fragment Caching)

`Rails.cache`中可存一般字符串，也可存ActiveRecord Object。简单的操作如下:

```sh
[1] pry(main)> Rails.cache.write "name", "xiajian"
=> true
[2] pry(main)> Rails.cache.read "name"
=> "xiajian"
[3] pry(main)> Rails.cache.exist? "name"
=> true
[4] pry(main)> Rails.cache.delete "name"
=> true
[5] pry(main)> Rails.cache.read "name"
=> nil
[6] pry(main)> Rails.cache.write "first_post", Article.first
=> true
[7] pry(main)> Rails.cache.read :first_post
=> #<Article _id: 5175590bf12379ac91000291, ....
```

备注: memcached访问，通过`telnet 127.0.0.1 11211`登录,可以使用get、set，delete、stats , telnet退出命令是`quit`。尝试了一下,觉得不太好用。这一点不如Redis, Redis还有的命名行工具。

处理缓存异常的方法有两种：

* 其一，可以在fetch方法中使用`:expires_in`参数, 其可放置在Model中，也可放置在view中。

```ruby
# post.rb
class Post < ActiveRecord::Base
  belongs_to :user

  def self.recent
    Rails.cache.fetch("recent_posts", :expires_in => 30.minutes) do 
      self.find(:all, :limit => 10)
    end
  end
end

# post的视图中
<% cache(:recent_posts, :expires_in => 30.minutes) do %>
  ...
<% end %>
```

* 其二，使用Intelligent keys，代码形如: `cache("#{post.id}-#{post.updated_at.to_i}-data")`，Rails中简写形式为: `cache(post)`, `cache([post, user])`。

memcached的使用时机：使用Action Caching 或 Fragment Caching，并减少db访问次数。

备注: `memcached -m 2000`就会拥有2G内存，用光内存之后，memcached会 pop stack。

## 第九章 Taylor Weibley & Databases

EngineYard - Rails Hosting公司。Taylor Weibley的建议: 

* Beware of fetching external data, 页面尽量不要需要额外的数据
* Optimized your Database, 找出slow query，然后改善。别忘了打index
* Design for Scaling Upfront, 设计时就要注意扩展性

让数据库更快的方法：

1. Don’t forget indexes，key都要打上index
2. Use include，是何含义
3. 使用counter caching，多开一个字段，将counter cache起来。设置`:counter_cache => true`
4. 安装 QueryTrace Plugin，检查系统生成的查询语句
5. Drop to SQL, 某些查询ORM非常耗资源，不如手写
6. 数据库表的非规范化
7. Slaves and Masters，db上使用主从架构，[masochism](http://github.com/technoweenie/masochism/)。主写，从读
8. Databse Sharding，使用[Data Fabric](http://github.com/fiveruns/data_fabric/)

更多内容，可以参考Advance ActiveRecord

## 第十章 Client-side Caching

客户端浏览器有三个参数可处理，max-age, etag, last_modified。

- max-age的使用，在action中添加`expires_in 10.minutes`, 响应中就会包含`header["Cache-Control"] = "max-age=600"`
- etag，Rails内建etag-md5(body)。比较请求和响应的etag`request.etag_matches?(response.etag)`，客户端快而服务器端依旧。

<div class="pic"><img src="/assets/images/etag.jpg"/></div>

- last_modified，类似etag，其记录的是日期，实例如下

```ruby
def show
  @user = User.find(param[:id])
  fresh_when :last_modified => @user.updated_at.utc
end

# request.not_modified?(response.last_modified)
```

建议： 组合etag和last_modified进行使用。好处，增进服务器端性能，减少查询和render，增加客户端性能。

使用时机: 使用Fragment或Object caching时，提高throughput，并节省CPU时间。

## 第十一章 Advanced HTTP Caching

Rack::Cache / Varnis / Squid / Akamai (Reverse Proxy Caches ) 

Proxy Cache是位于客户端的缓存层，反向代理是位于服务器端的缓存层。

缓存就要考虑过期的问题，Reverse Proxy 和 Server 之间的Expiration，混合max-age、etag、last_modified + Reverse Proxy，从而降低Server的负担。

结果是相当诱人的，具体的性能结果参考<http://www.hksilicon.com/kb/cn/articles/3805/Scaling-RailsAdvanced-HTTP-Caching>。

 Rack::Cache - Reverse Proxy, 不同的Process使用File Store或memcache处理。 

 ## 高手建议

 [RailsMachine](http://railsmachine.com/)的Jesse Newland的建议: 

 1. Separate / Isolate Your Rails Stack , 将不同的service放在不同的server上。
 2. Avoid Hitting the Database， 各种缓存
 3. Use an Intelligent Reverse Proxy，Mongrel 上 HAProxy

与HAProxy类似功能的有Nginx中的fair proxy，带全局队列的Passenger

[New Relic](http://newrelic.com/)的Jim Gochee(Director of Enginering)提出的建议: 

1. Analyze your app in Production, 使用New Relic工具分析
2. Optimize your database use, 做好 Cache, 减少 Hit DB, 善用EXPLAIN搞清楚query慢在哪里, 弄熟ActiveRecord，生产高效
3. Use ha_proxy with max-con 1 , 使用HAproxy

## 总结

第一章的重点:

一般来说花在 loading page 的时间会比较高，改善这个 CP 值比较高。可用 YSlow 和其提供的 tips 去提升效率。

第二到第八章的重点:

介绍各种 Cache 策略的作法：Page Caching、Action Caching、Fragment Caching。使用 Memcache 搭配 Fragment Caching 等等。

第九章的重点:

许多网页应用程式瓶颈都是卡 DB，因此善用 MySQL 的 EXPLAIN 去找出 Slow Query，并且挖掘是哪一段的代码（ORM语法）造成的。记得要打 INDEX，将 counter 做 cache。上 Master/Slave 架构。

第十到第十一章的重点:

讲 Client-side Caching。要提高速度，就是避免去 Hit DB，因此做好 Client-site Caching 是很重要的。这两章主要是介绍三种 HTTP header：max-age、etags、last_modified 降低 Client 来问的次数。并且建议将流量转嫁到 ReverseProxy 上。

第十二章:

负载平衡以及如何实作简单的 HA 架构。

其实不光是 Rails，一般 Web Application "基本"的 Scaling 也大概都是照这些方式。如果对 Scaling 有兴趣的话，这些主题是相当好的 Google 关键字…继续挖掘下去，相信您会收获更多的。

## 小结

读完后，收获良多，虽然实践很少，不过给了我继续前进的动力。新书《构建高性能Web站点》送到了。
