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
  - 在app/sweepers目录下，新建文件`post_sweeper.rb`，其内容如下: 

```
