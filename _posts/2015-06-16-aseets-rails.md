---
layout: post
title:  "assets-rails 相关的gemfile 分组"
description: "assets-rails中相关的资源的Gemfile资源的收集“
category: note
---

## 前言

偶然，看到1700行的 Gemfile , 觉得相当的恐怖，特别是，其中添加了一堆没用的东西。看到，关于 angularjs 的收集，感觉可以收藏起来。

## 收藏

```
# https://rails-assets.org
gem 'bundler', '>= 1.8.4'

source 'https://rails-assets.org' do

  # https://angularjs.org/
  ANGULAR_VERSION = '1.2.28'


  gem 'rails-assets-angular', ANGULAR_VERSION

  gem 'rails-assets-angular-cookies', ANGULAR_VERSION

  # https://github.com/danialfarid/angular-file-upload
  gem 'rails-assets-danialfarid-angular-file-upload'

  # # https://github.com/nervgh/angular-file-upload
  # gem 'rails-assets-angular-file-upload'

  gem 'rails-assets-angular-i18n', ANGULAR_VERSION

  gem 'rails-assets-angular-lodash', '0.1.0'

  gem 'rails-assets-angular-moment', '0.1.3'

  gem 'rails-assets-angular-resource', ANGULAR_VERSION

  gem 'rails-assets-angular-route', ANGULAR_VERSION

  # http://dalelotts.github.io/angular-bootstrap-datetimepicker/
  gem 'rails-assets-angular-bootstrap-datetimepicker', '0.2.4'

  # https://github.com/frapontillo/angular-bootstrap-switch
  gem 'rails-assets-angular-bootstrap-switch', '0.3.0'

  gem 'rails-assets-angular-spinner', '0.5.0'

  # https://github.com/angular-ui/bootstrap
  # gem 'rails-assets-angular-ui-bootstrap', '0.11.0'

  # https://github.com/angular-ui/bootstrap-bower
  gem 'rails-assets-angular-ui-bootstrap-bower', '0.11.0'

  # http://angular-ui.github.io/
  gem 'rails-assets-angular-ui-bower'

  # https://github.com/monicao/angular-uuid4
  gem 'rails-assets-angular-uuid4', '0.3.0'

  ######## Upload

  # https://github.com/nervgh/angular-file-upload
  gem 'rails-assets-angular-file-upload', '1.1.5'

  # https://github.com/danialfarid/angular-file-upload
  gem 'rails-assets-angularjs-file-upload', '2.2.2'

  # # https://github.com/blueimp/jQuery-File-Upload
  # gem 'rails-assets-jquery-file-upload', '9.9.2'

  # gem 'jquery-fileupload-rails', path: '/Users/jason-hou/project/vendor/jquery-fileupload-rails'

  gem 'jquery-fileupload-rails', git: 'ssh://git@repo.scm.atyun.com.cn:20322/atyun-gems/jquery-fileupload-rails.git'

  # https://github.com/jasny/bootstrap
  # gem 'rails-assets-jasny-bootstrap'

  gem 'rails-assets-bootbox', '4.2.0'

  gem 'rails-assets-bootstrap', '3.1.1'

  ######## Tree

  # https://github.com/angular-ui-tree/angular-ui-tree
  gem 'rails-assets-angular-ui-tree', '2.2.0'

  # # https://github.com/jonmiles/bootstrap-treeview
  # gem 'rails-assets-bootstrap-treeview', '1.0.1'

  # https://github.com/wix/angular-tree-control
  gem 'rails-assets-angular-tree-control', '0.2.8'
  
  # https://github.com/nostalgiaz/bootstrap-switch
  gem 'rails-assets-bootstrap-switch', '3.0.2'

  # https://github.com/Eonasdan/bootstrap-datetimepicker
  gem 'rails-assets-eonasdan-bootstrap-datetimepicker', '3.0.0'

  gem 'rails-assets-lodash', '2.4.1'

  # gem 'rails-assets-jquery', '2.1.1'
  gem 'rails-assets-jquery', '1.9.1'

  gem 'rails-assets-jquery.cookie', '1.4.1'

  # https://github.com/jassa/lazyload-rails
  gem 'rails-assets-jquery.lazyload', '1.9.3'


  gem 'rails-assets-jquery-ujs', '1.0.0'

  # http://jqueryui.com/
  # https://github.com/components/jqueryui
  gem 'rails-assets-jquery-ui', '1.11.0'

  # gem 'rails-assets-jquery-mobile', '1.4.0'

  # https://github.com/mathiasbynens/jquery-placeholder
  gem 'rails-assets-jquery-placeholder', '2.0.8'

  gem 'rails-assets-jquery-waypoints', '2.0.5'

  ######## Validation

  # https://github.com/huei90/angular-validation
  gem 'rails-assets-angular-validation', '1.2.2'

  # https://github.com/jzaefferer/jquery-validation
  gem 'rails-assets-jquery.validation', '1.13.0'

  gem 'rails-assets-json3', '3.3.2'

  gem 'rails-assets-mobile-angular-ui', '1.1.0.beta.21'

  gem 'rails-assets-moment', '2.7.0'

  ######## Angular Table

  # https://github.com/esvit/ng-table
  gem 'rails-assets-ng-grid', '2.0.7'

  # http://ui-grid.info/
  # https://github.com/angular-ui/ng-grid
  gem 'rails-assets-ng-table', '0.3.3'

  # https://github.com/lorenzofox3/Smart-Table
  gem 'rails-assets-angular-smart-table'

  ######## HTTP clients

  # https://github.com/mgonto/restangular
  gem 'rails-assets-restangular', '1.4.0'

  gem 'rails-assets-underscore', '1.6.0'

  # # https://github.com/farrrr/uploadify
  # gem 'rails-assets-uploadify'
end
```

## 后记

对于一个上线的项目而言，1700行 Gemfile 绝对是个灾难。但是，对于个人而言，也算是一个宝库，其中收藏了各种各样的奇珍异宝。
