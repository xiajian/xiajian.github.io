---
layout: post
title: Gem包:devise
---

## 缘起
--

公司网站权限使用了devise，但一直不知道这个到底如何起作用的。今天，想知道为何全部网页的erb视图中都可以访问current_user这个变量时，使用git grep找了半天，都没有找到相应的定义。问过前辈后才
知道，这是由devise默认根据user模型生成的变量。于是，就想称这个机会了解一下devise，下面是对github上devise的readme的翻译和理解。

devise是灵活的基于warden（通用的基于Rack的授权框架）的授权解决方案。
特点:

-  Is Rack based;
-  Is a complete MVC solution based on Rails engines;
-  Allows you to have multiple models signed in at the same time;
-  Is based on a modularity concept: use just what you really need.

其本身由十个模块组成:

* [Database Authenticatable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/DatabaseAuthenticatable): encrypts and stores a password in the database to validate the authenticity of a user while signing in. The authentication can be done both through POST requests or HTTP Basic Authentication.
* 数据库授权: 加密并将密码存储在数据库中，用来在用户登录时进行权限验证。权限可以通过POST请求或者HTTP基本的权限验证。
* [Omniauthable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Omniauthable): adds Omniauth (https://github.com/intridea/omniauth) support.
* 授权: 添加了Omniauth的支持
* [Confirmable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Confirmable): sends emails with confirmation instructions and verifies whether an account is already confirmed during sign in.
* 验证: 发送带有验证的指示emails,验证登录的用户是否已验证过了。
* [Recoverable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Recoverable): resets the user password and sends reset instructions.
* 恢复: 重置用户密码并发送重置指南。
* [Registerable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Registerable): handles signing up users through a registration process, also allowing them to edit and destroy their account.
* 注册: 通过注册流程处理注册用户，并允许其编辑和删除用户。
* [Rememberable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Rememberable): manages generating and clearing a token for remembering the user from a saved cookie.
* 记忆：从保存的cookie中管理生成和清除的记号。
* [Trackable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Trackable): tracks sign in count, timestamps and IP address.
* 追踪: 追踪用户的登录的次数，时间戳和IP地址。
* [Timeoutable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Timeoutable): expires sessions that have no activity in a specified period of time.
* 时效: 在指定的时间之后将不活跃的session强制过期。
* [Validatable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Validatable): provides validations of email and password. It's optional and can be customized, so you're able to define your own validations.
* 有效性检查: 提供邮箱和密码的有效性检查。该模块可选且可定制，所以可以定义自己的有效性验证。
* [Lockable](http://rubydoc.info/github/plataformatec/devise/master/Devise/Models/Lockable): locks an account after a specified number of failed sign-in attempts. Can unlock via email or after a specified time period.
* 锁：在指定的登录尝试之后，锁定某个用户。并在特定时间或通过email解锁。

Devise在YARV上保证线程安全，支持JRuby的线程安装正在处理。

## 相关信息

### The Devise wiki

Devise Wiki中有更多额外的信息，一些how-to文章，以及很多常见问题的回答，请在看完README之后浏览wiki: 

https://github.com/plataformatec/devise/wiki

### Bug reports

If you discover a problem with Devise, we would like to know about it. However, we ask that you please review these guidelines before submitting a bug report:

如果发现devise任何问题，请联系如下地址: 

https://github.com/plataformatec/devise/wiki/Bug-reports

If you found a security bug, do *NOT* use the GitHub issue tracker. Send an email to opensource@plataformatec.com.br.

### Mailing list

If you have any questions, comments, or concerns, please use the Google Group instead of the GitHub issue tracker:

https://groups.google.com/group/plataformatec-devise

### RDocs

You can view the Devise documentation in RDoc format here:

http://rubydoc.info/github/plataformatec/devise/master/frames

If you need to use Devise with previous versions of Rails, you can always run "gem server" from the command line after you install the gem to access the old documentation.

### Example applications

There are a few example applications available on GitHub that demonstrate various features of Devise with different versions of Rails. You can view them here:

https://github.com/plataformatec/devise/wiki/Example-Applications

### Extensions

Our community has created a number of extensions that add functionality above and beyond what is included with Devise. You can view a list of available extensions and add your own here:

https://github.com/plataformatec/devise/wiki/Extensions

### Contributing

We hope that you will consider contributing to Devise. Please read this short overview for some information about how to get started:

https://github.com/plataformatec/devise/wiki/Contributing

You will usually want to write tests for your changes.  To run the test suite, go into Devise's top-level directory and run "bundle install" and "rake".  For the tests to pass, you will need to have a MongoDB server (version 2.0 or newer) running on your system.

## Starting with Rails?

If you are building your first Rails application, we recommend you to *not* use Devise. Devise requires a good understanding of the Rails Framework. In such cases, we advise you to start a simple authentication system from scratch, today we have two resources:

如果你正在构建你的第一个Rails应用程序，建议不要使用Devise。Devise需要对Rails框架拥有比较好的理解。在这种情况下，建议从零开始构建一个简单的权限系统。现在有两个资源：

* Michael Hartl's online book: http://www.railstutorial.org/book/demo_app#sec-modeling_demo_users
* Ryan Bates' Railscast: http://railscasts.com/episodes/250-authentication-from-scratch

Once you have solidified your understanding of Rails and authentication mechanisms, we assure you Devise will be very pleasant to work with. :)

一旦，对Rails以及权限机制拥有深入的理解，将会更为方便的使用Devise。

## Getting started

Devise 3.0 works with Rails 3.2 onwards. You can add it to your Gemfile with:

Devise和Rails 3.2配套使用。你可以将其添加到你的Gemfile中: 

{% highlight ruby %}
gem 'devise'
{% endhighlight %}

Run the bundle command to install it.

然后运行bundle命令来安装devise。

After you install Devise and add it to your Gemfile, you need to run the generator:

在安装完Devise之后，并将其添加到Gemfile中，然后需要运行生成器:

>  rails generate devise:install

The generator will install an initializer which describes ALL Devise's configuration options and you MUST take a look at it. When you are done, you are ready to add Devise to any of your models using the generator:

生成器将安装一个描述Devise所有配置选项的initializer，所以必须要仔细阅读。完成上述操作后，可以通过生成器将devise添加到任何模型中。

> rails generate devise MODEL

Replace MODEL with the class name used for the application’s users (it’s frequently `User` but could also be `Admin`). This will create a model (if one does not exist) and configure it with default Devise modules. The generator also configures your `config/routes.rb` file to point to the Devise controller.

将MODEL替换为应用程序中用户的类名(通常为User或Admin)。生成器将创建模型并以默认的Devise模块配置模型。生成器同样配置`config/routes.rb`，设置指向Devise控制器的路由。

Next, check the MODEL for any additional configuration options you might want to add, such as confirmable or lockable. If you add an option, be sure to inspect the migration file (created by the generator if your ORM supports them) and uncomment the appropriate section.  For example, if you add the confirmable option in the model, you'll need to uncomment the Confirmable section in the migration. Then run `rake db:migrate`

然后，检查模型并设置任何想要添加的配置选项，比如验证和锁。如果你添加了一个选项，确保审查迁移文件(如果ORM支持的话，由生成器创建)，并对相应的章节进行解注释。例如，想要在模型中添加验证选项，需要解注释迁移文件中的验证章节，然后运行`rake db:migrate`。

Next, you need to set up the default URL options for the Devise mailer in each environment. Here is a possible configuration for `config/environments/development.rb`:

接下来，需要在每种环境中为Devise邮箱启动默认的URL选项。下面是`config/environments/development.rb`中可能的配置选项:

{% highlight ruby %}
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
{% endhighlight %}

You should restart your application after changing Devise's configuration options. Otherwise you'll run into strange errors like users being unable to login and route helpers being undefined.

修改Devise配置选项后，需要重启应用。否则，就会遇到奇怪的错误比如，不能登录或者路由方法未定义。

### 控制器过滤器和辅助方法(Controller filters and helpers)

Devise will create some helpers to use inside your controllers and views. To set up a controller with user authentication, just add this before_action (assuming your devise model is 'User'):

Devise将会在控制器和视图中创建一些辅助方法。为了设置带用户权限的控制器，只需要添加如下的before_action(假设devise模型是User):

{% highlight ruby %}
before_action :authenticate_user!
{% endhighlight %}

If your devise model is something other than User, replace "_user" with "_yourmodel". The same logic applies to the instructions below.

如果你devise模式不是User，请用"yourmodel"替换替换"user"。相同的逻辑可以应用到剩余的指南中。

为了验证user是否登录，使用如下的辅助方法:

{% highlight ruby %}
user_signed_in?
{% endhighlight %}

如果当前存在用户登录，如下的辅助方法可用(这也是为何找不到current_user的定义):

{% highlight ruby %}
current_user
{% endhighlight %}

可以通过如下的scope访问会话session: 

{% highlight ruby %}
user_session
{% endhighlight %}

After signing in a user, confirming the account or updating the password, Devise will look for a scoped root path to redirect. For instance, for a `:user` resource, the `user_root_path` will be used if it exists, otherwise the default `root_path` will be used. This means that you need to set the root inside your routes:

在用户登录后，验证用户或者修改密码，Devise将寻找scoped的根节点路径来重定向。例如，对于:user资源，如果存在user_root_path则使用该路径。否则，使用默认的`root_path`。这意味着，需要在路由中设置root。

{% highlight ruby %}
root to: "home#index"
{% endhighlight %}

You can also override `after_sign_in_path_for` and `after_sign_out_path_for` to customize your redirect hooks.

可以通过覆盖after_sign_in_path_for和after_sign_out_path_for方法，定制重定向钩子方法。

Notice that if your Devise model is called `Member` instead of `User`, for example, then the helpers available are:

**注意**:如果你的应用程序为Member而不是User，如下的辅助类将可使用(应用程序中经常可以看到这些变量的身影): 

{% highlight ruby %}
before_action :authenticate_member!

member_signed_in?

current_member

member_session
{% endhighlight %}

### 配置模型(Configuring Models)

The Devise method in your models also accepts some options to configure its modules. For example, you can choose the cost of the encryption algorithm with:

Devise模型中的方法接受选项配置，配置其模块。例如，可以选择加密算法的花费(加密花费的时间越长，密码越难破解)。

{% highlight ruby %}
devise :database_authenticatable, :registerable, :confirmable, :recoverable, stretches: 20
{% endhighlight %}

Besides `:stretches`, you can define `:pepper`, `:encryptor`, `:confirm_within`, `:remember_for`, `:timeout_in`, `:unlock_in` among other options. For more details, see the initializer file that was created when you invoked the "devise:install" generator described above.

除了`:stretches`，也可以定义`:pepper`, `:encryptor`, `:confirm_within`, `:remember_for`, `:timeout_in`, `:unlock_in`以及其他的选项。更多细节参考调用"devise:install"创建的初始化文件。

### 强度参数(Strong Parameters)

When you customize your own views, you may end up adding new attributes to forms. Rails 4 moved the parameter sanitization from the model to the controller, causing Devise to handle this concern at the controller as well.

当定制自己的视图时，将以添加新的属性到forms中结束。Rails 4将参数处理从模型移动到控制器中，使得Devise也在控制器中处理参数 。

There are just three actions in Devise that allows any set of parameters to be passed down to the model, therefore requiring sanitization. Their names and the permitted parameters by default are:

Devise中只有三个方法允许任意设置传递给模型的参数 ，所以，这需要参数处理。他们的命名和限制参数默认为: 

* `sign_in` (`Devise::SessionsController#new`) - 只允许像email这样的授权键。
* `sign_up` (`Devise::RegistrationsController#create`) - 授权键加`password`和`password_confirmation`
* `account_update` (`Devise::RegistrationsController#update`) - 授权键加`password`、`password_confirmation`以及`current_password`

In case you want to permit additional parameters (the lazy way™) you can do with a simple before filter in your `ApplicationController`:

万一想要限制附加的参数，可以通过在`ApplicationController`中设置一个简单的过滤器：

{% highlight ruby %}
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username
  end
end
{% endhighlight %}

The above works for any additional fields where the parameters are simple scalar types. If you have nested attributes (say you're using `accepts_nested_attributes_for`), then you will need to tell devise about those nestings and types. Devise allows you to completely change Devise defaults or invoke custom behaviour by passing a block:

上述的工作的任何附加域中，参数是简单scalar类型。如果拥有嵌套属性(可以使用accepts_nested_attributes_for方法)，然后，告诉devise嵌套的类型。Devise允许可以完全改变Devise模型或者通过传递块调用定制的行为。

To permit simple scalar values for username and email, use this

为了允许usename和email的简单标量类型，可以使用如下的方法

{% highlight ruby %}
def configure_permitted_parameters
  devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :email) }
