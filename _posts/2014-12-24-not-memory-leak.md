---
layout: post
title: 不是内存泄漏，而是Bloat
description: ""
category:  rails
---

## 前言

在看Rails性能时，看到这篇文章链接，有空细看一下。

## 正文

Our Rails customers often run into memory issues. The most frequent cause these days is what we in Support dub 'bloated mongrels.'

To be fair, bloat has absolutely nothing to do with mongrel itself, which is a solid and fine piece of work. You can run into this problem just as easily with thin, passenger, etc. Changing to a different server will not save you, as the root cause is not the server, but the code the server is running for you.

A real true-blooded memory leak is rare in comparison to the occurrence of bloating Rails instances. If your mongrels (or thins, or passenger instances) are suddenly sporting 100MB or more of extra weight, look no further: we've got the diet plan for you!

## What Is Bloat?

In short: you are loading in too much. Too much what, you ask? Why it's too much ActiveRecord!

Bloat is easily identifiable. Last week, your mongrels were at 110MB, but after a new feature or two and a bit of 'optimization'.... well, lets just say that you'd have trouble fitting one on a CD. It's not always that dramatic (probably the average size of bloated mongrels are 200-300MB), but basically the mongrels are 2-5x larger than they should be, or spike in size suddenly after a certain subset of requests.

## Detecting Bloat

The easiest way to detect bloat is to watch the Application Server process size. New Relic, for example, will show you combined memory usage. You could watch it live with "top" on your slice/server. In both cases, you are looking for quick jumps in process size. If you're using mongrel, you should be using monit to watch it precisely for this reason. Monit will log to syslog, and assuming that you've setup memory limits, you could run something:

grep resource /var/log/syslog

This would print out lines like so:

Aug 29 03:35:05 myserver monit \[5194\]: 'mongrel_myapp_5000' total mem amount of 133256kB matches resource limit [total mem amount>130360kB]

This is saying the mongrel was caught at 133MB, which is over 130MB. Not too bad. The problem is when you have bloat, you start seeing them skyrocket past the memory limits, sometimes multiple times an hour:

Aug 29 03:35:05 myserver monit \[5194\]: 'mongrel_myapp_5000' total mem amount of 210256kB matches resource limit [total mem amount>130360kB]

This is bad. Basically, the mongrels were fine one minute (under 130MB) and the next minute they weren't (~210MB). That's a pretty big jump, but yet, when it comes to bloat, this is fairly mild.

## OverActiveRecord

Misuse of ActiveRecord is probably the largest and most common threat to a Ruby process size that we see. Instantiation of ActiveRecord models is expensive, and it is very very easy to accidentally instantiate 100k records, especially in earlier versions of Rails. Though these records are not cached for the next request, the Ruby process still needs to request the required amount memory from the system and allocate it. On top of that, Ruby is greedy with memory—it doesn't hand the memory back to the OS after the request. So, one action with memory bloat will mean that your process is just cruising at a bloated 400MB.

## I'm Too Smart to Have Bloat!

The ActiveRecord tips below may seem obvious to seasoned Rails programmers, but even the most experienced programmers run into these issues. Don't worry, I won't name names! Ok, I'll name one: after I wrote the first draft of this very article, I was running a migration on one of our internal sites, and I noticed that the process size was growing... and growing... and growing. Luckily I had enough memory overhead on-slice, but I had a good laugh.

Also keep in mind that code written for a shiny new application with a few hundred users and code written for an application with 100k users have very different needs. Growing and scaling a healthy application requires regular tending and pruning, just like growing healthy garden. Assume that queries written a year ago will come back to bite you as you scale up.

## Development and Production Behavior Will Differ

Ok, so your mongrels may reach 500MB in production, yet they stay a cool 80MB on localhost. It doesn't matter, it's probably irrelevant. Unless you're running the app locally in production mode, with cache_classes=true, are using the exact same data set as production, and are simulating production traffic (with the same params as real-life traffic), the differences are not worth investigation. This is a distraction from the fact that you have a production issue that you should be dealing with. Let's instead go identify the action(s) that are causing the bloat, and work from there.

## Use Tools Like Rack::Bug, MemoryLogic and Oink

Unless you have a very small and manageable code-base, it can be relatively difficult and time consuming to blindly cruise through your application looking for problematic areas.

Luckily, the very awesome Ruby community has some awesome open source tools for the job. We often recommend people try Rack::Bug, MemoryLogic or Oink . These are _amazing _time savers and will allow you to inspect how many ActiveRecord instances are being loaded up on any given request.

