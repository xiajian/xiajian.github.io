---
layout: post
title: Erubis Users' Guide
---

## Preface

Erubis is an implementation of eRuby. It has the following features.

* Very fast, almost three times faster than ERB and about ten percent faster than eruby (implemented in C)
* File caching of converted Ruby script support
* Auto escaping support
* Auto trimming spaces around '<% %>'
* Embedded pattern changeable (default '<% %>')
* Enable to handle Processing Instructions (PI) as embedded pattern (ex. '<?rb ... ?>')
* Multi-language support (Ruby/PHP/C/Java/Scheme/Perl/Javascript)
* Context object available and easy to combine eRuby template with YAML datafile
* Print statement available
* Easy to expand and customize in subclass
* Ruby on Rails support
* mod_ruby support|#topcs-modruby
* Erubis is implemented in pure Ruby. It requires Ruby 1.8 or higher. Erubis now supports Ruby 1.9.

指南的描述结构如下：第一章介绍了安装，第二章介绍了如何使用，第三章描述erubis的增强，第四章描述了多语言的支持，第五章讨论Rails的支持，第六章讨论了其他的一些议题，第七章介绍了命令行工具。

## Chapter 1 安装

```sh
gem install erubis
```

## Chapter 2 指南

### 2.1 简单的例子

```erb
# ex1.erb
<ul>
  <% for item in list %>
    <li><%= item %></li>
  <% end %>
  <%# 这里是注释  %>
</ul>
```

```ruby
# ex1.rb
require 'erubis'
input = File.read "./ex1.erb"
erb = Erubis::Eruby.new input

puts "---------- script source ------------"
puts erb.src

puts "----------- result ------------------"
list = ['aaa', 'bbb', 'ccc' ]
# puts erb.result binding 
puts erb.result(:list => list)
```

输出结果:

```
---------- script source ------------
_buf = ''; _buf << '<ul>  # 这里_buf = ''是Preamble
';   for item in list 
 _buf << '    <li>'; _buf << ( item ).to_s; _buf << '</li>
';   end 

 _buf << '</ul>
';
_buf.to_s # Postamble
----------- result ------------------
<ul>
    <li>aaa</li>
    <li>bbb</li>
    <li>ccc</li>
</ul>
```

**备注**: 虽然之前有想过，erb需要被解析并且转换。没想到，居然是解析成ruby代码，然后通过追加字符串的方式实现的。

从生成的字符串中，可以看到，erubis自动删除`<% %>`周围的空格。在`Erubis::Eruby.new(input, :trim=>false)`中，可以手动设置`:trim`为true

```erb
<%= item %>   # ( item ).to_s
<%== item %>  # Erubis::XmlHelper.escape_xml( item ) - 转义
<%=== item %> # $stderr.puts("*** debug: item=#{(item).inspect}"); 标准输出
```

通过`:pattern`选项，可以用其他的模式代替`<% %>`。

### 2.2 上下文对象

```erb
// ex2.erb
<span><%= @val %></span>
<ul>
  <% for item in @list %>
    <li><%= item %></li>
  <% end %>  
</ul>
```

```ruby
require 'erubis'
input = File.read "erb/ex2.erb"
erb = Erubis::Eruby.new input
context = { val: "Erubis Example", list: ['aaa', 'bbb', 'ccc'] }
puts erb.evaluate context
```

**注**: rails的erb中有for，if等片段的扩展。

`Erubis#result(binding)`和`Erubis#evaluate(context)`之间的区别在于: `Erubis#result`调用了`eval @src, binding`, `Erubis#evaluate`调用了`context.instance_eval @src`。具体的实现，可以参考erubis的源代码。

这表明，调用`Eruby::binding()`时，数据是通过局部变量传递的，而调用`Eruby::evaluate()`，数据是通过实例变量定义的。

此外，`instance_eval`是由Object类定义的，`evaluate`函数参数可以为任何对象。

