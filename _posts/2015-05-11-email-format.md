---
layout: post
title: "邮件格式处理"
description: "邮件名格式，有效的邮件名"
category: note
---

## 前言

上次，发错了邮件的事情，让我感觉很丢脸。今天，决定统计一下有关的无效邮件的名的相关。

## 正文

形形色色的第三方登录，其授权的邮箱名大多是这样的: `xxx@example.com`，这样的邮箱是无效邮箱。

形形色色奇葩的无效邮箱后缀名(将正常的后缀域名过滤掉): 

```
["qq.cpm", "qq.con", "126.com081122", "163.co", "qq.xom", "qq.vom", "qq.ocm", "9208112.qq", "qq.nom", "qq.cim", "qq.co", "163.con", "foxmail.con", "121.eee", "gmu.jq", "qq.coom", "hotmail.con", 
"jwu.gj", "126.con", "qq.come", "com.pp", "sohu.con", "163.cmo", "126.co0m", "163.cdw", "110.con", "163.conm", "qq.copm", "com.on", "pp.con", "163.c0m", "1138123928.con", "qq.252454026", "qq.gom",
"165.fdfwes", "qq.cxom", "qq.cmo", "qq.c0m", "163.com337839273", "126.c0m", "163.7com", "www.con", "99.eom", "zhanzheng.xing", "pp.th", "pp.cow", "16.3cem", "qq.169", "ww.ppt", "61702.187", 
"foxmail.coo", "168.con", "qq.col", "qq.copcom", "www.1231456", "16.cow", "126.cft", "163.com38025472", "126.ccom", "562907163.con", "ww.ea", "aqq.som", "139.com030910", "qq.comn", "qq.mop", 
"comm.qq", "hh238827649.zzcom", "qq.cam", "cn.cnm", "qq.ciom", "qq.2540719975", "qq.cow", "160.0com", "963799807.con", "sina.con", "qq.cao", "www.ciong.con", "com.qq", "qq.ccom", "qq.cnm", 
"cmm.qq", "qq.kang", "dwd.con", "df.ki"] 
```

无效邮件共有3589份, 当单是上面这些奇葩格式的后缀域名就84个。

有一类无效的邮件能明确的看出来，最后的域名不是字母的，可以通过`\.[a-z]{2,4}$`将其匹配出来 - 共有28份。

第二类，包含`www.`的邮件，通过`^www\.`配出出来，共有235份。

第三类，`cpm|con|xom|cm|vom|gj|jq|coom|cow|col|...`，这你玛太坑爹了。我决定，从正确的开始匹配。将其和第一类合并，正则表达式为
`/\.(com|net|uk|cn|sg|my|hk|ca|tw|top|jp|edu|cc|es|ru|de|info|org|au|om|cm|gr|be)$/`, 去掉了230个。

> 尝试使用ex命令，来删除不需要的行。`:%/{pattern}/d` ，结果发现遇到一个坑爹问题。VIM所谓的坑爹的匹配模式( magic, nomagic, very magic, very nomagic )。其中，
> very nomagic 模式才是自己所熟悉的Perl正则表达式类型，所有正则表达式前要加`\v`。

无效的后缀名的正则表达式: 

    `/\.(cpm|con|co|xom|vom|ocm|qq|nom|cim|eee|jq|coom|gj|come|pp|cmo|cdw|conm|copm|on|gom|cxom|eom|xing|th|cow|ppt|coo|col|cft|ccom|ea|som|comn|mop|cam|cnm|ciom|cao|kang|ki)$` ，

ex命令为: 

    %global/\v\.(cpm|con|co|xom|vom|ocm|qq|nom|cim|eee|jq|coom|gj|come|pp|cmo|cdw|conm|copm|on|gom|cxom|eom|xing|th|cow|ppt|coo|col|cft|ccom|ea|som|comn|mop|cam|cnm|ciom|cao|kang|ki)$/d

大概过滤了201条。与直接使用有效后缀明相反，少过滤了29条数据。

其他, 剩下3153份无效邮件就没什么模式可言了，建立一个数据库表进行模式匹配和删除，然后在后台建立管理界面。大体的思路就是这样的。

邮箱验证的正则表达式，收集了几个: 

```
类似新浪的邮箱验证: /^[a-z0-9](\w|\.|-)*@([a-z0-9]+-?[a-z0-9]+\.){1,3}[a-z]{2,4}$/
devise自带的邮箱验证: /^[a-z0-9]([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,4})$/i
github上看到的邮箱验证: /^([a-zA-Z0-9]+[_|_|.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|_|.]?)*[a-zA-Z0-9]+.[a-zA-Z]{2,4}$/;
```

由于正则表达式是使用状态机进行匹配的，正则表达式太越长，耗时越多，效率越慢。

## 实践

综合上面的这些讨论，实现了一个简单的数据库模型: 

```
class InvalidEmail
  
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email

  validates :email , :presence => true, :uniqueness => true

  # 验证邮箱是否为无效邮箱
  # 如果邮箱无效，返回为false。由于这是用来发送邮件的验证，严格点没问题。
  def self.verify_email(email)
    return false unless email =~ /^[a-z0-9]([\w\.\-]+)@([\w\-]+\.)+([\w]{2,4})$/i      # 验证是否是邮件
    return false if email =~ /@example.com/i                                           # 去掉各种第三方授权链接
    return false if email =~ /^www\./i                                                 # 去掉以www.开头的邮箱
    return false unless email =~ /\.(com|net|uk|cn|sg|my|hk|ca|tw|top|jp|edu|cc|es|ru|de|info|org|au|om|cm|gr|be)$/
    return false if email =~ Regexp.new(get_invalid_email)                             # 去掉其他已知的无效邮箱
    return true
  end

  # 觉得直接访问数据库性能不好，可以用redis缓存。
  def self.get_invalid_email
    invalid_array = []
    InvalidEmail.each { |x| invalid_array  << Regexp.escape(x.email) }
    invalid_array.join('|')
  end
end
```

## 后记

早上过来，思路清晰多了。

## 参考文献

1. [Javascript正则表达式验证表单邮箱地址](http://www.tuicool.com/articles/AR3iqa)
