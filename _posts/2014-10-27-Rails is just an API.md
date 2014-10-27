---
layout: post
title: Rails is just an API
---
 

There’s been a lot of talk recently about the future of Rails, and how it relates to client-side JavaScript frameworks such as Spine and Backbone.

Historically Rails applications have been an amalgamation of Ruby, HTML and snippets of JavaScript. Add an API to the mix, include a ton of conditional rendering logic, and you’ve got your classic Rails spaghetti.

So what’s the future for Rails? If you talk to the likes of 37Signals and GitHub, it’s pjax and server side rendering. This involves fetching a partial of HTML from the server with Ajax, updating the page and changing the URL with HTML5 pushState. The advantages of this approach are clear. It’s simple, fits in well with the existing methodology and doesn’t require using much JavaScript.

I think this makes sense for web sites, but not web applications. An approach to complex web applications like this, persisting state in the DOM and relying on the server to update the UI only exacerbates the initial spaghetti problem. Aside from that, your interface is only as fast as your network connection, and frankly speed matters.

However, now we have got the tools and conventions to break free from that predicament. Client-side MVC frameworks let you pull that logic into standalone JavaScript applications allowing you to separate out your concerns cleanly, re-render templates client-side and build responsive asynchronous interfaces.

The caveat in moving state to the client is that it’s a huge perceptual shift for developers, with a steep learning curve. But there are some thorough resources out there, and the potential upsides are huge, bringing incredible, desktop-like experiences to the web, without the ‘click and wait’ interaction that’s haunted the request/response model.

So where does this picture leave Rails?

The answer is simple. Rails isn’t going away anytime soon. It makes excellent CRUD REST APIs, and the asset pipeline ensures serving up JavaScript Web Apps is pretty straightforward. Rails has a good ORM, excellent libraries and lacks the callback hell that Node sometimes suffers from. There’s nothing wrong with relegating Rails to the API layer.