推荐使用`evaluate`，而不是`binding`，这是因为后者存在一些问题。

### 2.3 上下文数据文件(Content Data file)

erubis的命令行-f选项，接受特定的数据文件(可以是yaml或ruby脚本)

```erb
<h1><%= @title %></h1>
<ul>
  <% for user in  @users %>
    <li> <a href="mailto:<%= user['mail'] %>"><%= user['name'] %></a> </li>
  <% end %>
</ul>
```

```ruby
# convert.rb
@title = 'Users List'
@users = [
   { 'name'=>'foo', 'mail'=>'foo@mail.com' },
   { 'name'=>'bar', 'mail'=>'bar@mail.net' },
   { 'name'=>'baz', 'mail'=>'baz@mail.org' },
]
# convert.yml
title: Users List
users:
  - name:  foo
    mail:  foo@mail.com
  - name:  bar
    mail:  bar@mail.net
  - name:  baz
    mail:  baz@mail.org
```

调用命令：`erubis -f context.yaml xxx.erb`

### 处理指令转化器

Erubis可将处理指令解析为嵌入模式: 

* `<?rb ... ?>` 表示Ruby语句
* `@{...}@` 代表转义表达式的值
* `@!{...}@` 表示正常表达式的值
* `@!!{...}@` 表示将值输出到标准输出中

erubis的`-x`选项可以用来提出ruby代码。

## Enhancer

Enhancer是一个用来给`Erubis::Eruby`添加特性的模块。使用Enhancer，需要定义`Erubis::Eruby`的子类，并包含相应的模块: 

```ruby
class MyEruby < Erubis::Eruby
  include EscapeEnhancer
  include PercentLineEnhancer
  include BiPatternEnhancer
end
```

可以通过`-E`选项来指定特定的加强，例如`erubis -xE Escape,PercentLine,BiPattern example.eruby`

加强的列表: 

* EscapeEnhander (语言无关) 装换`<%= %>`和`<%== %>`原本的语义
* StdoutEnhancer (仅Eruby) 使用$stdout代替array buffer. 
* PrintOutEnhancer (仅Eruby) 使用`print(...)`代替`_buf << ...`
* PrintEnabledEnhancer (仅Eruby) 在`<% ... %>`中启用print. 
* ArrayEnhancer (仅Eruby) 返回字符串数组而不是字符串 
* ArrayBufferEnhancer (仅Eruby) 使用array buffer，比StringBufferEnhancer慢些
* StringBufferEnhancer (仅Eruby) 使用string buffer，默认包含在Erubis::Eruby中
* ErboutEnhancer (仅Eruby) 设置`_erbout = _buf = "";`兼容erb
* NoTextEnhancer (语言无关) 仅打印嵌入代码并忽略文本 
* NoCodeEnhancer (语言无关) 仅打印文本忽略代码 
* SimplifyEnhancer (语言无关) 快速编译，但不剔除`<% %>`中的空格 
* BiPatternEnhancer (language-independent) [experimental] Enable to use another embedded pattern with `<% %>`. 
* PercentLineEnhancer (language-independent) Regard lines starting with '%' as Ruby code. This is for compatibility with eruby and ERB. 
* HeaderFooterEnhancer (language-independent) [experimental] Enable you to add header and footer in eRuby script. 
* InterpolationEnhancer (only for Eruby) [experimental] convert `<p><%= text %></p>` into `_buf << %Q{<p>#{text}</p>}`. 
* DeleteIndentEnhancer (language-independent) [experimental] delete indentation of HTML file and eliminate page size.

Erubis可以支持多种语言。

## Ruby on Rails Support

Rails 3 中内建了Erubis的支持，具体就是各种辅助方法。rails中，转换html的h函数实现示例: 

```ruby
ESCAPE_TABLE = { '&'=>'&amp;', '<'=>'&lt;', '>'=>'&gt;', '"'=>'&quot;', "'"=>'&#039;', }
def h(value)
 value.to_s.gsub(/[&<>"]/) { |s| ESCAPE_TABLE[s] }
end
```

