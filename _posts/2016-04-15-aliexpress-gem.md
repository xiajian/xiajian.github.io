---
layout: post
title: 使用 Nokogiri 解析巨大的 XML 文件
description: 'xml 解析, rails, ruby, Nokogiri'
category: note
---

## 前言

有一个大概 500MB 的 xml 文件需要解析， 其内容结构。 使用 `File.open('xx.xml')` 然后，拼接字符串，然后再使用 `Hash#from_xml` 
方法，耗时太多，内存不足。 此时，只能使用流式解析的方式。


##  正文

虽然有很多选择，比如， SAX 解析，最后，还是选择了 ` Nokogiri::XML::Reader`, 因为，看起来能直接工作。

xml 的文件结构： 

```
<?xml version="1.0" encoding="utf-8"?>
<GetCategorySpecificsResponse xmlns="urn:ebay:apis:eBLBaseComponents">
   <Timestamp>2016-06-28T23:19:20.500Z</Timestamp>
   <Ack>Success</Ack>
   <Version>971</Version>
   <Build>E971_CORE_API6_18007281_R1</Build>
   <Recommendations>
    <CategoryID>22422</CategoryID>
    .....中间省略
    <NameRecommendation>
     <Name>Author</Name>
     <ValidationRules>
      <MaxValues>1</MaxValues>
      <SelectionMode>FreeText</SelectionMode>
     </ValidationRules>
    </NameRecommendation>
   </Recommendations>
   
```

具体结构，可以参考： <http://developer.ebay.com/DevZone/XML/docs/Reference/eBay/GetCategorySpecifics.html#GetCategorySpecifics> 中的响应结构：

具体的代码： 

```ruby

# 方法1：将文件中所有的行拼成的字符串
def file_string(file = 'tmp/5856756037_report.xml')
  value = ''

  File.foreach(file) { |line| value << line.strip }

  value
end

# 解析 xml 文件
# @note 数据量太大，根本不可行，
#
# @param {String} file - xml 文件
def parse_xml(file = 'tmp/ebay_report.xml')
  Ebayr::Response.from_xml file_string(file)
end

# 方法2：流式的解析 xml 文件
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

# 从 xml 文件中，将属性以及属性值的信息导入到数据库中
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

表示，这件事还是相当的有点挑战的。 我这段代码，写的还是相当的得意的。要不，干脆，放到 Ebayr 的 gem 中。 今天，发现 TextMate 的彩蛋，复制文件时发现的，好开心。

## 参考资料

- http://stackoverflow.com/questions/6675128/how-do-i-use-nokogirixmlreader-to-parse-large-xml-files
- https://snippets.aktagon.com/snippets/569-how-to-parse-huge-xml-files-with-ruby-and-nokogiri-without-using-too-much-ram-
- http://blog.gregweber.info/posts/2011-06-03-high-performance-rb-part1
- http://www.rubydoc.info/github/sparklemotion/nokogiri/master/Nokogiri/XML/SAX/Parser#parse_file-instance_method