end
{% endhighlight %}

If you have some checkboxes that express the roles a user may take on registration, the browser will send those selected checkboxes as an array. An array is not one of Strong Parameters permitted scalars, so we need to configure Devise thusly:

如果在用户注册时有一些表现规则的checkbox，浏览器将会把选择的checkbox作为数组发出。数组并不是强参数限制的标量，因而，需要配置Devise:

{% highlight ruby %}
def configure_permitted_parameters
  devise_parameter_sanitizer.for(:sign_up) { |u| u.permit({ roles: [] }, :email, :password, :password_confirmation) }
end
{% endhighlight %}
For the list of permitted scalars, and how to declare permitted keys in nested hashes and arrays, see

对标量的列表，如何在嵌套哈希和数组中申明允许键，查看如下的连接:

https://github.com/rails/strong_parameters#nested-parameters

If you have multiple Devise models, you may want to set up different parameter sanitizer per model. In this case, we recommend inheriting from `Devise::ParameterSanitizer` and add your own logic:

如果有多个Devise模型，你也许想要对每个模型设置不同的参数限制。在这种情况下，建议从Devise::ParameterSanitizer中继承并添加自己的逻辑:

{% highlight ruby %}
class User::ParameterSanitizer < Devise::ParameterSanitizer
  def sign_in
    default_params.permit(:username, :email)
  end
