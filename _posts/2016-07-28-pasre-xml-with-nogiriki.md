---
layout: post
title: 批量导入数据
description: 'rails，postgres, import database'
category: note
---

## 前言

最近，涉及插入十几万条数据，直接使用 ActiveRecord 的 create 方法，超慢的。找了 ActiveRecord-import 方法。尝试了一下，快了不少。


```ruby
def import_countries
  country_file = Rails.root.join('db/data', 'country.csv').to_s

  countries = []

  CSV.foreach country_file do |row|
    country = Country.new name: row[2], code: row[3], name_en: row[1].gsub(/^\s+|\s+$/, '') # 去除投和尾的空格
    puts country
    countries << country
  end

  Country.import countries
end

def create_countries
  country_file = Rails.root.join('db/data', 'country.csv').to_s

  countries = []

  CSV.foreach country_file do |row|
    country = {
        name: row[2],
        code: row[3],
        name_en: row[1].gsub(/^\s+|\s+$/, '') # 去除投和尾的空格
    }

    puts country
    countries << country
  end

  Country.create countries
end

def prof(&block)
  start_time = Time.now

  if block_given?
    block.call
  end

  cost_time = Time.now - start_time

  puts "Cost Time is: #{cost_time} s"
end

prof do 
  import_countries # Cost Time is: 1.692939 s
end
  
prof do 
  create_countries # 0.241883 s
end 
```

## 后记

批量插入数据，使用了 postgresql 支持的批量将数据插入内置方法，非常的方便。

同时插入，一万条数据以上的，在网络状况不好的情况下，会引发 Network Timeout 时间。 后来，发现还是自己的本地的网络的状况不太好。

```
from /Users/xiajian/.rvm/gems/ruby-2.3.0@camp/gems/activerecord-4.2.5/lib/active_record/connection_adapters/postgresql_adapter.rb:592:in `async_exec'
```
