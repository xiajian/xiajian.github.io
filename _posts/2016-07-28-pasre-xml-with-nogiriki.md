---
layout: post
title: 解析巨大的 xml 文件
description: 'rails，postgres, import database'
category: note
---

## 前言

最近，涉及插入十几万条数据，直接使用 ActiveRecord 的 create 方法，超慢的。找了 ActiveRecord-import 方法。尝试了一下，快了不少。


```ruby
# 流式的解析 xml 文件
# @note 使用了 Ebayr::Response 中解析 xml 文件, 使用的是 Reader，而不是 Parser 处理
#
# @param {String} file - xml 文件
# @param {Proc} block - 代码块对象
#
# @return
def parse_xml_with_stream(file = 'tmp/ebay_report.xml', &block)
  ActiveSupport::XmlMini.backend = 'Nokogiri'
  reader = Nokogiri::XML::Reader(File.open(file))

  reader.each do |node|
    if node.name == "Recommendations"

      # puts "outer xml: #{node.outer_xml}"
      # puts "node class: #{node.class}"
      # puts "node methods: #{node.public_methods}"
      response = Ebayr::Record.new Ebayr::Response.from_xml(node.outer_xml)

      category = Hashie::Mash.new response

      # 在这里头添加导入数据的处理逻辑

      puts "category: #{category.to_h}"

      block.call category
    end
  end
end

def count_recommendations(file = 'tmp/ebay_report.xml')
  ActiveSupport::XmlMini.backend = 'Nokogiri'
  reader = Nokogiri::XML::Reader(File.open(file))
  count = 1

  reader.each do |node|
    if node.name == "Recommendations"
      count += 1
    end
  end

  count
end

def limit_parse_count(limit_count = 3)
  count = 1

  parse_xml_with_stream do |category|
    count += 1
    puts "count: #{count}"

    break if count > limit_count
  end

  count
end

# 获取并存储 ebay 的属性
#
# @return {Array} categories - 所有的品类的数组
def get_categories
  categories = []

  parse_xml_with_stream do |category|
    categories << category
  end

  categories
end

# 从 xml 文件中，将属性以及属性值的信息导入到
#
# @param {String} xml_file - 需要解析的文件
def import_ebay_specifics_from_xml(xml_file = 'tmp/ebay_report.xml')
  platform = B2cPlatform.ebay

  Profile.parse_xml_with_stream xml_file do |category|
    b2c_category_id = category.recommendations.try(:category_id)

    if b2c_category_id.blank?
      puts "category #{b2c_category_id} is not exists!!!"
      next
    end

    category_id = ProductCategory.get_id_from_cache b2c_category_id, ProductCategory::PlatformType::EBAY

    next if category_id.blank?

    name_recommendations = category.recommendations.try(:name_recommendation)

    next if name_recommendations.blank?

    name_recommendations.each do |item|
      next if item.is_a?(Array)

      product_attribute = ProductAttribute.get_ebay_product_attribute item, platform, category_id

      if product_attribute.product_attribute_values.present?
        next
      elsif item[:value_recommendation].present?
        ProductAttributeValue.import_by_platform_and_product_attribute item[:value_recommendation], platform, product_attribute
      end
    end
  end
end

```

## 后记

批量插入数据，使用了 postgresql 支持的批量将数据插入内置方法，非常的方便。

同时插入，一万条数据以上的，在网络状况不好的情况下，会引发 Network Timeout 时间。 后来，发现还是自己的本地的网络的状况不太好。

```
from /Users/xiajian/.rvm/gems/ruby-2.3.0@camp/gems/activerecord-4.2.5/lib/active_record/connection_adapters/postgresql_adapter.rb:592:in `async_exec'
```


## 参考资料

- http://stackoverflow.com/questions/6675128/how-do-i-use-nokogirixmlreader-to-parse-large-xml-files
- https://snippets.aktagon.com/snippets/569-how-to-parse-huge-xml-files-with-ruby-and-nokogiri-without-using-too-much-ram-
- http://blog.gregweber.info/posts/2011-06-03-high-performance-rb-part1
- http://www.rubydoc.info/github/sparklemotion/nokogiri/master/Nokogiri/XML/SAX/Parser#parse_file-instance_method
