---
layout: post
title: API Tasker
---

## 缘起
----
最近，忙于计算无聊的留存率，今天下午，终于搞定了，虽然做了很多第一次，比如，第一次写Rake任务，第一次写后台job等，第一次打开类。总体觉得相当的无聊，终于，要开始再一次写接口了，内心无比的感慨。

不管怎么说，测试先行，我要从接口的编写中将测试之道贯彻到底，首先从`api_taster`开始。

## 简介
----
ApiTaster是一个简单的，可视的方法，可以用来测试Rails应用程序的API。

> 0.8版本的只能和Rails 4.1 一起使用，如果想要在Rails 3.x/4.0中使用，请指定0.7版本的Api Taster。

## 为何

世界上已经了一坨API客户端（比如，Postman), 所以，为何要重造轮子。

API Taster拥有如下的这些特性可选: 
* API终端点是自动从Rails路由的定义中生成的 * 定义参数和定义路由一样的方便
* 参数可以在测试工厂之间共享

## 使用

在gemfile文件中添加如下的行：

> gem 'api_taster'

挂载API Taster，然后，就可以在应用程序中访问API Taster。例如：

    Rails.application.routes.draw do
      mount ApiTaster::Engine => "/api_taster" if Rails.env.development?
    end
这里其实就是在路由中添加了一条规则`mount ApiTaster::Engine => "/api_taster" if Rails.env.development?`。

然后在`lib/api_tasters/routes.rb`中，在每个常规的路由定义代码块中，为每个API终端定义参数。具体的代码示例如下: 

    if Rails.env.development?
      ApiTaster.routes do
        desc 'Get a __list__ of users'
        get '/users'
    
        post '/users', {
          :user => {
            :name => 'Fred'
          }
        }
    
        get '/users/:id', {
          :id => 1
        }
    
        put '/users/:id', {
          :id => 1, :user => {
            :name => 'Awesome'
          }
        }
    
        delete '/users/:id', {
          :id => 1
        }
      end
    end
可以通过创建`config/initializers/api_taster.rb`，其中包含如下内容，从而修改默认的`lib/api_tasters/routes.rb`。

> ApiTaster.route_path = Rails.root.to_s + "/app/api_tasters" # just an example

### 在测试工厂之间分享参数

如果使用诸如[FactoryGirl](https://github.com/thoughtbot/factory_girl)这样的测试工厂，这可能需要测试工厂共享参数。例如，在FactoryGirl中使用`attributes_for(:name_of_factory)`方法。

### Custom Headers

如果存在需要作为API终端的潜在假设(比如权限token)，可能需要在`APITaster.routes`调用之前，设置`APITaster.global_headers`： 

    ApiTaster.global_headers = {
      'Authorization' => 'Token token=teGpfbVitpnUwm7qStf9'
    }
    
    ApiTaster.routes do
      # your route definitions
    end

###  注释API终点 

在每个路由之前，可以通过使用`desc`添加一些注释。注释中支持Markdown语法。

    desc 'Get a __list__ of users'
    get '/users'

### API终点中的源数据

对于每个路由定义，可以使用可选的地方参数(hash数组)作为元数据：

    get '/users', {}, { :meta => 'data' }

对于处理任意数据的路由，元数据选项的定义非常有用。例如，可以执行期望的相应，从而使得测试用例集能够测试到这些路由。

元数据对于某个路由的定义存储在`ApiTaster::Route.metadata`文件中，请通过阅读源代码来找出如何为特定的路由获取元数据。

### Missing Route Definitions Detection

API Taster为那些遗失的路由定义，提供了警告页。

### 过时的/未匹配的路由定义

APIs evolve - especially during the development stage. To keep ApiTaster.routes in sync with your route definitions, API Taster provides a warning page that shows you the definitions that are obsolete/mismatched therefore you could correct or remove them.

APIs会演化，尤其是在开发状态时。保持ApiTaster.routes和路由定义同步，API Taster提供了显示过时和未匹配的警告页，从而方便纠正或移除。

> 遇到问题，运行Rails server后，相应的js不能获取并下载，问了前辈后说，是Gem包冲突了, 或者是其他的什么原因。尝试不成功之后，我就想替换现存的实现。后来的某一天(10月20), 换了台机器，启动了一下，结果依然，但是注意到了DalliError 以及11211端口信息不可得这样的一些信息，然后，去查看了一下Dalli的项目主页，发现其前置条件是安装memcached，安装memcached后，就正常了。

## 后记
----
看完了API-taster，也不知道如何去编写api, 感觉没什么用处。结果，自己写代码，主要还是靠猜和试，哈哈，一点都不专业。其实，我可以称自己为`混饭吃的业余程序员`，Good Name。

最近，进入了滞涩期，所以，需要一些新的学习方法。比如，看一些开源的项目(gitlab和redmine)。

找到新的写API的方式了，Grape gem包，sinatra，还是Rails-API，持续纠结中。
