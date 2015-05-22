---
layout: post
title:  尝试meteor
description: "尝试用来生成手机app的h5框架 - meteor"
category: note
---

## 前言

最近，接触了一个可利用HTML，JS，CSS 来生成 手机应用的几个解决方案: [Ionic](https://github.com/driftyco/ionic) , [Meteor](https://github.com/meteor/meteor)。以下是一些尝试。

## 尝试Meteor

安装: 

```
curl https://install.meteor.com/ | sh
```

创建应用:

```
meteor create test-meteor-app # 启动应用
cd test-meteor-app            
meteor -p 4000                # 启动本地服务器
```

运行安卓的模拟器:

```
meteor install-sdk android
meteor add-platform android  # 总是卡在某处
meteor run android           # 很慢
```

上面，第一条命令就出错了，出错信息如下:

```
✓ Found Android bundle
✓ A JDK is installed
✓ Found Android Platform tools
Installing Android Build Tools

/Users/lenville/.meteor/packages/meteor-tool/.1.0.45.1y6cwq8++os.osx.x86_64+web.browser+web.cordova/mt-os.osx.x86_64/dev_bundle/lib/node_modules/fibers/future.js:278
                        throw(ex);
```

参考[Issue 4047](https://github.com/meteor/meteor/issues/4047)， 说是GFW的功劳，翻个墙就ok了。

第2、3两条命令，就不知道怎么处理了。


## 参考文献

1. <https://www.meteor.com/install>
