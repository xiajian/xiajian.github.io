---
layout: post
title: 可维护的Rails视图(Maintainable Rails View)
description: "编写可维护的Rails视图，视图中要少逻辑"
category: [rails, view]
---

## 前言

昨天，看到一本书上说: `地位越高的人越容易忘记自己姓什么`。 我想把网站变的快一点，但是，知识的掌握也很匮乏，工作时又不是特别的尽心，偶尔还跑去看动漫，所谓漫漫长路的人生烦恼。以下是，在推酷上看到了，复制过来，学习一下。原作者[xdite](http://blog.xdite.net)大概有6年RoR经验，是个不错的"导师"。

文章来源: <http://segmentfault.com/blog/ytwman/1190000000507093>

## 正文

话题来源于xdite在[RubyConfChina 2013](http://rubyconfchina.org/)的Talk： [Maintainable Rails View](https://speakerdeck.com/xdite/maintainable-rails-view)

关于讨论视图的原因：长久以来，在一个 Project 里面，设计出干净的 Model 与 Controller要比干净的view要简单的。views中有如一团乱麻，很难以简单的思路去整理这些纠结的线。xdite整理出关于Rails views处理的指南，也是其所在的[Rocodev](http://rocodev.com/)目前在用的 Rails View 技巧。

## 前情提要

要了解这些用法中的取舍，需要了解几个前提(原则)。View 中的复杂逻辑 ( if / else & other syntax )会导致如下的问题: 

-  页面修改以及维护
-  导致 View Performance 下降 ( pure logic )
-  导致 View Performance 严重下降 ( with data query )。数据查询应该放在Helper中

Talk 包含以下几个主题：

-  Helper Best Pratices
-  Partial Best Pratices
-  除了 Helper 与 Partial 之外的整理武器
-  Object-Oriented View

本文将介绍 18 个整理view手法。值得注意的是，这些手法是「循序渐进」的，即前面的手法未必是「最好」的，而是在「初期整理阶段」是一个好的手法，而事情变得复杂的时候，你才需要越后面的技巧去协助整理。

Helper(辅助ruby方法)和Partial(局部模板)都是用来整理view的常用工具，容易混淆两者的使用。Partial通常用来处理大段重复的程序码或独立局部功能。Helper专属于需要逻辑输出的HTML的工具，常见的`stylsheet_link_tag`，`link_to`都是Helper的范畴。Rails内建了很多helper: `simple_format`, `auto_link`, `truncate`, `html_escape`，`form_for`。

本文中，最重要的是：对Helper和Partial的理解。

## 1. Move logic to Helper

这是一段经常在 View 里面直觉写出来的判断程序。

```ruby
<% if current_user && current_user == post.user %>
  <%= link_to("Edit", edit_post_path(post))%>
<% end %>
```

- 如果只有一个条件，如 if current_user ，则不用进行整理
- 如果在第一次撰写时，就发现会有两个条件，则在最初撰写时，就使用一个简易的 helper 整理。

```ruby
<% if editable?(post) %>
  <%= link_to("Edit", edit_post_path(post))%>
<% end %>
```

**注**: `editable?(post)` 并不是一个好的名字，不过可以先标上打上**# TODO: REFACTOR** ，之后再回来整理。

## 2. Pre-decorate with Helper (常用栏位预先使用 Helper 整理)

在设计 Application 时，常常会遇到某些栏位，其实在初期设计时，就会不断因为规格扩充，一直加上 helper 装饰。比如 Topic 的 content ：

    <%= @topic.content %>

在几次的扩充之下，很快就会变成这样：

    <%= auto_link(truncate(simple_format(topic.content), :lenth => 100)) %>

而这样的内容，整个 Application 可能有 10 个地方。每经过一次规格扩充，developer 就要改十次，还可能改漏掉。

针对这样的情形，建议在第一次在进行 Application 设计时，就针对这种「可能马上就会被大幅扩充」的栏位进行 Helper 包装。而不是「稍候再整理」

    <%= render_topic_content(@topic) %>

其他类似的包装方法有: `render_post_author`, `render_post_published_date`, `render_post_title`,`render_post_content`

## 3. Use Ruby in Helper ALL THE TIME ( 全程在 Helper 里面使用 Ruby )

有时候会因为要对 View 进行装饰的原因，会被迫在 Helper 里面写出如下的代码: 

```ruby
# double quote
def post_tags_tag(post, opts = {})
  tags = post.tags
  raw tags.collect { |tag|  "<a href=\"#{posts_path(:tag => tag)}\" class=\"tag\">#{tag}</a>" }.join(", ")
end

# single quote
def post_tags_tag(post, opts = {})
  tags = post.tags
  raw tags.collect { |tag| "<a href='#{posts_path(:tag => tag)}' class='tag'>#{tag}</a>" }.join(", ")
end
```

这是`非常不好`的设计手法，在 Ruby Helper 里面穿插纯 HTML 与 quote 记号，会很容易因为少关一个 quote，就导致 syntax error。另外一个潜在副作用是：Helper 被这样一污染，Developer 因为害怕程式码爆炸，很容易就降低了重构的意愿。

因此， 严格禁止 在 Ruby Helper 里面穿插任何 HTML 标记。请使用任何可以生成 HTML 的 Ruby Helper 取代。

```ruby
def post_tags_tag(post, opts = {})
  tags = post.tags
  raw tags.collect { |tag| link_to(tag,posts_path(:tag => tag)) }.join(", ")
end
```

## 4. mix Helper & Partial （混合使用 Helper 与 Partial )

穿插 HTML 在 Helper 里面还有另外一个后遗症。Helper 的输出最后往往要用`raw/.jjhtml_safe`进行HTML unescape。

```ruby
def render_post_title(post)
  str = ""
  str += "<li>"
  str += link_to(post.title, post_path(post))
  str += "</li>"
  return raw(str) 
end
```

从而造成了一个非常巨大的 security issue。Ruby on Rails 的标准预设是 HTML escape，避免了非常多会被 XSS 攻击的可能。穿插 HTML 在 Helper 的设计，导致了一个巨大的曝险地位。

因此，只要遇到需要穿插稍微复杂 HTML 的场景，可以使用Helper与Partial穿插的技巧实现。如修改成以下的程式码：

```ruby
def render_post_title(post)
  render :partial => "posts/title_for_helper", :locals => { :title => post.title }
end
```
一些常见的使用场景: 1. 列表中的分类 2. 面包屑中的post标题 3. glyphicons中的用户名

## 5. Tell, Don't ask

有些时候，开发者会在 New Relic 发现某个 view 的 Performance 低落，但是却抓不出来实际的问题在哪里。这是因为是慢在 helper 里面。

这是一个相当经典的范例：

```ruby
def render_post_taglist(post, opts = {})
  tags = post.tags
  tags.collect { |tag| link_to(tag,posts_path(:tag => tag)) }.join(", ")
end

<% @posts.each do |post| %>
  <%= render_post_taglist(post) %>
<% end %>
```

这是因为在 View / Helper 里面被 query 的资料是不会 cache 起来的。在 helper 里面获取tags，这样的设计容易造成 `N+1问题`(即查询n个对象时，需要执行N+1次select语句)，也会造成 template rendering 的效率低落。

改进方法：尽量先在外部查询，再传入 Helper 里面「装饰」

```ruby
def render_post_taglist(tags, opts = {})
  tags.collect { |tag| link_to(tag,posts_path(:tag => tag)) }.join(", ")
end

<% @posts.each do |post| %>
  <%= render_post_taglist(post.tags) %>
<% end %>

def index
  @posts = Post.recent.includes(:tags)
end
```

## 6. Wrap into a method ( 包装成一个 model method )

有时候，我们会写出这种 Helper code :

```ruby
def render_comment_author(comment)
  if comment.user.present?
    comment.user.name
  else
    comment.custom_name
  end
end
```

这段程式码有两个问题：

-  Ask, Not Tell
-  问 name 的责任其实不应放在 Helper 里面

可以作以下整理，搬到 Model 里面，这样 author_name 也容易实现 cache ：

```ruby
def render_comment_author(comment)
  comment.author_name
end

class Comment < ActiveRecord::Base
  def author_name
    if user.present?
      user.name
    else
      custom_name
    end
  end
end
```

这一篇的重点是 Partial 的设计

## 7. Move code to Partial

什么时候应该将把程序搬到Partial呢？

- long template | code 超过两页请注意
- highly duplicated | 内容高度重复
- indepdenent blocks | 可独立作为功能区块
- nav/user_info
- nav/admin_menu
- vendor_js/google_analytics
- vendor_js/disqus_js
- global/footer

## 8. Use presenter to clean the view ( 使用 Presenter 解决 logic in view 问题）

在前一章节，我们介绍过 view 里面常被迫出现这种代码: 

```ruby
<%= if profile.has_experience? && profile.experience_public? %>
  <p><strong>Experience:</strong> <%= user_profile.experience %></p>
<% end %>
```

Presenter 这个设计手法最近很少在 Rails 界被提到，是因为 Presenter 很常被滥用。不过在现在这段程式码的状况，其实你可以用 Presenter 实现一点整理：

```ruby
class ProfilePresenter < ::Presenter
  def with_experience(&block)
    if profile.has_experience? && profile.experience_public?
      block.call(view)
    end
  end
end
```

然后就可以生出这么优美的 View

```ruby
<% user_profile.with_experience do %>
  <p><strong>Experience:</strong> <%= user_profile.experience %></p>
<% end %> 
<% user_profile.with_hobbies do %>
  <p><strong>Hobbies:<strong> <%= user_profile.hobbies %></p>
<% end %>
```

## 9. Cache Digest(缓存摘要)

Logic in View 有两种最常出现的 case： if / else 和 for / each 。前者我们可以用 Helper 闪掉，后者却几乎无法有其他方式取代。

这是一个经典的回圈 View：

```ruby
<% @project do %>
  aaa
  <% @todo do %>
    bbb
    <% @todolist do %>
      ccc
    <% end %>
  <% end %>
<% end %>
```

通常提高效率的方式，只有「进行 Cache」，居然可以这样:

```ruby
<% cache @project do %>
  aaa
  <% cache @todo do %>
    bbb
    <% cache @todolist do %>
      ccc
    <% end %>
  <% end %>
<% end %>
```

但是进行 cache，又会遇到 cache invalid(缓存失效) 的问题，比如要改 todolist 回圈里的 ccc，就非常困难。于是，我们又会改变思路，在 cache 上面加上版本号，如

```ruby
<% cache [v15,@project] do %>
  aaa
  <% cache [v10,@todo] do %>
    bbb
    <% cache [v45,@todolist] do %>
      zzz
    <% end %>
  <% end %>
<% end %>
```

但加上版本号以后，还是有其他的问题，很多时候 view 是被 partial 层层嵌套，如上面这个例子，当我们把版本 bump 到 v46 ，还必须去找出所有上层的 v10 ，去改成 v11 ，很是麻烦。

Rails 的创始人 DHH，开发了一个 gem : `[cache_digest](https://github.com/rails/cache_digests)` 。现在已正式内建在 Rails4 中，完美了解决这个问题。 cache_digest 的思路是: 自动计算 cache helper 里的 view 的 checksum ：

```ruby
# md5_of_this_view
<% cache @todolist do %>
    zzz
<% end %>
```

因此，安装了 cache_digest 的 Rails project，在遇到这种状况时：

```ruby
<% cache @project do %>
  aaa
  <% cache @todo do %>
    bbb
    <% cache @todolist do %>
      ccc
    <% end %>
  <% end %>
<% end %>
```

可以自动 invalid cache，不需要作额外的 hack，很是方便。

## 10. Cells

在设计某些 Profile 页，会遇到必须针对某些 Object 进行 diplay related information 的状况。如 User Profile：

```ruby
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @recent_posts = @user.recent_posts.limit(5)
    @favorite_posts = @user.favorite_posts.limit(5)
    @recent_comments = @user.comments.limit(5)
  end
end

<%= render :partial => "users/recent_post", :collection => @recent_posts %>
<%= render :partial => "users/favorite_post", :collection => @favorite_posts %>
<%= render :partial => "users/recent_comment", :collection => @recent_comments %>
```

这算是一个相对安全的问题。但后续可能会撞到一些奇怪的问题：

- 如果要对个别 block 进行 cache，而且每一个 block 需要被 cache 不同的时间，如 3/5/7 hours
- 每个 block 内的 data set 必须要进行一些加工。

这时候整个 controller 和 view 就会被污染到无法想像，而且效率非常低下。

这时候可以引进外部的 Gem 进来整理，不需拘泥于原始的 Controller / View 架构，而这个 Gem 就是 [cells](https://github.com/apotonick/cells)。

Cells 的想法是开发者并不需要强行在一层的 MVC 架构里，在 Controller 把一次事情做完（查资料，处理资料）。开发者可以使用 Cells 把这些复杂逻辑拆成一个一个独立的逻辑元件（componet)去实现。而这些 component 是可以被复用、被 Cahce、可以被测试的。

简而言之，在用 Cells 时，你是可以把 Cells 想成这样的：

- 可复用可Cache 的 Partial
- 这个可以被 Cache 的 Partial，自己有一个迷你的 Controller 和 View

同时 Cells 可以让你把 cache 的条件拆成非常的漂亮。

```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end
end
```

```ruby
# app/views/users/show.html.erb
<%= render_cell :user, :rencent_posts, :user => :user %>
<%= render_cell :user, :favorite_posts, :user => :user %>
<%= render_cell :user, :recent_comments, :user => :user %>
```

```ruby
# app/cells/user_cell.rb
class UserCell < Cell::Rails

  cache :recent_posts, :expires_in => 1.hours
  cache :favorite_posts, :expires_in => 3.hours
  cache :recent_comments, :expires_in => 5.hours
 
  def recent_posts(args)
    @user = args[:user]
    @recent_posts = @user.recent_posts.limit(5)
    render
  end
  
  def favorite_posts(args)
    @user = args[:user]
    @favorite_posts = @user.favorite_posts.limit(5)
    render 
  end
  
  def recent_comments(args)
    @user = args[:user]
    @recent_comments = @user.comments.limit(5)
    render
  end
end
```

我之前曾经写过一个 Cells 系列，如果你有兴趣深入把玩 Cells 的话，以下是系列连结：

## 11. content_for ( yield )

有些开发者不是很了解 Rails 的 yield 是拿来作什么的。可以理解成跳跃到定点执行 。

这招常被用在一个情景上： [Best Practices for Speeding Up Your Web Site](https://developer.yahoo.com/performance/rules.html) 中的 put javascript at bottom。

在调整前端 performance 时，最常见也最有效的一招就是，把肥大的 JavaScript 放在最底端读入执行，因为很多 JS 都是 document.ready 才会被执行。

但是，如果开发者只是把 javascript_include_tag 丢到 view 的底下，如：

```ruby
<%= stylesheet_link_tag "application" %>
<%= yield %>
<%= javascript_include_tag "application" %>
```

其实这样有时候是不其作用的，因为当 View 里面需要写 inline javascripts 时，如：

```html
your content stuff 
<script type= "text/javascript">
  your script here
</script>
```

会得到 javascript undefined。

这通常是因为 inline javascripts 呼叫了 jQuery 里面的函式，而 inline javascripts 被执行的比 jQuery 被读入的时间早，所以会出现 undefined。

所以你只好被迫将优美的

```ruby
<%= stylesheet_link_tag "application" %>
<%= yield %>
<%= javascript_include_tag "application" %>
```

改成: 

```ruby
<%= stylesheet_link_tag "application" %>
<%= javascript_include_tag "application" %>
<%= yield %>
```


其实要解决这样的问题。只需要把 View 改成这样：

```ruby
<%= stylesheet_link_tag "application" %>
<%= yield %>
<%= javascript_include_tag "application" %>
<%= yield :page_specific_javascript %>
```

需要插入 inline javascripts 的地方再这样写，这样 inline javascripts 就会在正确的位置 page_specific_javascript 被执行。

```erb
your content stuff 
<%= content_for :page_specific_javascript do %>
  <script type= "text/javascript">
    your script here
  </script> 
<% end %>
```

套用在 sidebar 上

这招也可以用在 sidebar 上。很多内容网站里面常常需要放置侧边栏广告，而这些网站通常有严重的 performace issue，原因是它们的 sidebar 都是这样被设计的：

```erb
<div class="main">
  main content
</div>

<div class="sidebar">
  <% case @ad_type %>
  <% when foo %>
    <%= render "ad/foo"%>
  <% when bar %>
    <%= render "ad/bar"%>
  <% else %>
    <%= render "ad/default"%>
  <% end %>
</div>
```

其实用 yield 就可以巧妙的避开这种问题。将 View 改成

```erb
<div class="main">
  <%= yield %>
</div>

<div class="sidebar">
  <%= yield :sidebar %>
</div>
```

再把各个 view 里面需要呼叫的 sidebar 拆开独立呼叫即可

```erb
main content

<%= content_for :sidebar do %>
  <%= render "ad/foo"%>
<% end %>
```

## 12. Decoration in Controller

有些开发者学到了 yield 这招，就会开始觉得这招实在太棒了，觉得应该可以开始把 Logic 拆散在 View 里面。如把 meta 定义在 View 里面：

```erb
<%= content_for :meta do %>
  <meta content="xdite's blog" name="description">
  <meta content="Blog.XDite.net" property="og:title">
<% end %>
```

其实 过犹不及 也是不好的。如果是关于 meta 的部分，放在 Controller 里面其实是比较整理和好收纳的。反而可以

* 清楚的标明这个 action 的作用
* 避免逻辑散落。

```ruby
def show
    @blog = current_blog
    drop_blog_title @blog.name             # blog的name, meta中的属性
    drop_blog_descption @blog.description  # blog中描述，meta中属性
end

<%= stylesheet_tag "application" %>
<%= render_page_title %>
<%= render_page_descrption %>
```
> 理解:  meta主要是用来做seo的 - 个人理解

## 13. Decoration using I18n

大家对 Rails 的 I18n 机制的印象都是「作翻译」，其实 I18n 也可以拿来做包装 "Decoration"。如：

```ruby
def render_user_geneder(user)
  if user.gender == "male"
    "男 (Male)"
  else
    "女 (Female)"
  end
end
# 与上述代码功能相同，用来翻译，t函数是I18n提供的，
def render_user_gender(user)
  I18n.t("users.gender_desc.#{user.geneder}")
end
```

这样的情景其实也被可以套用在这种 yes/no ( true/false) 的场景：

```ruby
def render_book_purchase_option(book)
  if book.aviable_for_purchase?
    "Yes"
  else
    "No"
  end
end
```

善用 I18n，可以节省不少装饰用的程序。

以下的重点是Object-Oriented View。

## 14. Decorate using Decorator ( don’t put everything in model )

在前面我们介绍了几个手法，包括 将 Logic 收纳到 Helper 里面 ：

```ruby
def render_article_publish_status(article)
  if article.published?
    "Published at #{article.published_at.strftime('%A, %B %e')}"
  else
    "Unpublished"
  end
end
```

以及 将 Helper 里面的 Logic 重新整理到 Model ：

```ruby
class Article < ActiveRecord::Base
  def human_publish_status
    if published?
      "Published at #{article.published_at.strftime('%A, %B %e')}"
    else
      "Unpublished"
    end
  end
end
```

但是，再怎么整理，Model 还是会肥起来：

```ruby
class Article < ActiveRecord::Base 
  def human_publish_status
  end

  def human_publish_time
  end

  def human_author_name
  end

  ........
end
```

最后你只好把这些 Logic 又抽出成 Module：

```ruby
class Article < ActiveRecord::Base
  include HumanArticleAttributes
end
```

等等...这样好像有很大的问题？ 这些程序其实大部分都是 View 里面的 Logic，怎么到最后都变成 Model 里面的东西。

### Drapper ( Decorators/View-Models for Rails Applications )

我们可以用 Decorators/View-Models 解决这样的问题。因为这本来就是属于「View 层次」的东西。

有一个还不错的 Gem 叫 [Draper](https://github.com/drapergem/draper) 可以进行这样的抽象整理。

其实开发者最希望 View 里面只要有一行

    <%= @article.publication_status %>

我们可以透过 Draper 的 DSL，做到这样的封装。

```ruby
class ArticleDecorator < Draper::Decorator
  delegate_all

  def publication_status
    if published?
      "Published at #{published_at}"
    else
      "Unpublished"
    end
  end

  def published_at
    object.published_at.strftime("%A, %B %e")
  end
end
```

然后在 Controller 里面呼叫 decorate 就可以了

```ruby
def show
  @article = Article.find(params[:id]).decorate
end
```

## 15. Decoration using View Object

另外一种作法是把 View 里面复杂的逻辑抽成 View Object

这是一个 event 页面。在这个页面里面，如果当前 User 是 event host，则显示 "You"，否则显示 Host name。且参加者里面也要剔除当前 User。

```erb
<dl class="event-detail">
  <dt>Event Host</dt>
  <dd>
    <% if @event.host == current_user %>
      You
    <% else %>
      <%= @event.host.name %>
    <% end %>
  </dd>
  <dt>Participants</dt>
  <dd><%= @event.participants.reject { |p| p == current_user }.map(&:name).join(", ") %></dd>
</dl>
```

写成 Helper 实在是有点啰唆。我们不如改用 View Object 进行整理。

```ruby
class EventDetailView
  def initialize(template, event, current_user)
    @template = template
    @event = event
    @current_user = current_user
  end

  def host
    if @event.host == @current_user
      "You"
    else
      @event.host.name
    end
  end

  def participant_names
    participants.map(&:name).join(", ")
  end


  private

  def participants
    @event.participants.reject { |p| p == @current_user }
  end
end
```

则 View 就可以很漂亮的被简化成以下：

```erb
<dl class="event-detail">
  <dt>Host</dt>
  <dd><%= event_detail.host %></dd>
  <dt>Participants</dt>
  <dd><%= event_detail.participant_names %></dd>
</dl>
```

## 16. Form Builder

有时候我们为了排版 Form，不得不在 Form 里面也穿插一些 HTML 作 styling。

```erb
<%= form_for @user do |form| %>
  <div class="field">
    <%= form.label :name %>
    <%= form.text_field :name %>
  </div>

  <div class="field">
    <%= form.label :email %>
    <%= form.text_field :email %>
  </div>
<% end %>
```

但要写十几遍 `<div class="field">` 是一件很烦人的事。我们最希望的是，其实 View 里面只要这样写就 OK 了：

```erb
<%= form_for @user, :builder => HandcraftBuilder do |form| %>
  <%= form.custom_text_field :name %>
  <%= form.custom_text_field :email %>
<% end %>
```

这样的烦恼可以透过客制 Form Builder 解决：

```ruby
class HandcraftBuilder < ActionView::Helpers::FormBuilder
  def custom_text_field(attribute, options = {})
    @template.content_tag(:div, class: "field") do
      label(attribute) + text_field(attribute, options)
    end
  end
end
```
其他 Form Builder

- [simple_form](https://github.com/plataformatec/simple_form)
- [bootstrap_form](https://github.com/bootstrap-ruby/rails-bootstrap-forms)

不过现在还需要自己写 Form Builder 吗？其实机会蛮少了。主要的原因是如热门的 Framework： [Bootstrap](http://getbootstrap.com/) 有专属的 gem [bootstrap_form](https://github.com/bootstrap-ruby/rails-bootstrap-forms) 。而 simple_form 也提供 template ，透过 API 就可以轻松客制出一个 Form Builder。

> 表单构建器, 从事web之后，发现连接(link)和表单(form)都很重要。

## 17. Form Object (wrap logic in FORM, not in model nor in controller)

Form Object 是一个比较新的概念。它的想法是，其实表单的逻辑验证不应该发生在 Model 里面也不应该发生在 Controller 里面。

我们可以重新设计一个 Form Object，使用 ActiveModel 的部份 API 将逻辑重新包装，塞进 Form Builder 里面：

详细手法可以见这篇文章： [Form-backing objects for fun and profit](http://pivotallabs.com/form-backing-objects-for-fun-and-profit/)

```ruby
class Forms::Registration

  # ActiveModel plumbing to make `form_for` work
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def persisted?
    false
  end

 .....
end
```

这巧妙的解决了一些问题。比如让人很烦的 massive assignment issue（ 其实使用 `strong_parameter` 也会让人心情烦躁）。而且 `strong_parameter` 并没有办法解决这样的问题：

```erb
<%= simple_form_for @registration, :url => registrations_path, :as => :registration do |f| %>
  <%= f.input :name %>
  <%= f.input :email %>

  <label class="checkbox">
    <%= check_box_tag :terms_of_service %>
    I accept the <%= link_to("Terms of Service ", "/pages/tos") %>
  </label>
  <%= f.submit %>
<% end %>
```

有时候我们必须要在注册表单上，多加一个 check_box ，确认使用者同意注册条款。而 controller 就会变得这么恶心。

```ruby
def create
  if params[:terms_of_service]
    if @regfistration.save
      redirect_to root_path
    else
      render :new
    end
  else
    render :new
  end
end
```

而这么恶心的 controller 如果又再加上 captcha 或是一些客制选项，那就又会变得更恐怖了。不过 Form Object 的设计门槛也不是很低。

所以 cells 的作者又推出了这么一个 Gem : [Reform](https://github.com/apotonick/reform) ，简化 Form Object 的包装。

### Reform (Decouples your models from form validation, presentation and workflows.)

透过 Reform ，刚刚的 Logic 可以被简化成:

```ruby
class RegistrationForm < Reform::Form
  property :name
  property :email
  property :term_of_service

  validates :term_of_service, :presence => true
end
```

而 controller 里面又可以重新变会成漂漂亮亮的一层 if/else ：

```ruby
def create
  if @form.validate(params[:registration])
    @form.save
  else
    render :new
  end
end
```

## 18. Policy Object / Rule Engine (centralize permission control)

这是这一个系列的最后一招。在设计 Application 的时候，我们常要面对权限的设计封装问题，如：

```ruby
def render_post_edit_option(post)
  if post.user == current_user
    render :partial => "post/edit_bar"
  end
end
```

当权限只有 current_user 时还没有什么问题。不过权限通常是会膨胀下去的：

```ruby
def render_post_edit_option(post)
  if post.user == current_user || current_user.admin? 
    render :partial => "post/edit_bar"
  end
end
```

多一个 admin? 还不打紧，但事情往往没那么简单，过不久可能又会生出一个 moderator?

```ruby
def render_post_edit_option(post)
  if post.user == current_user || current_user.admin? || current_user.moderator?
    render :partial => "post/edit_bar"
  end
end
```

整串逻辑就变得又臭又长。最麻烦的是除了 View 之外，Controller 其实也是需要配合权限检查的：

```ruby
class PostController < ApplicationController
  before_filter :check_permission, :only => [:edit]
  
  def edit
    @post = Post.find(params[:id])
  end
end
```

### Cancan (Authorization Gem for Ruby on Rails)

[cancan](https://github.com/ryanb/cancan) 是最常被想到的一个整理的招数。透过 Rule Engine 的结构，整理权限：

```ruby
<% if can? :update, @post %>
   <%= render :partial => "post/edit_bar" %>
<% end %>

class Ability
  include CanCan::Ability

  def initialize(user)

    if user.blank?
      # not logged in
      cannot :manage, :all
    elsif user.has_role?(:admin)
      can :manage, :all
    elsif user.has_role?(:moderator)
      can :manage, Post
    else
      can :update, Post do |post|
        (post.user_id == user.id)
      end
    end
  end
end
```

我之前曾经写过一个 Cancan 系列，如果你有兴趣深入把玩 Cancan 的话，以下是系列连结：

* [Cancan 实现角色权限设计的最佳实践(1)](http://blog.xdite.net/posts/2012/07/30/cancan-rule-engine-authorization-based-library-1/)
* [Cancan 实现角色权限设计的最佳实践(2)](http://blog.xdite.net/posts/2012/07/30/cancan-rule-engine-authorization-based-library-2/)
* [Cancan 实现角色权限设计的最佳实践(3)](http://blog.xdite.net/posts/2012/07/30/cancan-rule-engine-authorization-based-library-3/)

### Pundit (Minimal authorization through OO design and pure Ruby classes)

不过 cancan 这种 Rule Engine 式的设计常被开发者嫌过度笨重。最近还新诞生了一种设计手法，利用 Policy Object 对于权限进行整理，其中有一个 gem : [pundit](https://github.com/elabs/pundit) 算做得蛮不错的。

Pundit 的想法是把单独的一组 logic 抽取出来，放在 app/policies 下。

```ruby
class PostPolicy
  attr_reader :user, :post

  def initialize(user, post)
    @user = user
    @post = post
  end

  def edit?
    user.admin? || user.moderator?
  end
end
```

而在 View 里面单独使用 policy object 验证：

```erb
<% if policy(@post).edit? %>
  <%= render :partial => "post/edit_bar" %>
<% end %>
```

controller 里面也只要 include Pundit ，就可以套用逻辑。

```ruby
class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery
end
```

## Summary

总结以上 18 个设计手法，看似复杂，其实原则不外乎：

*  Always assume things need to be decorated (永远假设东西必须要被装饰)
*  Extract logic into methods / classes ( 将逻辑封装成 method 或者 class )
*  Avoid perform query in view/helper ( 尽量避免在 view/helper 里面进行资料查询 )
*  When things get complicated, build a new control center （当事情变得复杂，不要拘泥于旧的手段，找一个新的中心重新整理控制）

掌握这些原则，就可以尽量把 View 整理的干干净净。

## 参考

在撰写以上内容时，我的参考内容有：

*  http://blog.xdite.net （相当多年来的经验积累，很多技巧以前都有讲过）
*  https://github.com/bloudermilk/maintainable_templates
*  http://pivotallabs.com/form-backing-objects-for-fun-and-profit/
*  http://saturnflyer.com/blog/jim/2013/10/21/how-to-make-your-code-imply-responsibilities/
*  http://objectsonrails.com/

## 后记

鼓动Rich在Learnpub上购买这本书，结果发现和上面的文章中内容一致。看来，给xdite捐钱了，算了，就当是学费吧。
