---
layout: post
title: Rails is just an API
---

译自: [Rails is just an API](http://blog.alexmaccaw.com/rails-is-just-and-api-and-that-s-ok)

## 正文

There’s been a lot of talk recently about the future of Rails, and how it relates to client-side JavaScript frameworks such as [Spine](http://spinejs.com/) and [Backbone](http://documentcloud.github.com/backbone/).

Rails如何关联客户端的JavaScript框架([Spine](http://spinejs.com/)和[Backbone](http://documentcloud.github.com/backbone/))。

Historically Rails applications have been an amalgamation of Ruby, HTML and snippets of JavaScript. Add an API to the mix, include a ton of conditional rendering logic, and you’ve got your classic Rails spaghetti.

历史上，Rails应用程序就是Ruby，HTML和Javascript片段的混合，然后添加API来混合，其中包含一吨条件渲染逻辑，最终形成了`传统的Rails意大利面条`。

So what’s the future for Rails? If you talk to the likes of 37Signals and GitHub, it’s ajax and server side rendering. This involves fetching a partial of HTML from the server with Ajax, updating the page and changing the URL with HTML5 pushState. The advantages of this approach are clear. It’s simple, fits in well with the existing methodology and doesn’t require using much JavaScript.

pjax(ajax + pushState)和服务器端渲染，从服务器端获取部分HTML，更新页面，并使用HTML5 pushState更改URL。

I think this makes sense for web sites, but not web applications. An approach to complex web applications like this, persisting state in the DOM and relying on the server to update the UI only exacerbates the initial spaghetti problem. Aside from that, your interface is only as fast as your network connection, and frankly speed matters.

web站点和web应用程序的区别？ 复杂web应用中处理的方法: 在DOM中持久化状态 & 依赖服务器更新UI -->  加剧最初的意大利面条(spaghetti)问题。

However, now we have got the tools and conventions to break free from that predicament. Client-side MVC frameworks let you pull that logic into standalone JavaScript applications allowing you to separate out your concerns cleanly, re-render templates client-side and build responsive [asynchronous interfaces](http://old.alexmaccaw.com/posts/async_ui).

已经有工具和概念从困境中出来，客户端MVC框架，将单独的逻辑放到单独的JavaScript应用，重新新渲染客户端模板，构建响应式的异步接口。

The caveat in moving state to the client is that it’s a huge perceptual shift for developers, with a steep learning curve. But there are some thorough resources out there, and the potential upsides are huge, bringing incredible, desktop-like experiences to the web, without the ‘click and wait’ interaction that’s haunted the request/response model.

客户端的活动状态对开发者而言，是一种巨大的感性的转变的警告，并带有一个陡峭的学习曲线。存在一些深入的资源，并且潜在的好处巨大且难以置信，比如和桌面一样的经历延伸到web上，没有“等待”互动，以及恼人的请求/响应模型。

So where does this picture leave Rails? 

所以，对于Rails而言，未来是什么？

The answer is simple. Rails isn’t going away anytime soon. It makes excellent CRUD REST APIs, and the asset pipeline ensures serving up JavaScript Web Apps is pretty straightforward. Rails has a good ORM, excellent libraries and lacks the callback hell that Node sometimes suffers from. There’s nothing wrong with relegating Rails to the API layer.

答案是简单的，Rails并不会被淘汰。极佳的CRUD REST APIs，优雅的asset pipeline，好用的ORM，出色的类库，Rails的API层无懈可击。

注：关于文中提到的异步响应接口的链接的文章，内容摘要如下: 
* 前端中的新技术： HTML5, CSS3, Canvas 以及 WebGL
* request/response mindset -  click and wait 
* asynchronous user interfaces(AUI): 完全无阻塞，MVC Javascript框架，核心要点: 
  -  Move state & 客户端视图渲染
  -  智能预加载数据
  -  异步服务器通信
* key point: 用户不关心Ajax，要做好用户体验，不唐突的反馈

## 后记

接触了PJAX，这个新奇的技术，终于，找到了我想要的技术了。
