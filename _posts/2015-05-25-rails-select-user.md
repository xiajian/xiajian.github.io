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

总结，ActiveRecord中，可直接写sql语句，其提供的语法简化了sql语句。

直接使用数据库提供的函数，可能会形成对DBRMS的依赖。

## 参考文献

1. [Rails ActiveRecord date between](http://stackoverflow.com/questions/2381718/rails-activerecord-date-between)
