---
layout: post
title: Rails中按日期筛选用户
description: "Rails中按日期筛选用户，ActiveRecord，mysql"
category: note
---

## 前言

有个需求，需要筛选出用户，从而发送邮件。

## 正文

那条筛选语句，最初是这样的: 

    User.includes(:trades).where("last_sign_in_at <= ? and last_sign_in_at >= ?  and trades.id is not null ", 1.weeks.ago, 8.days.ago)

后来要加上 7 天， 30 天， 以及 180天，简单的扩展一下，变成这样: 

    User.includes(:trades).where("(last_sign_in_at <= ? and last_sign_in_at >= ?) or (last_sign_in_at <= ? and last_sign_in_at >= ?) or (last_sign_in_at <= ? and last_sign_in_at >= ?)  and trades.id is not null ", 7.days.ago, 8.days.ago, 30.days.ago, 31.days.ago, 180.days.ago, 181.days.ago)

使用sql的between语句估计还要更长。 为了减少写这么可怕的语句，将查询分为3次: 

```ruby
def deliver_mail(time)
  User.includes(:trades).where("last_sign_in_at <= ? and last_sign_in_at >= ?  and trades.id is not nul ", time.days.ago,  (time+1).days.ago) 
end

[7, 30, 180].each { |x| deliver_mail(x) }
```

但是，查一次肯定比查三次要好。这时，使用数据库提供的`date`函数，语句就短一些: 

    User.includes(:trades).where("date(last_sign_in_at) in (?) and trades.id is not null" , [7.days.ago.to_date, 30.days.ago.to_date, 180.days.ago.to_date])

上述的语句，如果使用的地方很多，就可以使用`scope`封装。 在User模型中，写入如下的scope: 

```ruby
class User < ActiveRecord::Base
  # 查询在特定日期内登录过的用户
  scope :last_sign_date, ->(*time) { where("date(last_sign_in_at) in (?)" ,time.map {|d| d.to_date } ) }
  scope :has_live , includes(:live_account).where("live_accounts.user_id is not null")
  scope :no_vt_and_no_live, includes(:trades, :live_account).where("trades.id is null and live_accounts.user_id is null")
  scope :has_vt_but_no_live, includes(:trades, :live_account).where("trades.id is not null and live_accounts.user_id is null")
end
```

使用scope之后，上面的查询语句可以简化成如下语句，可读性变高了: 

    User.no_vt_and_no_live.last_sign_date(7.days.ago, 30.days.ago, 180.days.ago)

多次使用scope，尝试代码块的代码: 

```
#encoding: utf-8
class InvalidEmailsController < ApplicationController
  inherit_resources

  def index
    @invalid_emails = InvalidEmail.page(params[:page]).per(20)
    if @invalid_emails.current_page == 1
      @callback_user_count = {} 
      @callback_user_count["无模拟无实盘"] = get_callback_user_count { User.no_vt_and_no_live }
      @callback_user_count["有模拟没实盘"] = get_callback_user_count { User.has_vt_but_no_live }
      @callback_user_count["有实盘"] = get_callback_user_count { User.has_live }
    end
  end
  
  protected
    def get_callback_user_count(&blk)
      arr = {}
      # 我原本是这样写的，[7.days.ago, 30.days.ago, 180.days.ago]，后来发现很脑残
      # 违反了最小知识
      [7, 30, 180].each do |time|
        arr.store("#{time}天", blk.call.last_sign_date(time.days.ago).count)
      end
      arr
    end
end
```

> 备注: 可以看到 `get_callback_user_count` 中查询了三次数据库，如果，可以一次将数据查出来，那该多好。听前辈说，`group`可以做到，不管怎么样，
> sql方面，我不是很熟。

总结，ActiveRecord中，可直接写sql语句，其提供的语法简化了sql语句。 抽象问题的水平，决定了编码的水平。

直接使用数据库提供的函数，可能会形成对DBRMS的依赖。

## 参考文献

1. [Rails ActiveRecord date between](http://stackoverflow.com/questions/2381718/rails-activerecord-date-between)