end
{% endhighlight %}

And then configure your controllers to use it:

然后配置控制器使用它: 

{% highlight ruby %}
class ApplicationController < ActionController::Base
  protected

  def devise_parameter_sanitizer
    if resource_class == User
      User::ParameterSanitizer.new(User, :user, params)
    else
      super # Use the default one
    end
  end
end
{% endhighlight %}

The example above overrides the permitted parameters for the user to be both `:username` and `:email`. The non-lazy way to configure parameters would be by defining the before filter above in a custom controller. We detail how to configure and customize controllers in some sections below.

上述的例子重写了用户限制的参数(`:username`和`:email`)。配置参数的非懒方法可以在定制的控制器中定义。在下面的章节中，详细介绍如何配置和定制控制器。

### 配置视图(Configuring views)

We built Devise to help you quickly develop an application that uses authentication. However, we don't want to be in your way when you need to customize it.

Devise的目标是辅助开发者快速构建一个使用权限的应用程序。但是，Devise不能帮助你定制视图。

Since Devise is an engine, all its views are packaged inside the gem. These views will help you get started, but after some time you may want to change them. If this is the case, you just need to invoke the following generator, and it will copy all views to your application:

由于Devise是一个engine，所有的视图都被打包到gem中。这些视图可能会帮助你开始，但是用不了多久，你就可能想要修改它了。如果是这样，你只需要调用如下的生成器，他将把Devise中所有的视图拷贝到应用程序中。

