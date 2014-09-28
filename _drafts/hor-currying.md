---
layout: post
title: Currying
---
[Higher-order Ruby](http://graysoftinc.com/higher-order-ruby)

All the examples in this chapter are trivially translated (switch sub { ... } to lambda { ... }). Ironically, I have never seen a chunk of idiomatic Ruby do anything like this. Rubyists clearly favor blocks for this sort of work. Have a look at the stream addition and multiplication examples of this chapter, for example. You can also see this when MJD trying to create a suitable inject() for Perl (he calls it reduce/fold).

Another interesting point about this chapter is how much of it is spent warring with Perl's syntax. MJD really struggles to introduce a block-like syntax for curried methods and is outright defeated in a couple of attempts. I really like how easily Ruby yields to our attempts to reprogram her, in sharp contrast to her sister language.

Continuing that line of thought, here's my best effort at the Poor Man's Currying library:
click to copy

#!/usr/bin/env ruby -w

class Proc
  def curry(&args_munger)
    lambda { |*args| call(*args_munger[args]) }
  end
end

class Object
  def curry(new_name, old_name, &args_munger)
    ([Class, Module].include?(self.class) ? self : self.class).class_eval do
      define_method(new_name) { |*args| send(old_name, *args_munger[args]) }
    end
  end
end

Unlike the Perl, this feels like very natural Ruby to me. You could argue that I struggle with Ruby's syntax because it's not easy to curry a block-taking method, but that seems like a minor issue. (This is fixed in Ruby 1.9, which adds Proc#curry.)

Here are examples of me playing with my toy:
click to copy

#!/usr/bin/env ruby -w

require "curry"

multiply = lambda { |l, r| l * r }
double   = multiply.curry { |args| args + [2] }
triple   = multiply.curry { |args| args << 3 }

multiply[5, 2]    # => 10
double[5]         # => 10
triple[5]         # => 15
triple["Howdy "]  # => "Howdy Howdy Howdy "

class Value
  def initialize(value)
    @value = value
  end

  def *(other)
    @value * other
  end
  curry(:double, :*) { [2] }
  curry(:triple, :*) { |args| args.unshift(3) }
end

five, howdy = Value.new(5), Value.new("Howdy ")
five * 2      # => 10
five.double   # => 10
five.triple   # => 15
howdy.triple  # => "Howdy Howdy Howdy "

I am purposefully trying to show the library's flexibility in these calls. The version in the book only supports currying a single argument at the front of the list. In 15 lines the Ruby version can completely rewrite arguments as it sees fit and it includes OO support.

You be the final judge, but I stand by my claim that Higher-Order Perl is the quest to bring many Rubyisms to Perl.

If you want to go deeper down the rabbit hole of currying in Ruby, I recommend you check out the Ruby library Murray. If you want to see a more Rubyish example of the FlatDB MJD builds in these pages, also see my article on code blocks.
