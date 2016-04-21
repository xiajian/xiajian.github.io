---
layout: post
title: Master Password密码使用    
description: '密码管理，任意平台的密码管理，极客电台'
category: note
---

## 前言

[Master Password](https://github.com/Lyndir/MasterPassword)保存密码的方式，使用了独特的同一的加密算法。在输入参数相同的相同的下，
使用相同的算法，生成的密码是相同的。

其实现的存储和同步密码方式就是不同步密码，使用**独一无二的算法**同一性的算法实现。

##  正文

Master Password 的 Github 地址： 

1. <https://github.com/Lyndir/MasterPassword>
2. <http://masterpasswordapp.com/>

Mac OS 安装命令行： 

```
$ brew install mpw

# 使用
✗ mpw
Your full name: test
Site name: test.com
Your master password:
test's password for test.com:
[ ╔░╗♚ ]: HakvJirySako2_
```

帮助命令介绍，使用说明： 

```
✗ mpw -h
Usage: mpw [-u name] [-t type] [-c counter] site
```

生成密码 和 查看密码： 

```
✗ mpw test.com
Your full name: test
Your master password:
test's password for test.com:
[ ╰░╯♔ ]: Kupu3$BexoJovh
✗ mpw  -u test test.com
Your master password:
test's password for test.com:
[ ╰░╯♔ ]: Kupu3$BexoJovh
```

PS： 

自己收藏了一个 shell 生成密码的函数：

```
function generate_password() {
  if [[ $# == 0 ]] ; then
    len=8
  else
    len=$1
  fi
  # str=(a b c d e f g h i j k l m n o p q r s t u vw x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 1 2 3 4 5 6 7 8 9 0 \! \@ \# \$ \% \^ \& \* \( \) \- \_ \= \+ \\ \/ \' \" \; \: \[ \] \{ \} \, \. \?) 
  str=(a b c d e f g h i j k l m n o p q r s t u vw x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 1 2 3 4 5 6 7 8 9 0) 
  for (( i=1; i<=$len; i++)); do 
      arr[$i]=${str[$[$RANDOM%87]]} 
  done; 
  echo "${arr[@]}" | tr -d " "
}
```

## Gif 社区

24岁的美国年轻人： <http://imgur.com/>。

## Payoneer 账号

在中国注册 [Payoneer](https://www.payoneer.com/zh/usps/?utm_source=Baidu&utm_medium=search&utm_campaign=pcard&kw=payoneer)。

Payoneer 只支持别人转账给你，非常方便的用在做外贸生意，和挣外国人的钱。 亚马逊日本和美国，有些正对美国人的优惠。

## 后记

今天，收听了[极客电台](https://geek.wasai.org)。 收听一下，感觉相当不多。