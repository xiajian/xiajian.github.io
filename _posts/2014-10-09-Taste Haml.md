---
layout: post
title: Taste Haml
---

人活着怎么能够没有爱，erb就是没有爱的标签语言。而Haml，满满的都是爱。

Haml的官方网站: <http://haml.info/>  ; github代码库： <https://github.com/haml/haml>

照着手册改erb为haml，遇到的第一个问题是:

1. Ruby代码中的end不是必须的，使用缩进解决问题
2. `syntax error, unexpected keyword_class, expecting keyword_do or '{' or '('` 这样的错误是因为括号没有闭合的原因。
3. 由于使用缩进作为标签闭合的方式，所以，存在TAB和空格的区别的问题，这种问题会导致编译错误。具体的就是，空格和制表混用的时候，会出错。解决方法:g/\t/s//  /g
4. 由于render部分视图的原因，所以会出现一些在index中的语法错误，现在所能想到的方法是，使用`haml`对那个部分视图进行编译，然后，找到其错误的行号。

一些全局替换(由erb到haml)的命令：

    g/<%/s///g
    g/%>/s///g
    g/<t/s//%t/g
    g/\t/s//  /g
    g/<\/t[h|d]>/s///g
    g/>=/s//=/g
    g/<\/.*/s///g
    g/">/s//")/g

特定文件的导航文件的替换命令:

    g/<u/s//%u/g
    g/<l/s//%l/g
    g/<i/s//%i/g
    g/">/s//")/g
    g/<span>/s//%span /g
    g/= ' active/s//#{' active/g

每次都使用vim的ex-mode进行替换，文件有非常的多，并相当的繁琐。决定使用sed批量的进行文件的替换(试用了一下，效果好可以):

    sed -i 's/<%//' **/*.haml ; sed -i 's/%>//' **/*.haml ; sed -i 's/\t/  /' **/*.haml
    sed -i 's/">/")/' **/*.haml

index特定的文件的替换: 

sed -i 's/<t/%t/' **/index.html.haml ; sed -i 's/>=/=/' **/index.html.haml

nav文件的替换

    sed -i 's/<u/%u/' **/_nav.html.haml ; sed -i 's/<l/%l/' **/_nav.html.haml ; sed -i 's/<i/%i/' **/_nav.html.haml ; sed -i 's/<span>/%span /' **/_nav.html.haml ; sed -i 's/= ' active/#{' active/' **/_nav.html.haml
    sed -i "s/= " active/#{' active/" **/_nav.html.haml
    sed -i "s/' \"/'}\"/" **/_nav.html.haml
    sed -i "s/^ cpanel/- cpanel/" **/*.haml
    sed -i "s/<\/i> %span/%span/" **/_nav.html.haml
    sed -i "s/<\/.*//" **/*.haml

想要删除空白行，尝试命令:

sed -i "s/^ *$//" **/*.haml
sed -i "s/th class=\"menu_actions\"/th(class=\"menu_actions\")/" **/index.html.haml

执行之后，发现这是个替换命令，没有得到想要的结果，查找了一下sed删除行的方法。

    sed -i "/^ *$/d"  **/*.haml
    sed -i "/^ *end *$/d"  **/*.haml

syntax error, unexpected ')' 往往是因为缩进不合理，不能解析。

多条sed命令执行之间会存在一定问题。

使用单引号('')将替换表达式包裹起来时，如果替换表达式中也包含单引号，就会出错，此时，需要使用双引号("")，双引号表达式中包含双引号时，需要用\转义。

缩进不合理就会报错。

vim中删除空行： g/^ *$/,d

由于需要批量的执行这些ex命令，所以想知道是否存在批量执行这些命令的方式。结果，找到了`ex-mode`的这个方法，可以不用每次输入:, 进入该模式的方法的命令为`gQ`。

觉得VIM中的正则匹配稍微有点怪，可能我对正则表达式的掌握也是有些问题的，匹配</td>这样的文本需要`<\/.*`这样的表达式，`\w`和`+`好像都不太管用。

爱是盲目的，不产生任何价值的。后台用erb写也没什么太大的问题，要改成haml，就要进行各种复杂的文本替换。

干啥事都会存在倦怠期，尤其是在处理erb转换为haml的半山腰上。
