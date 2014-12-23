---
layout: post
title: Maintainable Templates
category: rails, templates
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

### Traits of a Decorator

* Wraps a single object
* Transparent interface
* Forwards methods to original object

In our case:

* Adds presentational logic to models without affecting the model itself

### Implementing a Decorator in Ruby

```ruby
class Decorator
  def initialize(component)
    @component = component
  end

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

### Credit Card Decorator

```ruby
class CreditCardDecorator < Decorator
  def masked_number
    "XXXX-XXXX-XXXX-" + number[-4..-1]
  end

  # ... other presentational methods
end
```

### Instantiating the decorator

```ruby
class CreditCardsController < ApplicationController
  def show
    @credit_card = CreditCardDecorator.new(
      current_user.credit_cards.find(params[:id])
    )
  end
end
```

### Using the decorator

```erb
<p>
  Thanks for ordering! Your purchase has been billed to your credit card:
  <strong><%= @credit_card.masked_number %></strong>
</p>
```

Mmmm, that's nice.

### When to decorate

Presentation logic that relates directly to a single instance of a model.

### Draper

Implementing basic decorators is easy, but [Draper][draper] adds a few helpful
features:

* Access to the view context
* Easily decorate collections
* Pretends to be decorated object (helpful for `form_for` and such)
* Easily decorate associations

[draper]: https://github.com/drapergem/draper

## Complex views

Unique and/or complex UI behavior will quickly outgrow helpers.

### Complex view example

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

### Presentation Model

> The essence of a Presentation Model is of a fully self-contained class that
> represents all the data and behavior of the UI window, but without any of the
> controls used to render that UI on the screen. A view then simply projects the
> state of the presentation model onto the glass.

<cite>[Martin Fowler][presentation_model]</cite>

[presentation_model]: http://martinfowler.com/eaaDev/PresentationModel.html

### Learning from JavaScript libraries

Thanks, Backbone.

### Designing a view object

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

### Story summary template

```erb
<dl class="story-summary">
  <dt>Assigned to</dt>
  <dd><%= story_summary.assigned_user %></dd>
  <dt>Participants</dt>
  <dd><%= story_summary.participant_names %></dd>
</dl>
```

### Helpers to set up view objects

```ruby
module StoriesHelper
  def story_summary(story)
    StorySummaryView.new(self, story, current_user)
  end
end
```

In our calling view:

```erb
<%= story_summary(@story) %>
```

## Form Builders

Rails comes with View Objects.

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

### Defining a custom FormBuilder

```ruby
class FancyFormBuilder < ActionView::Helpers::FormBuilder
  def fancy_text_field(attribute, options = {})
    @template.content_tag(:div, class: "form-field") do
      label(attribute) + text_field(attribute, options)
    end
  end
nd
```

### Rendering the custom builder

```erb
<%= form_for @user, builder: FancyFormBuilder do |form| %>
  <%= form.fancy_text_field :name %>
  <%= form.fancy_text_field :email %>
<% end %>
```

## Other tips

* Use i18n
* Find gems to do this work for you (eg. [simple_form][simple_form],
  [table_cloth][tables])

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