Run these tools in production mode on production data, they are built to be non-obtrusive. They should point you pretty immediately to the actions that have issues, and you can begin to explore in script/console and check out the size of the data sets the action and view are loading in. Be sure to use the same exact parameters that the troubled actions are receiving.

## Nailing Down the Root Cause

After you've found a couple of troublesome actions, here are some more detailed tips on what to look for in your code. A "memory leak" from leaky dependencies or Rails itself would be 25th on the list of things to check. Enjoy!

### 1. Model.find(:all)

In versions of Rails before 2.3, this is a memory killer. The most common form in the wild is:

Comment.find(:all).each{ |record| do_something_with_each(record) }

If you have 100,000 Comments, this will load and instantiate all 100k records in memory, then go through each one. In Rails 2.3, the .each will paginate through the results, so you'll only load in small batches, but this won't save you from the following variations:

@records = Comment.all
@records = Comment.find(:all)
@record_ids = Comment.find(:all).collect{|record| record.id }

Each of these will load up all Comment records into an instance variable, regardless if you have 100 or 100,000 and regardless if you are on Rails 2.1 or 2.3

### 2. :includes are Including Too Much

Article.find(:all, :include => [:user => [:posts => :comments]])

This is a variant of the above, intensified by the one or multiple joins on other tables. If you only have 1000 articles you may have thought loading them in is not a big deal. But when you multiply 1000 that by the number of users, the posts they have and the comments that they have... it adds up.

### 3. :includes on a has_many

@articles.users.find(:all, :include => [:posts => :comments]])

Variation on the above, but through a has_many.

### 4. @model_instance.relationship

Referring to a has_many relationship directly like so:

@authors.comments

is a shortcut to the potentially bloated:

@authors.comments.find(:all)

Be sure that you don't have thousands of related records, because you will be loading them all up.

### 5. Filtering Records with Ruby Instead of SQL

This is also fairly common, especially as requirements change or when folks are in a hurry to just get the results they want:

Model.find(:all).detect{ |record| record.attribute == "some_value" }

ActiveRecord almost always has the ability to efficiently give you what you need:

Model.find(:all, :conditions => {:attribute => "some_value"})

This is a simple example to make the point clear, but I've seen more convoluted chunks of code where detect or reject is using some non-attribute model method to determine inclusion. Almost always, these queries can be written with ActiveRecord, and if not, with SQL.

### 6. Evil Callbacks in the Model

I've helped a couple of customers track down memory issues where their controller action looked perfectly reasonable:

def update
  @model = Model.find_by_id(params[:id])
end

However, a look at the filters on the model showed something like this:

after_save :update_something_on_related_model
.
.
def update_something_on_related_model
  self.relationship.each do |instance|
    instance.update_attribute(:status, self.status)
  end
end

### 7. Named scopes, default scopes, and has_many relationships that specify :include Where Inappropriate

Remember the first time you setup your model's relationships? Maybe you were thinking smartly and did something like this:

class User
  has_many :posts, :include => :comments
end

So, by default, posts includes :comments. Which is great for when you are displaying posts and comments on the same page together. But lets say you are doing something in a migration which has something to do with all posts and nothing to do with comments:

@posts = User.find(:all, :conditions => {:activated => true}).posts

This could feel 'safe' to you, because you only have 50 users and maybe a total of 1000 posts, but the include specified on the has_many will load in all related comments - something you probably weren't expecting.

### 8. Use :select When You Must Instantiate Large Quantities of Records

Sometimes, in the reality of running a real production site, you need to have a query return a large data set, and no, you can't paginate. In that case, the first question you should ask is "Do I need to instantiate all of the attributes?"

Maybe you need all the comment_ids in an Array for some reason.

@comment_ids = Comment.find(:all).collect{|comment| comment.id }

In this case, you are looking for an array of ids. Maybe you will be delivering them via JSON, maybe you need to cache them in memcached, maybe they are the first step of some calculation you need. Whatever the need, this is a much more efficient query:

@comment_ids = Comment.find(:all, :select => 'comments.id').collect{|comment| comment.id }

### 9. Overfed Feeds

Check all the places you are making XML sandwiches. Often these controllers are written early on and don't scale well. Maybe you have a sitemap XML feed that delivers every record under the sun to Google, or are rending some large amount of data for an API.

### 10. Monster Migrations

Finally, watch out for your Migrations, as this is a common place where you need to do things like iterate over every record of a Model, or instantiate and save a ton of records. Watch the process size on the server with top or with "watch 'ps aux | grep migrate'".
Summary For the Twitter Lovers

Big honking Rails instances on production? You're loading too much! Look at AR usage in production and adjust; stop looking for leaks!

Keep an eye out for more posts like this in the future, and feel free to share your very own horror stories in the comments :)

