---
layout: post
title: Maintainable Templates
category: rails
---

## 前言

由[Maintainable Rails View]()追溯到的资料，怎么说呢，原本是PPT的内容。收获是，原来存在可直接从Markdown转换为Slides的gem包。

## 正文

Rails应用中view的基础是布局。模板通常会被忽略。

不可维护的模板包含: 

* 重复标签
* 模板中包含逻辑(高度重复，难于测试)

好的设计师重复自己，好的程序员从不重复。

避免标签重复的方法: 

* 抽象接口组件
* 使用部分视图

## 程序中逻辑

重复逻辑实例:

```erb
<h3>Your Saved Credit Card</h3>

<dl>
  <dt>Number</dt>
  <dd>XXXX-XXXX-XXXX-<%= @credit_card.number[-4..-1] %></dd>
  <dt>Exp. Date</dt>
  <dd>
    <%= @credit_card.expiration_month %> / <%= @credit_card.expiration_year %>
  </dd>
</dl>
```

```erb
<p>
  Thanks for ordering! Your purchase has been billed to your credit card:
  <strong>XXXX-XXXX-XXXX-<%= @order.credit_card.number[-4..-1] %></strong>
</p>
```

解决方法: 使用 Helpers

## Helper

> View Helpers位于app/helpers，并提供views的代码片段的重用。

