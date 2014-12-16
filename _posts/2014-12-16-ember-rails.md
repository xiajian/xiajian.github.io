---
layout: post
title: ember-rails
---

## 前言

为了研究如何在Rails中使用[ember-rails](https://github.com/emberjs/ember-rails)，特地去研究ember-rails，并设置一定的目标，替换公司交易页面js(deal.js-2277行和forex.js-1518行，很明显的单页面复杂js)，一旦完成这件事情，近期对js的投入就没有白费。

我的人生一直很失败，无论如何，这次一定要成功。每次都这么对自己说一定要成功，放弃的时候，说算了，何必这么较真。然后下一次继续说 这次一定要成功。感觉如同死循环一般，这次一定要成功。说到底，是没有杀身成仁的觉悟。

## 简介

[ember-rails](https://github.com/emberjs/ember-rails)使得在Rails 3.1+中开发复杂的Ember.js程序非常的容易。该Gem包包含如下的功能: 

* 在构建asset pipeline时，预编译handlebars模板
* 包含开发和生产环境的Ember拷贝，Ember Data以及Handlebars
* 包含Ember Data与[ActiveModel::Serializer](https://github.com/rails-api/active_model_serializers)的集成

**注**: [ActiveModel::Serializer]()是[rails-api](https://github.com/rails-api/rails-api)的组成部分。

具体的样例: <https://github.com/keithpitt/ember-rails-example>。简单的教程: [Beginning Ember.js on Rails](http://www.cerebris.com/blog/2012/01/24/beginning-ember-js-on-rails-part-1/)。

## 起步

1. 在Gemfile中添加gem包

  ```
  gem 'ember-rails'
  gem 'ember-source', '~> 1.9.0' # or the version you need
  ```
2. 运行`bundle install`
3. 然后生成应用程序结构: `rails generate ember:bootstrap`。其生成的结构大概是这样的: 

  ```
  app/assets/javascripts/application.js.coffee
  app/assets/javascripts/models
  app/assets/javascripts/models/.gitkeep
  app/assets/javascripts/controllers
  app/assets/javascripts/controllers/.gitkeep
  app/assets/javascripts/views
  app/assets/javascripts/views/.gitkeep
  app/assets/javascripts/routes
  app/assets/javascripts/routes/.gitkeep
  app/assets/javascripts/helpers
  app/assets/javascripts/helpers/.gitkeep
  app/assets/javascripts/components
  app/assets/javascripts/components/.gitkeep
  app/assets/javascripts/templates
  app/assets/javascripts/templates/.gitkeep
  app/assets/javascripts/templates/components
  app/assets/javascripts/templates/components/.gitkeep
  app/assets/javascripts/mixins
  app/assets/javascripts/mixins/.gitkeep
  app/assets/javascripts/sample_app.js.coffee
  app/assets/javascripts/router.js.coffee
  app/assets/javascripts/store.js.coffee
  ```

4. 如果服务器在运行，重启服务器

## 从scratch中构建新项目

Rails支持从Ruby源代码文件中构建应用程序。为了构建一个以Ember为中心的Rails应用程序，可以简单输入如下的命令: 

```sh
rails new my_app -m http://emberjs.com/edge_template.rb
```

更多内容参考[Rails应用模板](http://edgeguides.rubyonrails.org/rails_application_templates.html)和[edge_template.rb](https://github.com/emberjs/website/blob/master/source/edge_template.rb)

注意： 

为了安装最新的ember和ember-data，可以使用`rails generate ember:install`。ember.js的官方教程中就是使用的最新的版本。

安装完最新的版本后，可能需要清除一下数据。此外，ember-rails包含了一些bootstrap生成器的选项: 

```
--ember-path or -d   # custom ember path
--skip-git or -g     # skip git keeps
--javascript-engine  # engine for javascript (js, coffee or em)
--app-name or -n     # custom ember app name
```

## CoffeeScript支持

在Gemfile中添加coffee-rails: 

    gem 'coffee-rails'

并在上述第四步骤中，添加额外的标志选项: 

    rails g ember:bootstrap -g --javascript-engine coffee

## EmberScript支持

[EmberScript](http://emberscript.com/)是CoffeeScript的方言，其中包含了对计算属性的支持(未显式申明)，class/extends语法，支持观察者和mixins语法。

为了获取EmberScript的支持，确保在Gemfile中添加: 

    gem 'ember_script-rails', :github => 'ghempton/ember-script-rails'

可通过`--javascript-engine=em`指定EmberScript作为生成器，也可通过variant变量全局指定。

## 配置选项

如下的选项可在应用程序或环境的层面的文件中进行配置，即`config/application.rb`和`config/environments/development.rb`: 

* `config.ember.variant` : 决定Ember变体的使用，有效的选项为: `:development`, `:production`
* `config.ember.app_name` : 对所有的生成器指定默认的应用程序
* `config.ember.ember_path` : 对所有生成器指定默认的root路径
* `config.handlebars.precompile` : 启动或禁止预编译
* `config.handlebars.output_type` : 配置输出的样式，可用的选项为`:amd `和`:global`，默认值为: `:global`
* `config.handlebars.templates_root` : 设置模板查找的根路径，默认值为: `templates`
* `config.handlebars.templates_path_separator` : 模板使用的路径分隔器，默认值为'/'

**注意**:  在挂载的engine中，`ember-rails`不是识别任何配置，最好使用命令行。

## 使用特性标签启动特性


See [the guide](http://emberjs.com/guides/configuring-ember/feature-flags/#toc_flagging-details) and check [features.json](https://github.com/emberjs/ember.js/blob/master/features.json) for the version of Ember you're using.

If a feature is set to false, you will need to compile ember from source yourself to include it.

### Important note for projects that render JSON responses

ember-rails includes [active_model_serializers](https://github.com/rails-api/active_model_serializers) which affects how ActiveModel and ActiveRecord objects get serialized to JSON, such as when using `render json:` or `respond_with`. By default active_model_serializers adds root elements to these responses (such as adding `{"posts": [...]}` for `render json: @posts`) which will affect the structure of your JSON responses.

To disable this effect on your JSON responses, put this in an initializer:
```Ruby
# Stop active_model_serializers from adding root elements to JSON responses.
ActiveModel::Serializer.root = false
ActiveModel::ArraySerializer.root = false
```

See the [active_model_serializers](https://github.com/rails-api/active_model_serializers) documentation for a more complete understanding of other effects this dependency might have on your app.

## Architecture

Ember does not require an organized file structure. However, ember-rails allows you
to use `rails g ember:bootstrap` to create the following directory structure under `app/assets/javascripts`:

```
├── components
├── controllers
├── helpers
├── mixins
├── models
├── practicality.js.coffee
├── router.js.coffee
├── routes
├── store.js.coffee
├── templates
│   └── components
└── views
```

Additionally, it will add the following lines to `app/assets/javascripts/application.js`.
By default, it uses the Rails Application's name and creates an `rails_app_name.js`
file to set up application namespace and initial requires:

```javascript
//= require handlebars
//= require ember
//= require ember-data
//= require_self
//= require rails_app_name
RailsAppName = Ember.Application.create();
```

*Example:*

    rails g ember:bootstrap
      insert  app/assets/javascripts/application.js
      create  app/assets/javascripts/models
      create  app/assets/javascripts/models/.gitkeep
      create  app/assets/javascripts/controllers
      create  app/assets/javascripts/controllers/.gitkeep
      create  app/assets/javascripts/views
      create  app/assets/javascripts/views/.gitkeep
      create  app/assets/javascripts/helpers
      create  app/assets/javascripts/helpers/.gitkeep
      create  app/assets/javascripts/components
      create  app/assets/javascripts/components/.gitkeep
      create  app/assets/javascripts/templates
      create  app/assets/javascripts/templates/.gitkeep
      create  app/assets/javascripts/templates/components
      create  app/assets/javascripts/templates/components/.gitkeep
      create  app/assets/javascripts/app.js

If you want to avoid `.gitkeep` files, use the `skip git` option like
this: `rails g ember:bootstrap -g`.

Ask Rails to serve HandlebarsJS and pre-compile templates to Ember
by putting each template in a dedicated ".js.hjs", ".hbs" or ".handlebars" file
(e.g. `app/assets/javascripts/templates/admin_panel.handlebars`)
and including the assets in your layout:

    <%= javascript_include_tag "templates/admin_panel" %>

If you want to avoid the `templates` prefix, set the `templates_root` option in your application configuration block:

    config.handlebars.templates_root = 'ember_templates'

If you store templates in a file like `app/assets/javascripts/ember_templates/admin_panel.handlebars` after setting the above config,
it will be made available to Ember as the `admin_panel` template.

Note: you must clear the local sprockets cache after modifying `templates_root`, stored by default in `tmp/cache/assets`

Default behavior for ember-rails is to precompile handlebars templates.
If you don't want this behavior you can turn it off in your application configuration (or per environment in: `config/environments/development.rb`) block:

    config.handlebars.precompile = false

_(Note: you must clear the local sprockets cache if you disable precompilation, stored by default in `tmp/cache/assets`)_

Bundle all templates together thanks to Sprockets,
e.g create `app/assets/javascripts/templates/all.js` with:

    //= require_tree .

Now a single line in the layout loads everything:

    <%= javascript_include_tag "templates/all" %>

If you use Slim or Haml templates, you can use the handlebars filter :

    handlebars:
        <button {{action anActionName}}>OK</button>

It will be translated as :

    <script type="text/x-handlebars">
        <button {{action anActionName}}>OK</button>
    </script>

### Note about ember components

When necessary, ember-rails adheres to a conventional folder structure. To create an ember component you must define the handlebars file *inside* the *components* folder under the templates folder of your project to properly register your handlebars component file.

*Example*

Given the following folder structure:

```
├── components
├── controllers
├── helpers
├── mixins
├── models
├── practicality.js.coffee
├── router.js.coffee
├── routes
├── store.js.coffee
├── templates
│   └── components
│       └── my-component.handlebars
└── views
```

and a `my-component.handlebars` file with the following contents:

    <h1>My Component</h1>

It will produce the following handlebars output:

    <script type="text/x-handlebars" id="components/my-component">
      <h1>My Component</h1>
    </script>

You can reference your component inside your other handlebars template files by the handlebars file name:

     {{ my-component }}

### A note about upgrading ember-rails and components
The ember-rails project now includes generators for components. If you have an existing project and need
to compile component files you will need to include the components folder as part of the asset pipeline.
A typical project expects two folders for *components* related code:

* `assets/javascripts/components/` to hold the component javascript source
* `assets/javascripts/templates/components/` to hold the handlebars templates for your components

Your asset pipeline require statements should include reference to both e.g.

RailsAppName.js
```
//= require_tree ./templates
//= require_tree ./components
```

or

RailsAppName.js.coffee
```
#= require_tree ./templates
#= require_tree ./components
```

These are automatically generated for you in new projects you when you run the `ember:bootstrap` generator.

## Specifying Different Versions of Ember/Handlebars/Ember-Data

By default, ember-rails ships with the latest version of
[Ember](https://rubygems.org/gems/ember-source/versions),
[Handlebars](https://rubygems.org/gems/handlebars-source/versions),
and [Ember-Data](https://rubygems.org/gems/ember-data-source/versions).

To specify a different version that'll be used for both template
precompilation and serving to the browser, you can specify the desired
version of one of the above-linked gems in the Gemfile, e.g.:

    gem 'ember-source', '1.7.0'

You can also specify versions of 'handlebars-source' and
'ember-data-source', but note that an appropriate 'handlebars-source'
will be automatically chosen depending on the version of 'ember-source'
that's specified.

You can also override the specific ember.js, handlebars.js, and
ember-data.js files that'll be `require`d by the Asset pipeline by
placing these files in `vendor/assets/ember/development` and
`vendor/assets/ember/production`, depending on the `config.ember.variant`
you've specified in your app's configuration, e.g.:

    config.ember.variant = :production
    #config.ember.variant = :development

## Updating Ember

If at any point you need to update Ember.js from any of the release channels, you can do that with

    rails generate ember:install --channel=<channel>

This will fetch both Ember.js and Ember Data from [http://builds.emberjs.com/](http://builds.emberjs.com/) and copy to the right directory. You can choose between the following channels:
* canary - This references the 'master' branch and is not recommended for production use.
* beta - This references the 'beta' branch, and will ultimately become the next stable version. It is not recommended for production use.
* release - This references the 'stable' branch, and is recommended for production use.

When you don't specify a channel, the release channel is used.

It is also possible to download a specific tagged release. To do this, use the following syntax:


    rails generate ember:install --tag=v1.2.0-beta.2 --ember

or for ember-data

    rails generate ember:install --tag=v1.0.0-beta.2 --ember-data

## Note on Patches/Pull Requests

1. Fork the project.
2. Make your feature addition or bug fix.
3. Add tests for it. This is important so I don't break it in a future version unintentionally.
4. Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
5. Send me a pull request. Bonus points for topic branches.