> rails generate devise:views

If you have more than one Devise model in your application (such as `User` and `Admin`), you will notice that Devise uses the same views for all models. Fortunately, Devise offers an easy way to customize views. All you need to do is set `config.scoped_views = true` inside the `config/initializers/devise.rb` file.

如果应用程序中有多个Devise模型(比如User和Admin)，你可能发现Devise对所有的视图使用相同视图。所幸的是，Devise提供了简单的方式来定制视图。所需要做的仅仅是在`config/initializers/devise.rb`文件中设置`config.scoped_views = true`。

After doing so, you will be able to have views based on the role like `users/sessions/new` and `admins/sessions/new`. If no view is found within the scope, Devise will use the default view at `devise/sessions/new`. You can also use the generator to generate scoped views:

之后，将拥有诸如`users/sessions/new`和`admins/sessions/new`这样的视图。如果没有这样的视图，Devise将使用默认的视图`devise/sessions/new`。同样也可使用生成器生成scoped视图:

> rails generate devise:views users

If you want to generate only a few set of views, like the ones for the `registrable` and `confirmable` module, you can pass a list of modules to the generator with the `-v` flag.

如果，想要生成一组视图，比如`registrable`和`confirmable`模块，可以通过-v标志传递一组模块。

> rails generate devise:views -v registrations confirmations