## Other Topics

### Erubis::FastEruby Class

Erubis::FastEruby class generates more effective code than Erubis::Eruby.

```ruby
fasteruby-example.rb
require 'erubis'
input = File.read('example.eruby')

puts "----- Erubis::Eruby -----"
print Erubis::Eruby.new(input).src

puts "----- Erubis::FastEruby -----"
print Erubis::FastEruby.new(input).src
```

结果显示: 

Technically, Erubis::FastEruby is just a subclass of Erubis::Eruby and includes InterpolationEnhancer. Erubis::FastEruby is faster than Erubis::Eruby but is not extensible compared to Erubis::Eruby. This is the reason why Erubis::FastEruby is not the default class of Erubis.

### :bufvar Option

Since 2.7.0, Erubis supports :bufvar option which allows you to change buffer variable name (default '_buf').

```ruby
# bufvar-example.rb
require 'erubis'
input = File.read('example.eruby')

puts "----- default -----"
eruby = Erubis::FastEruby.new(input)
puts eruby.src

puts "----- with :bufvar option -----"
eruby = Erubis::FastEruby.new(input, :bufvar=>'@_out_buf')
print eruby.src
```

结果显示：


### '<%= =%>' and '<%= -%>'

Since 2.6.0, '<%= -%>' remove tail spaces and newline. This is for compatibiliy with ERB when trim mode is '-'. '<%= =%>' also removes tail spaces and newlines, and this is Erubis-original enhancement (cooler than '<%= -%>', isn't it?).

```html
tailnewline.rhtml
<div>
<%= @var -%>          # or <%= @var =%>
</div>
```

结果


### '<%% %>' and '<%%= %>'

Since 2.6.0, '<%% %>' and '<%%= %>' are converted into '<% %>' and '<%= %>' respectively. This is for compatibility with ERB.

```html
doublepercent.rhtml:
<ul>
<%% for item in @list %>
  <li><%%= item %></li>
<%% end %>
</ul>
```

结果显示: 

### evaluate(context) v.s. result(binding)

It is recommended to use 'Erubis::Eruby#evaluate(context)' instead of 'Erubis::Eruby#result(binding)' because Ruby's Binding object has some problems.

    It is not able to specify variables to use. Using binding() method, all of local variables are passed to templates.
    Changing local variables in templates may affect to varialbes in main program. If you assign '10' to local variable 'x' in templates, it may change variable 'x' in main program unintendedly.

The following example shows that assignment of some values into variable 'x' in templates affect to local variable 'x' in main program unintendedly.
template1.rhtml (intended to be passed 'items' from main program)

```erb
<% for x in items %>
item = <%= x %>
<% end %>
** debug: local variables=<%= local_variables().inspect() %>
```

main_program1.rb (intended to pass 'items' to template)

```ruby
require 'erubis'
eruby = Erubis::Eruby.new(File.read('template1.rhtml'))
items = ['foo', 'bar', 'baz']
x = 1
## local variable 'x' and 'eruby' are passed to template as well as 'items'!
print eruby.result(binding())    
## local variable 'x' is changed unintendedly because it is changed in template!
puts "** debug: x=#{x.inspect}"  #=> "baz"
```

结果:

This problem is caused because Ruby's Binding class is poor to use in template engine. Binding class should support the following features.

```ruby
b = Binding.new     # create empty Binding object
b['x'] = 1          # set local variables using binding object
```

But the above features are not implemented in Ruby.

A pragmatic solution is to use 'Erubis::Eruby#evaluate(context)' instead of 'Erubis::Eruby#result(binding)'. 'evaluate(context)' uses Erubis::Context object and instance variables instead of Binding object and local variables.
template2.rhtml (intended to be passed '@items' from main program)

```erb
<% for x in @items %>
item = <%= x %>
<% end %>
** debug: local variables=<%= local_variables().inspect() %>
```

main_program2.rb (intended to pass '@items' to template)

```ruby
require 'erubis'
eruby = Erubis::Eruby.new(File.read('template2.rhtml'))
items = ['foo', 'bar', 'baz']
x = 1
## only 'items' are passed to template
print eruby.evaluate(:items=>items)    
## local variable 'x' is not changed!
puts "** debug: x=#{x.inspect}"  #=> 1
```


### Class Erubis::FastEruby

Erubis provides Erubis::FastEruby class which includes InterpolationEnhancer and works faster than Erubis::Eruby class. If you desire more speed, try Erubis::FastEruby class.

File 'fasteruby.rhtml':

```erb
<html>
  <body>
    <h1><%== @title %></h1>
    <table>
<% i = 0 %>
<% for item in @list %>
<%   i += 1 %>
      <tr>
        <td><%= i %></td>
        <td><%== item %></td>
      </tr>
<% end %>
    </table>
  </body>
</html>
```

File 'fasteruby.rb':

```ruby
require 'erubis'
input = File.read('fasteruby.rhtml')
eruby = Erubis::FastEruby.new(input)    # create Eruby object

puts "---------- script source ---"
puts eruby.src

puts "---------- result ----------"
context = { :title=>'Example', :list=>['aaa', 'bbb', 'ccc'] }
output = eruby.evaluate(context)
print output
```



### Syntax Checking

Command-line option '-z' checks syntax. It is similar to 'erubis -x file.rhtml | ruby -wc', but it can take several file names.

```sh
$ erubis -z app/views/*/*.rhtml
Syntax OK
```

### File Caching

`Erubis::Eruby.load_file(filename)` convert file into Ruby script and return Eruby object. In addition, it caches converted Ruby script into cache file (filename + '.cache') if cache file is old or not exist. If cache file exists and is newer than eruby file, Erubis::Eruby.load_file() loads cache file.
example of Erubis::Eruby.load_file()

```ruby
require 'erubis'
filename = 'example.rhtml'
eruby = Erubis::Eruby.load_file(filename)
cachename = filename + '.cache'
if test(?f, cachename)
  puts "*** cache file '#{cachename}' created."
end
```

Since 2.6.0, it is able to specify cache filename.
specify cache filename.

filename = 'example.rhtml'
eruby = Erubis::Eruby.load_file(filename, :cachename=>filename+'.cache')

Caching makes Erubis about 40-50 percent faster than no-caching. See benchmark for details.

### Erubis::TinyEruby class

Erubis::TinyEruby class in 'erubis/tiny.rb' is the smallest implementation of eRuby. If you don't need any enhancements of Erubis and only require simple eRuby implementation, try Erubis::TinyEruby class.


### Helper Class for mod_ruby

Thanks Andrew R Jackson, he developed 'erubis-run.rb' which enables you to use Erubis with mod_ruby.

    Copy 'erubis-2.7.0/contrib/erubis-run.rb' to the 'RUBYLIBDIR/apache' directory (for example '/usr/local/lib/ruby/1.8/apache') which contains 'ruby-run.rb', 'eruby-run.rb', and so on.

    $ cd erubis-2.7.0/
    $ sudo copy contrib/erubis-run.rb /usr/local/lib/ruby/1.8/apache/

    Add the following example to your 'httpd.conf' (for example '/usr/local/apache2/conf/httpd.conf')

    LoadModule ruby_module modules/mod_ruby.so
    <IfModule mod_ruby.c>
      RubyRequire apache/ruby-run
      RubyRequire apache/eruby-run
      RubyRequire apache/erubis-run
      <Location /erubis>
        SetHandler ruby-object
        RubyHandler Apache::ErubisRun.instance
      </Location>
      <Files *.rhtml>
        SetHandler ruby-object
        RubyHandler Apache::ErubisRun.instance
      </Files>
    </IfModule>

    Restart Apache web server.

    $ sudo /usr/local/apache2/bin/apachectl stop
    $ sudo /usr/local/apache2/bin/apachectl start

    Create *.rhtml file, for example:

    <html>
     <body>
      Now is <%= Time.now %>
      Erubis version is <%= Erubis::VERSION %>
     </body>
    </html>

    Change mode of your directory to be writable by web server process.

    $ cd /usr/local/apache2/htdocs/erubis
    $ sudo chgrp daemon .
    $ sudo chmod 775 .

    Access the *.rhtml file and you'll get the web page.

You must set your directories to be writable by web server process, because Apache::ErubisRun calls Erubis::Eruby.load_file() internally which creates cache files in the same directory in which '*.rhtml' file exists.

### Helper CGI Script for Apache

Erubis provides helper CGI script for Apache. Using this script, it is very easy to publish *.rhtml files as *.html.

```sh
### install Erubis
$ tar xzf erubis-X.X.X.tar.gz
$ cd erubis-X.X.X/
$ ruby setup.py install
### copy files to ~/public_html
$ mkdir -p ~/public_html
$ cp public_html/_htaccess   ~/public_html/.htaccess
$ cp public_html/index.cgi   ~/public_html/
$ cp public_html/index.rhtml ~/public_html/
### add executable permission to index.cgi
$ chmod a+x ~/public_html/index.cgi
### edit .htaccess
$ vi ~/public_html/.htaccess
### (optional) edit index.cgi to configure
$ vi ~/public_html/index.cgi
```

Edit ~/public_html/.htaccess and modify user name.

~/public_html/.htaccess

```
## enable mod_rewrie
RewriteEngine on
## deny access to *.rhtml and *.cache
#RewriteRule \.(rhtml|cache)$ - [R=404,L]
RewriteRule \.(rhtml|cache)$ - [F,L]
## rewrite only if requested file is not found
RewriteCond %{SCRIPT_FILENAME} !-f
## handle request to *.html and directories by index.cgi
RewriteRule (\.html|/|^)$ /~username/index.cgi
#RewriteRule (\.html|/|^)$ index.cgi
```
After these steps, *.rhtml will be published as *.html. For example, if you access to http://host.domain/~username/index.html (or http://host.domain/~username/), file ~/public_html/index.rhtml will be displayed.

### Define method

Erubis::Eruby#def_method() defines instance method or singleton method.

```ruby
require 'erubis'
s = "hello <%= name %>"
eruby = Erubis::Eruby.new(s)
filename = 'hello.rhtml'

## define instance method to Dummy class (or module)
class Dummy; end
eruby.def_method(Dummy, 'render(name)', filename)  # filename is optional
p Dummy.new.render('world')    #=> "hello world"

## define singleton method to dummy object
obj = Object.new
eruby.def_method(obj, 'render(name)', filename)    # filename is optional
p obj.render('world')          #=> "hello world"
```

### Benchmark

A benchmark script is included in Erubis package at 'erubis-2.7.0/benchark/' directory. Here is an example result of benchmark.
MacOS X 10.4 Tiger, Intel CoreDuo 1.83GHz, Ruby1.8.6, eruby1.0.5, gcc4.0.1

```
$ cd erubis-2.7.0/benchmark/
$ ruby bench.rb -n 10000 -m execute
*** ntimes=10000, testmode=execute
                                    user     system      total        real
eruby                          12.720000   0.240000  12.960000 ( 12.971888)
ERB                            36.760000   0.350000  37.110000 ( 37.112019)
ERB(cached)                    11.990000   0.440000  12.430000 ( 12.430375)
Erubis::Eruby                  10.840000   0.300000  11.140000 ( 11.144426)
Erubis::Eruby(cached)           7.540000   0.410000   7.950000 (  7.969305)
Erubis::FastEruby              10.440000   0.300000  10.740000 ( 10.737808)
Erubis::FastEruby(cached)       6.940000   0.410000   7.350000 (  7.353666)
Erubis::TinyEruby               9.550000   0.290000   9.840000 (  9.851729)
Erubis::ArrayBufferEruby       11.010000   0.300000  11.310000 ( 11.314339)
Erubis::PrintOutEruby          11.640000   0.290000  11.930000 ( 11.942141)
Erubis::StdoutEruby            11.590000   0.300000  11.890000 ( 11.886512)
```

This shows that...

*  Erubis::Eruby runs more than 10 percent faster than eruby.
*  Erubis::Eruby runs about 3 times faster than ERB.
*  Caching (by Erubis::Eruby.load_file()) makes Erubis about 40-50 percent faster.
*  Erubis::FastEruby is a litte faster than Erubis::Eruby.
*  Array buffer (ArrayBufferEnhancer) is a little slower than string buffer (StringBufferEnhancer which Erubis::Eruby includes)
*  $stdout and print() make Erubis a little slower.
*  Erubis::TinyEruby (at 'erubis/tiny.rb') is the fastest in all eRuby implementations when no caching.

Escaping HTML characters (such as '< > & "') makes Erubis more faster than eruby and ERB, because Erubis::XmlHelper#escape_xml() works faster than CGI.escapeHTML() and ERB::Util#h(). The following shows that Erubis runs more than 40 percent (when no-cached) or 90 percent (when cached) faster than eruby if HTML characters are escaped.
When escaping HTML characters with option '-e'

```
$ ruby bench.rb -n 10000 -m execute -ep
*** ntimes=10000, testmode=execute
                                    user     system      total        real
eruby                          21.700000   0.290000  21.990000 ( 22.050687)
ERB                            45.140000   0.390000  45.530000 ( 45.536976)
ERB(cached)                    20.340000   0.470000  20.810000 ( 20.822653)
Erubis::Eruby                  14.830000   0.310000  15.140000 ( 15.147930)
Erubis::Eruby(cached)          11.090000   0.420000  11.510000 ( 11.514954)
Erubis::FastEruby              14.850000   0.310000  15.160000 ( 15.172499)
Erubis::FastEruby(cached)      10.970000   0.430000  11.400000 ( 11.399605)
Erubis::ArrayBufferEruby       14.970000   0.300000  15.270000 ( 15.281061)
Erubis::PrintOutEruby          15.780000   0.300000  16.080000 ( 16.088289)
Erubis::StdoutEruby            15.840000   0.310000  16.150000 ( 16.235338)
```

## 命令参考

Usage: erubis [..options..] [file ...]

```sh
  -h, --help    : help
  -v            : version
  -x            : show converted code
  -X            : show converted code, only ruby code and no text part
  -N            : numbering: add line numbers            (for '-x/-X')
  -U            : unique: compress empty lines to a line (for '-x/-X')
  -C            : compact: remove empty lines            (for '-x/-X')
  -b            : body only: no preamble nor postamble   (for '-x/-X')
  -z            : syntax checking
  -e            : escape (equal to '--E Escape')
  -p pattern    : embedded pattern (default '<% %>')
  -l lang       : convert but no execute (ruby/php/c/cpp/java/scheme/perl/js)
  -E e1,e2,...  : enhancer names (Escape, PercentLine, BiPattern, ...)
  -I path       : library include path
  -K kanji      : kanji code (euc/sjis/utf8) (default none)
  -c context    : context data string (yaml inline style or ruby code)
  -f datafile   : context data file ('*.yaml', '*.yml', or '*.rb')
  -T            : don't expand tab characters in YAML file
  -S            : convert mapping key from string to symbol in YAML file
  -B            : invoke 'result(binding)' instead of 'evaluate(context)'
  --pi=name     : parse '<?name ... ?>' instead of '<% ... %>'
```

## 后记

看完后，感觉没什么特别深入的认识。而且，看到一半，觉得特别的无聊，有空再继续看吧。
