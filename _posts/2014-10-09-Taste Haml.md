---
layout: post
title: Taste Haml
---

人活着怎么能够没有爱，erb就是没有爱的标签语言。而Haml，满满的都是爱。

照着手册改erb为haml，遇到的第一个问题是:

1. Ruby代码中的end不是必须的，使用缩进解决问题
2. `syntax error, unexpected keyword_class, expecting keyword_do or '{' or '('` 这样的错误是因为括号没有闭合的原因。
3. 由于使用缩进作为标签闭合的方式，所以，存在TAB和空格的区别的问题，这种问题会导致编译错误。
