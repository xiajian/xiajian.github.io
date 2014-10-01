---
layout: post
title: 利用Jekyll Now写博客
---
缘起
===========
诸多原因，促成了决定使用Github Pages。
- 很早就注册了Github的帐号，除了clone代码以外，似乎都没做什么特别有意思的事情。
- 最近在学习Mongodb的Ruby驱动：Mongoid,搜了一圈，发现没什么中文文档，刚好自己也要学习，此时，就再次秀一下我蹩脚的英语
- 之前在CSDN上写博客时，起初用其自带的web编辑器，随后，用了一段时间WPS + copy & plaste。一直不能满意，想要使用VIM。
- 最后，自己好歹也是个web开发者，想多了解了解CSS和html之类的，想尝试一下Markdown。
综上所述，我尝试了一下Jekyll+ Github写博客。

正文
============
虽然知道最终的目标是，在Github上搭建自己的博客(或者github pages)，具体如何操作，却没个主意。盯着屏幕发了一会儿呆，最初是在哪看到Jelyll这玩意的？好像是阮一峰的博客，对了，阮一峰写了个关于Jelyll的博客。这话好假，我果然不太擅长叙事。
参考阮一峰的《搭建一个免费的，无限流量的Blog》，通读全文大概知道如何处理了，但是，觉得要自己处理模板、样式之类，还是比较繁琐的。但也大概的知道了如何处理，去Github上jekyll的项目库上看了看，项目简介中有个有多网站使用了Jekyll的介绍，点了进去后，随机点了个看了看，挺不错的。无意见点了barryclark，看到了其介绍中有个Jekyll Now，号称30秒建立一个博客。哈，30秒啊，可以试试。
然后我就是试了试，先是fork到自己的用户目录下，然后点击右边的settings，最后，修改版本库的名字，修改为name.github.io这种格式，然后点击rename，然后需要点击一下Automatic Page generator(一开始忘记点击了输入好几次都是Pages not find)。
搞完了远程的，搞本地的。
将Jekyll now克隆下来，让后在本地安装相应的环境，比如Ruby、jekyll之类的。具体的，可以通过rvm安装ruby，然后安装一些其他的gem包。操作如下：

- 克隆jekyll now: git clone git@github.com:yourusername/yourusername.github.io.git
- 安装rvm: \curl -sSL https://get.rvm.io | bash -s stable
- 安装ruby(这里使用的1.9.3的ruby,也可以使用其他版本): rvm install 1.9.3 
- 安装相关gem包: gem install jekyll jemoji jekyll-sitemap

注: 使用git@github.com的地址clone和https的方式的主要区别如下

1. 权限不同，https的方式，任何人都可以使用，git@的放置，github用户信任的机器才可使用（即上传了ssh key） 
2. .git目录下的config文件中[remote "origin"]中的url的不同，这使得用https克隆的版本库每次push时都需要输入用户名和密码

后记
=========== 
查看Jelyll Now的文件大小时，发现，项目占13Mb，版本库居然占9点几兆。很不爽，想要干掉版本库，折腾了好究git rebase、git prune、git gc，废去了好几个小时，版本只减少了一点。最后，放弃了。