### Configuring controllers

If the customization at the views level is not enough, you can customize each controller by following these steps:

如果在视图层面的定制不够，可以通过如下的步骤定制每一个控制器: 

1. 创建定制的视图，比如 `Admins::SessionsController`:

    {% highlight ruby %}
    class Admins::SessionsController <  Devise::SessionsController
    end 
    {% endhighlight %}

    Note that in the above example, the controller needs to be created in the `app/controllers/admins/` directory.
    
    注意，上述例子中，控制器需要在`app/controllers/admins/`目录中创建:

2. 告述路由使用该控制器，例如:

    {% highlight ruby %}
    devise_for :admins, controllers: { sessions: "admins/sessions" }
    {% endhighlight %}

3. 从`devise/sessions`将视图拷贝到`admins/sessions`中。由于控制器改变了，所以并不使用位于`devise/sessions`的默认视图: 

4. 最后，更改或扩展需要的控制器动作。可以完全覆盖控制器的动作:

    {% highlight ruby %}
    class Admins::SessionsController < Devise::SessionsController
      def create
        # custom sign-in code
      end
    end
    {% endhighlight %}
   或者简单的添加的新的行为:
    {% highlight ruby %}
    class Admins::SessionsController < Devise::SessionsController
      def create
        super do |resource|
          BackgroundWorker.trigger(resource)
        end
      end
    end
    {% endhighlight %}

    This is useful for triggering background jobs or logging events during certain actions.
    
    在某些动作中触发后台任务或者登录事件非常有用。

Remember that Devise uses flash messages to let users know if sign in was successful or failed. Devise expects your application to call `flash[:notice]` and `flash[:alert]` as appropriate. Do not print the entire flash hash, print only specific keys. In some circumstances, Devise adds a `:timedout` key to the flash hash, which is not meant for display. Remove this key from the hash if you intend to print the entire hash.

记住: Devise使用flash消息通知用户登录是成功还是失败。Devise希望应用程序调用`flash[:notice]`和`flash[:alert]`。不要打印整个flash哈希，而是仅打印特定的键。Devise添加了`:timedout`到flash哈希中，如果想要打印整个hash，请删除该键。

> Rails程序中，flash消息和session会话都可以存储变量。

### Configuring routes

Devise also ships with default routes. If you need to customize them, you should probably be able to do it through the devise_for method. It accepts several options like :class_name, :path_prefix and so on, including the possibility to change path names for I18n:

Devise自带了默认路由。如果想要定制，可以通过devise_for方法，该方法接受诸如:class_name，:path_prefix等等选项，包括可选的I18n路径参数: 

{% highlight ruby %}
devise_for :users, path: "auth", path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', unlock: 'unblock', registration: 'register', sign_up: 'cmon_let_me_in' }
{% endhighlight %}

