---
layout: post
title: Caching and Memoization
---
[Higher-order Ruby](http://graysoftinc.com/higher-order-ruby)
I felt this chapter had a lot going for it, in places, but occasionally got lost in the details. All in all though, it's good stuff.
Caching

Obviously a powerful technique here and all of it translates to Ruby with little effort. Here's a direct translation of the RGB_to_CMYK() subroutine:
click to copy

#!/usr/local/bin/ruby -w

$cache = Hash.new

def rgb_to_cmyk(*rgb)
  return $cache[rgb] if $cache.include?(rgb)
  c, m, y     = rgb.map { |color| 255 - color }
  k           = [c, m, y].min
  $cache[rgb] = [c, m, y].map { |color| color - k } + [k]
end

unless ARGV.size == 3 && ARGV.all? { |n| n =~ /\A\d+\Z/ }
  abort "Usage:  #{File.basename($PROGRAM_NAME)} RED GREEN BLUE"
end

puts rgb_to_cmyk(*ARGV.map { |num| num.to_i }).join(", ")

There are several interesting syntax differences in there. For example, I had to use a global variable for the $cache because Ruby methods don't have access to local variables. Another option would be to use a lambda(). These are probably good indicators that we would wrap this in an object and use instance variables normally.

The other big difference is that a Ruby Array can be used as the key of a Ruby Hash. This fact alone means you can ignore most of the finding suitable keys discussion in this chapter.

Finally, I think Ruby's iterators just make the solution cleaner.

It's interesting to note that we could do this completely with a Hash in Ruby:
click to copy

#!/usr/local/bin/ruby -w

cmyk = Hash.new do |colors, rgb|
  c, m, y     = rgb.map { |color| 255 - color }
  k           = [c, m, y].min
  colors[rgb] = [c, m, y].map { |color| color - k } + [k]
end

unless ARGV.size == 3 && ARGV.all? { |n| n =~ /\A\d+\Z/ }
  abort "Usage:  #{File.basename($PROGRAM_NAME)} RED GREEN BLUE"
end

puts cmyk[ARGV.map { |num| num.to_i }].join(", ")

I think using the default block of a Hash for caching like this has a lot of potential. I even suspect the performance is good, since Ruby's native Hash handles the dispatching. If the interface bothers you, passing an Array instead of RGB values, you can always wrap it in a method.
Scope, Duration, and Lexical Closure

This is simply a superb treatment of all of these topics. If you still struggle with understanding Ruby's closures or binding() or would just like a deeper understanding of variable scoping, this is a great place to pick up these details.

Just stay aware of Ruby's differences. lambda() is Ruby's anonymous subroutine, though not perfectly equivalent. Ruby's blocks are also closures and that's important to remember.
Memoization

Most of the details in here are helpful and interesting.

Along the way, it gets bogged down in minor Perlisms to eek out tiny improvements. I get sleepy when I start reading about that in any language.

There are still a lot of good tricks in here though and applicable to Ruby too. (The standard Ruby memoization process in Ruby is alias, then redefine, though you can get a reference with method() if you prefer.) Ruby does have a memoization library as well.

Here's my own attempt to build a memoization library, which was trickier to get right than I expected:
click to copy

#!/usr/local/bin/ruby -w

#
# memoizable.rb
#
#  Created by James Edward Gray II on 2006-01-21.
#  Copyright 2006 Gray Productions. All rights reserved.
#

# 
# Have your class or module <tt>extend Memoizable</tt> to gain access to the 
# #memoize method.
# 
module Memoizable
  # 
  # This method is used to replace a computationally expensive method with an
  # equivalent method that will answer repeat calls for indentical arguments 
  # from a _cache_.  To use, make sure the current class extends Memoizable, 
  # then call by passing the _name_ of the method you wish to cache results for.
  # 
  # The _cache_ object can be any object supporting both #[] and #[]=.  The keys
  # used for the _cache_ are an Array of the arguments the method was called 
  # with and the values are just the returned results of the original method 
  # call.  The default _cache_ is a simple Hash, providing in-memory storage.
  # 
  def memoize(name, cache = Hash.new)
    original = "__unmemoized_#{name}__"

    # 
    # <tt>self.class</tt> is used for the top level, to modify Object, otherwise
    # we just modify the Class or Module directly
    # 
    ([Class, Module].include?(self.class) ? self : self.class).class_eval do
      alias_method original, name
      private      original
      define_method(name) { |*args| cache[args] ||= send(original, *args) }
    end
  end
end

Standard intended usage looks like this:
click to copy

class Fibonacci
  extend Memoizable

  def fib(num)
    return num if num < 2
    fib(num - 1) + fib(num - 2)
  end
  memoize :fib
end

Or, for a class/module method:
click to copy

class Fibonacci
  class << self
    extend Memoizable

    def fib(num)
      return num if num < 2
      fib(num - 1) + fib(num - 2)
    end
    memoize :fib
  end
end

It even works for top-level methods:
click to copy

extend Memoizable

def fib(num)
  return num if num < 2
  fib(num - 1) + fib(num - 2)
end
memoize :fib

Finally, my library allows you to supply a custom cache. Here's an example using weak references:

[Note: The following code uses Thread.critical = true which is no longer supported in Ruby.]
click to copy

#!/usr/local/bin/ruby -w

#
# weak_references.rb
#
#  Created by James Edward Gray II on 2006-01-23.
#  Copyright 2006 Gray Productions. All rights reserved.
#

require "memoizable"

# 
# This cache uses weak references, which can be garbage collected.  When the 
# cache is checked, the value will be returned if it is still around, otherwise
# +nil+ is returned.
# 
# (Code by Mauricio Fernandez.)
# 
class WeakCache
  def initialize
    set_internal_hash
  end

  def method_missing(meth, *args, &block)
    __get_hash__.send(meth, *args, &block)
  end

  private

  def __get_hash__
    old_critical    = Thread.critical
    Thread.critical = true

    @valid or set_internal_hash
    return ObjectSpace._id2ref(@hash_id)
  ensure
    Thread.critical = old_critical
  end

  def set_internal_hash
    hash     = Hash.new
    @hash_id = hash.object_id
    @valid   = true

    ObjectSpace.define_finalizer(hash, lambda { @valid = false })
    hash = nil
  end
end
$cache = WeakCache.new  # makes the example below easier to show

class Fibonacci
  extend Memoizable

  def fib(num)
    return num if num < 2
    fib(num - 1) + fib(num - 2)
  end
  memoize :fib, $cache
end

puts "This method is memoized using a weak reference cache..."
start = Time.now
puts "fib(100):  #{Fibonacci.new.fib(100)}"
puts "Run time:  #{Time.now - start} seconds"

puts
puts "We will now try to get garbage collection to reclaim the cache..."
puts "Cache size:  #{$cache.size}"
puts "Running garbage collection..."
ObjectSpace.garbage_collect
puts "Cache size:  #{$cache.size}"

puts
puts "Running the test again may not be instant, but still fast..."
start = Time.now
puts "fib(100):  #{Fibonacci.new.fib(100)}"
puts "Run time:  #{Time.now - start} seconds"

The Missing Trade Off

I was kind-of surprised that this chapter talked a lot about speed yet barely mentioned memory consumption. Memoization is a trade-off of space (RAM or disk) for speed. Sometimes the space aspect makes it prohibitively expensive, though there is virtually no mention of that here. I wonder if that has anything to do with speed being much easier to measure than memory consumption, in languages like Perl and Ruby…
