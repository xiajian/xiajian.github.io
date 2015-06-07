---
layout: post
title:  http客户端
description: "Ruby中HTTP client相关的gem包"
category: note
---

## 前言

这几天，在做一个前端的项目。其需要向后台API请求。所以考虑需要使用一个HTTP的 client 。找到这样的几个客户端:  Nestful, RestClient。

##  实现

使用 nestful 的实现

```ruby
# encoding: UTF-8
class Base < Nestful::Resource
  endpoint "#{APISetting.host}#{APISetting.version}"
end

#encoding utf-8
class TestsResource < Base
  path 'users'

  # POST http://api.shop.sit.facloud.com/api/v1/users/sign_in.json
  def self.login(params)
    options = {
      login: params[:name],
      password: params[:password]
    }    
    sign_in_url = "#{self.url}/sign_in.json"
    Rails.logger.info "sign_in = #{sign_in_url}"
    begin
      post( URI.parse(sign_in_url) , options).decoded
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end
```

使用 RestCLient 的实现: 

```ruby
#encoding utf-8
require 'rest-client'
class UsersResource 
  USER_LOGIN_URL = "#{APISetting.host}#{APISetting.version}/users"
  def self.login(params)
    options = {
     login: params[:name],
     password: params[:password]
    }
    sign_in_url =  "#{USER_LOGIN_URL}/sign_in.json"
    Rails.logger.info "sign_in = #{sign_in_url}"
    begin
      JSON.parse RestClient.post(sign_in_url, options)
      # post("sign_in.json", name: options[:name], password: options[:password]).decoded
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end
```

> RestClient 只依赖 URL ，提供一些其他的功能。

## 后记

有空总结一下。