<cite>[Rails Guides][http://guides.rubyonrails.org/getting_started.html#view-helpers]</cite>

helpers的定义: 

```ruby
module CreditCardHelper
  def masked_credit_card_number(number)
    "XXXX-XXXX-XXXX-" + number[-4..-1]
  end
end
```

helpers的使用: 

```erb
<p>
  Thanks for ordering! Your purchase has been billed to your credit card:
  <strong><%= masked_credit_card_number(@credit_card.number) %></strong>
</p>
```

helpers可能出现问题

* 大项目中，会出现成**吨**的helper
* 难于组织
* 不适合复杂的逻辑
* 感觉怪怪的

此时，需要介绍另一种清理视图的方法，装饰者模式。

## Decorator Pattern

> [Decorators] 动态的给对象附加责任，其提供了比子类化更灵活的扩展功能的方式。

<cite>[Design Patterns: Elements of Reusable Object-Oriented Software][gang_of_four]</cite>

[gang_of_four]: http://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612

装饰者模式的特性: 

* 包装一个对象
* 透明接口
* 提取原始对象的方法

使用时机: 表象逻辑与模型的单个实例相关。

这里，可以提供装饰者模式，添加表象的逻辑而不必影响model本身。以下，是其在Ruby中的实现。

Decorator类的实现如下: 

```ruby
class Decorator
  def initialize(component)
    @component = component
  end

  # 使用method_missing方法，减低运行速度，用作父类的实现，不错的实践
  def method_missing(method, *arguments, &block)
    if @component.respond_to?(method)
      @component.send(method, *arguments, &block)
    else
      super
    end
  end

  def respond_to_missing?(method, *)
    @component.respond_to?(method) || super
  end
end
```

信用卡类的装饰者类:

```ruby
class CreditCardDecorator < Decorator
  def masked_number
    "XXXX-XXXX-XXXX-" + number[-4..-1]
  end

  # ... other presentational methods
end
```

实例化装饰者，使用装饰者的关键在于，使用装饰者，而不是原始的对象。

```ruby
class CreditCardsController < ApplicationController
  def show
    @credit_card = CreditCardDecorator.new(
      current_user.credit_cards.find(params[:id])
    )
  end
end
```

在视图中，使用装饰者提供的方法: 

```erb
<p>
  Thanks for ordering! Your purchase has been billed to your credit card:
  <strong><%= @credit_card.masked_number %></strong>
</p>
```

### Draper

Implementing basic decorators is easy, but [Draper][draper] adds a few helpful
features:

实现一个基本的装饰者相当的容易，但是，使用[Draper][draper]可以获得额外的好处: 

* 可在视图上下文访问
* 很方便的包装集合
* 假装成被装饰的对象(在`form_for`等方法中非常有用)
* 很容易的装饰关联

[draper]: https://github.com/drapergem/draper

## 复杂视图

独特的或复杂的UI行为，将使得helper迅速膨胀。

### 复杂视图的例子

```erb
<dl class="story-summary">
  <dt>Assigned to</dt>
  <dd>
    <% if @story.assigned_user == current_user %>
      You
    <% else %>
      <%= @story.assigned_user.name %>
    <% end %>
  </dd>
  <dt>Participants</dt>
  <dd><%= @story.participants.reject { |p| p == current_user }.map(&:name).join(", ") %></dd>
</dl>
```

### 演示模型(Presentation Model)

> 演示模型(Presentation Model)的本质是使用独立的类来表示用户界面所有数据和行为，但
> 不包含如何控制其在界面上的渲染。视图可以简单映射为演示模型的状态(A view then simply
> projects the state of the presentation model onto the glass.)。

<cite>[Martin Fowler][presentation_model]</cite>

[presentation_model]: http://martinfowler.com/eaaDev/PresentationModel.html

该模式和方法的实现，从[Backbone](http://backbonejs.org/)中偷学了不少。

视图对象的设计：

```ruby
class StorySummaryView
  def initialize(template, story, current_user)
    @template = template
    @story = story
    @current_user = current_user
  end

  def assigned_user
    if @story.assigned_user == @current_user
      "You"
    else
      @story.assigned_user.name
    end
  end

  def participant_names
    participants.map(&:name).join(", ")
  end

  def to_s
    @template.render(partial: "story_summary", object: self)
  end

  private

  def participants
    @story.participants.reject { |p| p == @current_user }
  end
end
```

Story summary模板:

```erb
<dl class="story-summary">
  <dt>Assigned to</dt>
  <dd><%= story_summary.assigned_user %></dd>
  <dt>Participants</dt>
  <dd><%= story_summary.participant_names %></dd>
</dl>
```

设置视图对象的辅助方法: 

```ruby
module StoriesHelper
  def story_summary(story)
    StorySummaryView.new(self, story, current_user)
  end
end
```

然后，在视图中调用: 

```erb
<%= story_summary(@story) %>
```

## Form Builders

Rails自带了一些View对象，比如，`form_for`。

注： 原来`form_for`是视图对象，如何理解Rails中的辅助方法？？ 难道，是要去阅读源代码!

### `form_for`

```erb
<%= form_for @user do |form| %>
  <div class="form-field">
    <%= form.label :name %>
    <%= form.text_field :name %>
  </div>

  <div class="form-field">
    <%= form.label :email %>
    <%= form.text_field :email %>
  </div>
<% end %>
```

定制化一个FormBuilder类: 

```ruby
class FancyFormBuilder < ActionView::Helpers::FormBuilder
  def fancy_text_field(attribute, options = {})
    @template.content_tag(:div, class: "form-field") do
      label(attribute) + text_field(attribute, options)
    end
  end
nd
```

以定制的builder渲染form: 

```erb
<%= form_for @user, builder: FancyFormBuilder do |form| %>
  <%= form.fancy_text_field :name %>
  <%= form.fancy_text_field :email %>
<% end %>
```

其他的一些建议: 

* 使用i18n
* 使用Gem包来创建Form视图对象(例如 [simple_form][simple_form] , [table_cloth][tables])

[simple_form]: https://github.com/plataformatec/simple_form
[tables]: https://github.com/bobbytables/table_cloth

## 进一步阅读

* [The Rails View][rails_view] (book)
* [Presentation Model][presentation_model] (article)
* [The Exibit Pattern][objects_on_rails] from Objects on Rails (book, free)
* [Presenter Pattern][presenter_pattern] (article)

[slides]: https://github.com/bloudermilk/maintainable_templates/blob/master/slides.md
[rails_view]: http://pragprog.com/book/warv/the-rails-view
[presentation_model]: http://martinfowler.com/eaaDev/PresentationModel.html
[objects_on_rails]: http://objectsonrails.com/#ID-2656c30c-080a-4a4e-a53e-4fbaad39c262
[presenter_pattern]: http://blog.jayfields.com/2007/03/rails-presenter-pattern.html
[slyde]: https://github.com/bloudermilk/slyde