Be sure to check `devise_for` documentation for details.

更多信息参考devise_for的文档。

If you have the need for more deep customization, for instance to also allow "/sign_in" besides "/users/sign_in", all you need to do is to create your routes normally and wrap them in a `devise_scope` block in the router:

如果想要更多的定制，例如，使用"/sign_in"，而不是"/users/sign_in"。所需要做的是创建路由，并将其包装到devise_scope块中:

{% highlight ruby %}
devise_scope :user do
  get "sign_in", to: "devise/sessions#new"
end
{% endhighlight %}

This way you tell Devise to use the scope `:user` when `/sign_in` is accessed. Notice `devise_scope` is also aliased as `as` in your router.

### I18n

Devise uses flash messages with I18n with the flash keys :notice and :alert. To customize your app, you can set up your locale file:

Devise使用带有国际化的flash消息的:notice和:alert等flash键。为了定制应用，需要设置locale文件(locales文件夹下的文件): 

{% highlight yaml %}
en:
  devise:
    sessions:
      signed_in: 'Signed in successfully.'
{% endhighlight %}

You can also create distinct messages based on the resource you've configured using the singular name given in routes:

可以创建基于资源的独特的消息，只需使用在路由中给定的单数名称来配置:

{% highlight yaml %}
en:
  devise:
    sessions:
      user:
        signed_in: 'Welcome user, you are signed in.'
      admin:
        signed_in: 'Hello admin!'
{% endhighlight %}

The Devise mailer uses a similar pattern to create subject messages:

Devise的mailer使用详细的模式创建对象消息: 

{% highlight yaml %}
en:
  devise:
    mailer:
      confirmation_instructions:
        subject: 'Hello everybody!'
        user_subject: 'Hello User! Please confirm your email'
      reset_password_instructions:
        subject: 'Reset instructions'
{% endhighlight %}

Take a look at our locale file to check all available messages. You may also be interested in one of the many translations that are available on our wiki:

参考一下locale文件从而检查所有可用的信息。你也许会对wiki中可用的翻译的信息刚兴趣:

https://github.com/plataformatec/devise/wiki/I18n

Caution: Devise Controllers inherit from ApplicationController. If your app uses multiple locales, you should be sure to set I18n.locale in ApplicationController

**注意**：Devise控制器继承自ApplicationController。如果使用了多个locales，确保在ApplicationController设置了I18n.locale。

### Test helpers

Devise includes some test helpers for functional specs. In order to use them, you need to include Devise in your functional tests by adding the following to the bottom of your `test/test_helper.rb` file:

Devise为功能描述提供了一些测试辅助类。为了使用他们，需要在功能测试文件`test/test_helper.rb`中包含如下的功能模块。

{% highlight ruby %}
class ActionController::TestCase
  include Devise::TestHelpers
end
{% endhighlight %}

If you are using RSpec, you can put the following inside a file named `spec/support/devise.rb` or in your `spec/spec_helper.rb`:

如果你使用RSpec，需要在`spec/support/devise.rb`或者`spec/spec_helper.rb`放置如下的内容: 

{% highlight ruby %}
RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
end
{% endhighlight %}

Now you are ready to use the `sign_in` and `sign_out` methods. Such methods have the same signature as in controllers:

现在，准备好使用`sign_in`和`sign_out`方法了。这些方法在控制器中拥有如下的相同签名：

{% highlight ruby %}
sign_in :user, @user   # sign_in(scope, resource)
sign_in @user          # sign_in(resource)

sign_out :user         # sign_out(scope)
sign_out @user         # sign_out(resource)
{% endhighlight %}

There are two things that are important to keep in mind:

有两件需要谨记的事情： 
1. These helpers are not going to work for integration tests driven by Capybara or Webrat. They are meant to be used with functional tests only. Instead, fill in the form or explicitly set the user in session;

