---
layout: post
title: 一些自写Ruby脚本的合集
---

## 缘起

好歹也是个Ruby工程师，说出去怕被人笑话。和Ruby相比，我其实更熟悉shell，因为后者的学习时间更长，也常写一些自用的函数和别名。

工作时，遇到的有些任务可以自动化处理，简单也许两三条命令搞定，复杂的可能需要一个脚本。以下是自己的写的一些脚本的例子。内容持续添加。

### 其一：将汉字转换为拼音，并提取其首字母，形成首字母大写的简写

```ruby
# convert.rb - 这是一个用完就扔的转换文本的脚本
# 输入文件： 每行两列(中文名，代码)，以tab分隔，
# 输出文件：每行三列(中文名，代码，首字母拼音)，以tab分隔
# 辅助函数：汉字转拼音的gem包
# 小记：第一次编写Ruby脚本，感觉还不错
require "hz2py"

input = "/home/xiajian/works/test/new_stock_less.txt"
output = "/home/xiajian/works/test/stock.txt"

f = File.open(input ,"r+")
o = File.new(output,"w+")

def hz2py(name)
  tmp=""
  Hz2py.do(name).split(" ").each { |x| tmp << x[0] }
  tmp.upcase
end

p "convert start ........"
f.each_line do |line| 
  st = line.chomp.split("\t")
  o.puts("#{st[0]}\t#{st[1]}\t"+hz2py(st[0]))
end
# 关闭文件，之前一直没有关闭文件，担心有问题，所以添加了文件关闭
f.close
o.close
p "convert over .........
```

### 其二 测试获取传递参数的脚本

```ruby
# 这是一个用来测试Ruby读写特定文件测试脚本
# 文件的格式，一行一列，以tab作为分隔
if ARGV.size == 0
  file="/home/xiajian/works/test/new_stock.txt"
else
  file="/home/xiajian/works/test/#{ARGV[0]}"
end

f= File.open(file ,"r+")
p "Print testing......"
f.each_line do |line| 
  tmp= line.chomp.split("\t")
  tmp.each do |x|
    p x
  end
end
f.close
p "testing is over....."

# Test input: ruby readfile.rb xijain
# Output: 
# This is test for get something,xijain
# The second way: ["xijain"]  - #{ARGV}
# The second way: xijain - #{ARGV[0]}
#
# 第一种获取命令行参数的方式
# puts "This is test for get something," + $*[0]

# 第二种获得命令行参数的方式
# puts "The second way: #{ARGV[0]}"
# puts "Total arguement number:#{ARGV.size}"
```

### 其三 将包含@xxx+[:| ]的字符串转换为链接

```ruby
i = "@user: ,@xijia @tete @jieeefe, @dfaewf: @121L: @jifjei"
i.gsub(/@.+?[:| ]/).each { |x| "<a href="+">#{x}</a>" }
```

### 其四 将某个文件下全部的*.erb文件名替换为*.haml文件

```ruby
Dir["**/*.erb"].each do |file|
  file.split("erb").each do |x|
    n = x + "haml"
    p 
    system "mv #{file} #{n}"
  end
end
# Ruby中执行shell命令的方式: exec "" , `` , system ""等等
# 文件的命名如下areas/show.html.erb，偶然发现，split以字符串分割挺方便的。
```

> 经验： 在irb中测试，然后在将语句汇总成脚本。这样比编写脚本，然后运行测试快多了。当然，shell也可以这么处理，事实证明，成功的概率大多了。

### 其五 计算留存率的问题

```ruby
# 原本想使用前置++和后置++的，由于在代码块中闭包的问题，没能成功。
# Rails中数字和时间处理方法确实灵活
c, d, h = 0,0,0
User.where("created_at >= ? ", 6.days.ago).each do  |x|
   c+=1
   d+=1 if (x.last_sign_in_at - x.created_at) >= 1.days
   h+=1 if (x.last_sign_in_at - x.created_at) >= 1.hours
end
p "间隔一天的三日留存率为: #{(d.to_f/c*100).round(2)}%"
p "间隔一小时的三日留存率为: #{(h.to_f/c*100).round(2)}%"
```

留存率的扩展版本：

```ruby
def exist_rate(date, num)
  c = User.where(:created_at => (date .. date.tomorrow) ).count
  return [0.0 , 0 , 0] if c == 0
  s = User.where(:created_at => (date..date.tomorrow) ).where(:last_sign_in_at => (date+1.days .. date+num.days ) ).count
  [(s.to_f/c*100).round(2), c , s ]
end
      
o = File.new("/home/lodestone/users.txt","w+")
o.puts("日期\t3日留存率\t7日留存率\t15日留存率\t30日留存率\t")
(Date.parse("2014-7-1")..Date.today).to_a.map(&:at_beginning_of_day).each do |date|
  rate = []
  [3,7,15,30].each do |x|
    rate << exist_rate(date, x+1 )
  end
  o.puts "#{date.to_date}\t#{rate[0][0]}(#{rate[0][2]}/#{rate[0][1]})\t#{rate[1][0]}(#{rate[1][2]}/#{rate[1][1]})\t#{rate[2][0]}(#{rate[2][2]}/#{rate[2][1]})\t#{rate[3][0]}(#{rate[3][2]}/#{rate[3][1]})"
end
o.close
```

清空数据的方法:

```ruby
UserStatistics.each do |x|
  x.rate = []  # 之前尝试`=||`操作，忽略了其根本的语义。
  x.save!
end
```

对于历史遗留的数据，采用的rake任务导入，并使用新打开的类UserStatistics的中的方法。

```ruby
desc "设置留存率的历史计算"
 task  :statistics => :environment do
   (Date.parse("2014-7-1")..Date.today).each do |day|
     UserStatistics.calc_rate(day)
 end
 p "done"
end
```

下面是一个打开的model类:

```ruby
class UserStatistics
  # 三日留存率, date表示日期，num为留存率参数
  def exist_rate(date, num)
    c = User.where(:created_at => (date .. date.tomorrow) ).count
    return 0.0 if c == 0
    s = User.where(:created_at => (date..date.tomorrow) ).where(:last_sign_in_at => (date+1.days .. date+num.days) ).count
    (s.to_f/c*100).round(2)
  end
  
  # 留存率的部分，分别计算三日，7日，15日以及30日留存率，三天即需要向前推4天。
  def self.calc_rate(date)
    [3,7,15,30].each_with_index do |x,idx|
      start = date - (x+1).days
      us = UserStatistics.where(:date => date).first
      if !us.blank? && us.rate[idx].blank?
        us.rate[idx] = us.exist_rate(start,x+1)
        us.save!
      end
    end
  end
end
```

> 备注：这里第一次学到了如何给类对象编写方法，self.xxx表明这是一个类方法而不是实例方法。

## 后记


等我以后NB了，这些就是我在NB道路上的足迹。哈哈！！
