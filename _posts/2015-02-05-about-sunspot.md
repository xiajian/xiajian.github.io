---
layout: post
title: 关于sunspot
---

## 前言

迭代了两年的项目中，存在一些历史遗留的垃圾，比如sunspot分词，以及标签相关的东西。了解了一下，还是挺复杂的一项功能，牵扯挺多，又对之不熟悉，怎么办！！

不急，一步一步，慢慢来。

## 正文

涉及的gem包太过复杂了，不知道从何下手。不过，今天，通过pstree查看是否有java进程运行时，意外的发现，居然没有运行solr，这意味着，有可能这个功能可以直接
的去掉，不会引起任何异常，这可是一个重大利好的消息。

后来在逐步了解中，现有的项目中根本就没有使用sunspot，完全属于无用的东西。分词是通过solr_cn项目，在后台任务中，通过RestClient
发送请求/解析进行处理的。以下是对sunspot的整理: 

Sunspot涉及的gem包: 

* "sunspot_rails", "2.0.0" ： 使用的方法: searchable, search, Sunspot等
* "sunspot_solr", "1.3.2" ： 脚本运行
* "sunspot_mongoid", "0.4.1" ： Sunspot::Mongoid
* `'sunspot_cell', :git => 'git://github.com/zheileman/sunspot_cell.git'`

涉及的solr的java程序: [solr_cn](https://github.com/tteng/solr_cn)

## 相关配置

配置文件sunspot.yml内容如下:

```
staging:
  solr:
    hostname: 192.168.1.99
    port: 8983
    log_level: WARNING
development:
  solr:
    hostname: 192.168.1.99
    port: 8983
    log_level: WARNING
production:
  solr:
    hostname: solr-node1
    port: 8983
    log_level: WARNING
```

## mongoid的patch

由于Article表是Mongodb的表，项目中对mongoid的gem包打patch。

```ruby
#sunspot_mongoid_patch.rb
#encoding: utf-8
#author: tteng
#override Sunspot::Mongoid::DataAccessor::BSON 
#to fix uninitialized constant Sunspot::Mongoid::DataAccessor::BSON bug
#target version: sunspot_mongoid/0.4.1

module Sunspot
  module Mongoid
    def self.included(base)
      base.class_eval do
        extend Sunspot::Rails::Searchable::ActsAsMethods
        Sunspot::Adapters::DataAccessor.register(DataAccessor, base)
        Sunspot::Adapters::InstanceAdapter.register(InstanceAdapter, base)

        after_save do
          # do not use meathod "changed", use changes.keys instead
          reindex_attr_array = changes.keys.map(&:to_sym) & self.class.sunspot_options[:only_reindex_attribute_changes_of]
          Resque.enqueue(SunspotIndexJob, self.class.name,self.id.to_s) if reindex_attr_array.any?
        end

        # after_delete do
        #   Sunspot.remove! self
        # end

        after_destroy do
          Sunspot.remove! self
        end
      end
    end

    class DataAccessor < Sunspot::Adapters::DataAccessor
      def load(id)
        @clazz.criteria.for_ids(Moped::BSON::ObjectId(id))
      end

      def load_all(ids)
        @clazz.criteria.in(:_id => ids.map {|id| Moped::BSON::ObjectId(id)})
      end
    end
  end
end
```


## 后记

没怎么费事，就把不想要的东西干掉了，真是不以快哉啊。事情又沿着我想要的方向发展了一步。话说，我想要方向到底是什么，
其实我自己也不太清楚。
