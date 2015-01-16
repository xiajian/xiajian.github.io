---
layout: post
title: "关于public_activity gem包 "
description: "public_activity, rails, gem包"
category: gem
---

## 前言

在手机网站项目中，看到一个奇怪的目录`public_activity/`，该目录下只有部分视图，找了一圈没有找到其控制器，在路由中也没有。向前辈
请教，得知这是一个gem包。以下是对于该gem包的认识和了解。

## 简介

`public_activity`为ActiveRecord, Mongoid 3 以及 MongoMapper模型提供简单方便的活动追踪。其应用场景是，但记录改变或创建时，给用户发送记录的活动，其行为类似github。简单理解，就是记录变更+消息推送。

gem包的在线演示版地址: <http://public-activity-example.herokuapp.com/feed>

## 使用

首先，安装`public_activity`，存在两种方法: 

其一，`gem install public_activity`。

其二，在Gemfile中，加入`gem 'public_activity'`。

其次，设置数据库。

默认情况下，`public_activity`使用ActiveRecord，也可以使用`Mongoid`或`MongoMapper`。可以在应用程序中，创建一个initializer的文件，其内容如下: 

```ruby
# config/initializers/public_activity.rb
PublicActivity::Config.set do
  orm :[mongo_mapper|mongoid]
end
```

对于ActiveRecord，还需要生成和运行迁移(RDBMS和NoSQL的区别): 

```sh
rails g public_activity:migration
rake db:migrate
```

然后，配置模型。

需要在模型中include `PublicActivity::Model`，并添加`tracked`方法到模型中: 

对于ActiveRecord，Model中添加追踪的方式如下: 

```ruby
class Article < ActiveRecord::Base
  include PublicActivity::Model
  tracked
end
```

对于Mongoid: 

```ruby
class Article
  include Mongoid::Document
  include PublicActivity::Model
  tracked
end
```

对于MongoMapper:

```ruby
class Article
  include MongoMapper::Document
  include PublicActivity::Model
  tracked
end
```

默认情况下，CRUD的活动都会被记录到活动表中。当然，这些活动记录的基本需求。

如果不想要`#tracked`方法，但是需要`#create_activity`，可以include Common模块，而不是Model。

通过设置所需的参数，并追踪的模型上触发`create_activity`，从而触发定制化的活动: 

```ruby
@article.create_activity key: 'article.commented_on', owner: current_user
```

更多关于定制化的信息，可以参考<http://www.rubydoc.info/gems/public_activity/PublicActivity/Common:create_activity>

最后，显示活动，这里就是需要着重研究的地方，因为前面的都已经设置好了。

### 显示活动

为了显示活动，可以通过简单查询`PublicActivity::Activity`模型: 

```ruby
# 某通知控制器
def index
  @activities = PublicActivity::Activity.all
end
```

然后，在对应的视图中，添加如下的行: 

```erb
<%= render_activities(@activities) %>
```

注意，`render_activities`是`render_activity`的别名，`render_activity`是视图模板辅助方法。`render_activity(activity)`也可写作为`activity.render(self)`， 都是一个意思。

**布局(layouts)**

可以给`activity#render`和`#render_activity`方法传递选项，其内部是调用`render_partial`方法。布局的有效例子是，将活动包装在布局中，其中包含活动的公共元素，比如: 时间戳、拥有者的头像等。

活动将使用`app/views/layouts/_activity.erb`中的布局。注意，活动的布局都是局部视图，需要使用`_`前缀。

**局部变量(locals)**
 
有时，需要传递一些额外的局部变量，可以通过如下的方法:

```erb
<%= render_activity(@activity, locals: {friends: current_user.friends} %>
```

注意: 在1.4.0之前，通过选项hash传递变量，1.4.0之后，推荐使用`:locals`方法，这样不会覆盖数据库中的activity的变量。

**活动视图(Activity views)**

`public_activity`在`app/views/public_activity`目录下，查找视图。例如，如果存在`:key`设为`"activity.user.changed_avatar"`的活动，gem包将在名为`app/views/public_activity/user/_changed_avatar.(erb|haml|slim|something_else)`的部分视图。

如果，视图文件不存在，`public_activity`将回退到之前的行为中，并尝试使用`I18n#translate`方法翻译活动的`:key`

### i18n

翻译使用`#text`方法，因此，可以传递可选的hash选项。当没有提供视图模板时，`#render`方法使用翻译。可以通过给`#render_activity`或`#render`传递`{display: :i18n}`来渲染纯的i18n字符串。

翻译应该放置到`.yml`文件中，渲染纯字符串I18n例子的结构如下:

```
activity:
  article:
    create: 'Article has been created'
    update: 'Someone has edited the article'
    destroy: 'Some user removed an article!'
```

上述文件的结构对`"activity.article.create"`或`"article.create"`有效，这里的`"activity."`部分是可选的。

## 测试(Testing)

For RSpec you can first disable `public_activity` and add the `test_helper` in
the `spec_helper.rb` with

```ruby
#spec_helper.rb
require 'public_activity/testing'

PublicActivity.enabled = false
```

In your specs you can then blockwise decide wether to turn `public_activity` on
or off.

```ruby
# file_spec.rb
PublicActivity.with_tracking do
  # your test code goes here
end

PublicActivity.without_tracking do
  # your test code goes here
end
```

## 文档和例子

更多文档参考<http://rubydoc.info/gems/public_activity/index>

更多例子参考: 

* [[How to] 默认设置活动的拥有者为current_user](https://github.com/pokonski/public_activity/wiki/%5BHow-to%5D-Set-the-Activity's-owner-to-current_user-by-default)
* [[How to] 全局或为某个类禁用追踪](https://github.com/pokonski/public_activity/wiki/%5BHow-to%5D-Disable-tracking-for-a-class-or-globally)
* [[How to] 常见定制化的活动](https://github.com/pokonski/public_activity/wiki/%5BHow-to%5D-Create-custom-activities)
* [[How to] 在活动上使用自定义的作用域](https://github.com/pokonski/public_activity/wiki/%5BHow-to%5D-Use-custom-fields-on-Activity)

## 后记

`public_activity`其实就是监视某些模型的变化，然后生成相应的记录，最后，其中包含了一些关于视图方面的东西。