- 这些辅助对使用Capybara或Webrat驱动的继承测试不起作用。但这不意味着其只能用在功能测试中，可以通过表单填充或显式在session中设置。

2. If you are testing Devise internal controllers or a controller that inherits from Devise's, you need to tell Devise which mapping should be used before a request. This is necessary because Devise gets this information from the router, but since functional tests do not pass through the router, it needs to be told explicitly. For example, if you are testing the user scope, simply do:

- 如果测试Devise的内部控制器或者继承自Devise的控制器，需要告诉Devise在请求之前，设置Devise使用何种映射。由于Devise通过路由获取信息，而功能测试不经过路由，所以需要显式通知。例如，如果测试user scope，操作如下:

    {% highlight ruby %}
    @request.env["devise.mapping"] = Devise.mappings[:user]
    get :new
    {% endhighlight %}

### 授权(Omniauth)

Devise comes with Omniauth support out of the box to authenticate with other providers. To use it, just specify your omniauth configuration in `config/initializers/devise.rb`:

Devise带有Omniauth支持，从而通过盒子支持其他提供器。为了使用它，只需要在`config/initializers/devise.rb`中指定授权配置:

{% highlight ruby %}
config.omniauth :github, 'APP_ID', 'APP_SECRET', scope: 'user,public_repo'
{% endhighlight %}

You can read more about Omniauth support in the wiki:

可以在wiki中夺取更多的授权支持: 

* https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview

### 配置多个模型(Configuring multiple models)

Devise allows you to set up as many Devise models as you want. If you want to have an Admin model with just authentication and timeout features, in addition to the User model above, just run:

{% highlight ruby %}
# Create a migration with the required fields
create_table :admins do |t|
  t.string :email
  t.string :encrypted_password
  t.timestamps
end

# Inside your Admin model
devise :database_authenticatable, :timeoutable

# Inside your routes
devise_for :admins

# Inside your protected controller
before_filter :authenticate_admin!

# Inside your controllers and views
admin_signed_in?
current_admin
admin_session
{% endhighlight %}

Alternatively, you can simply run the Devise generator.

可选的，可以简单的运行Devise生成器。

Keep in mind that those models will have completely different routes. They **do not** and **cannot** share the same controller for sign in, sign out and so on. In case you want to have different roles sharing the same actions, we recommend you to use a role-based approach, by either providing a role column or using a dedicated gem for authorization.

谨记：这些模型将有完全不同的路由。不能也不应该在sign in和sign out等时共享相同的控制器。在这种情况下，相同方法可能有不同的角色，推荐使用基于角色的方法，或者提供规则列，或是使用特定的授权gem包。

### Other ORMs

Devise supports ActiveRecord (default) and Mongoid. To choose other ORM, you just need to require it in the initializer file.

Devise支持ActiveRecord(默认)以及Mongoid。为了使用其他的ORM，需要在initializer文件中require相依的gem包。

## Additional information

### Heroku

Using Devise on Heroku with Ruby on Rails 3.1 requires setting:

{% highlight ruby %}
config.assets.initialize_on_precompile = false
{% endhighlight %}

Read more about the potential issues at http://guides.rubyonrails.org/asset_pipeline.html

### Warden

Devise is based on Warden, which is a general Rack authentication framework created by Daniel Neighman. We encourage you to read more about Warden here:

Devise是基于Warden，后者是一个通用的基于Rack的由Daniel Neighman创建的权限框架。建议从如下的地址了解更多关于warden的信息。

https://github.com/hassox/warden

### Contributors

We have a long list of valued contributors. Check them all at:

https://github.com/plataformatec/devise/graphs/contributors

## License

MIT License. Copyright 2009-2014 Plataformatec. http://plataformatec.com.br

You are not granted rights or licenses to the trademarks of the Plataformatec, including without limitation the Devise name or logo.

## 后记

看完Devise,无非获得了这样的一些认识，Rack-based，`current_user`，devise视图和控制器，模型和devise，一些可用的方法: `before_action :authenticate_member!`、`user_session`等。
