---
layout: post
title: Infinite streams
---
[Higher-order Ruby](http://graysoftinc.com/higher-order-ruby)
I've tried to summarize this chapter a couple of times now, but I keep getting tripped up over syntax. So, let's talk about that…
Functional Perl

Obviously, the examples in the book can be more or less directly translated. Here's a sample from the first couple of pages:
click to copy

#!/usr/local/bin/ruby -w

### Stream Methods ###

def node(head, tail)
  [head, tail]
end

def head(stream)
  stream.first
end

def tail(stream)
  tail = stream.last
  if tail.is_a?(Proc)
    tail.call
  else
    tail
  end
end

def drop(stream)
  head                 = head(stream)
  stream[0], stream[1] = Array(tail(stream))
  head
end

def show(stream, limit = nil)
  while head(stream) && (limit.nil? or (limit -= 1) > -1)
    print drop(stream), $, || " "
  end
  print $/
end

### Examples ###

def upto(from, to)
  return if from > to
  node(from, lambda { upto(from + 1, to) })
end
show(upto(3, 6))  # => 3 4 5 6

def upfrom(start)
  node(start, lambda { upfrom(start + 1) })
end
show(upfrom(7), 10)  # => 7 8 9 10 11 12 13 14 15 16

Already though this is feeling very un-Rubyish, and it will only get worse if we keep going down this path.

I suspect the main reason MJD took such a functional approach with his book is that Perl's objects can be heavy and awkward. That doesn't make for great book examples. Ruby isn't like that though and the previous code is just crying out to be objectified.
Ruby's Object Orientation

We will start at the beginning. Clearly we need a constructor. Now the whole point of all this is building lazy streams, so we're always going to be using some head value and a promise for the tail. A promise is a chunk of code, and in Ruby we call that a block:
click to copy

module LazyStream
  class Node
    def initialize(head, &promise)
      @head, @tail = head, promise
    end
  end
end

That's already an improvement, since it will allow us to drop the calls to Kernel#lambda. The name is a bit lengthy, but we can easily fix that after we have the rest of this down. For now, we're just tucking our work into a safe namespace.

The next step is to restore access to the head and tail. These are pretty simple readers in this form and while we are building them, let's add some Rubyish aliases:
click to copy

module LazyStream
  class Node
    attr_reader  :head
    alias_method :current, :head

    def tail
      if @tail.is_a?(Proc)
        @tail.call
      else
        @tail
      end
    end
    alias_method :next, :tail
  end
end

Now, adding back support for drop is where things start to get a little tricky. If a call to LazyStream::Node#tail returns a LazyStream::Node, we want that to replace the current LazyStream::Node. If we get anything else, we'll just assign it normally. Again, here's the code, with aliases:
click to copy

module LazyStream
  class Node
    def drop
      result, next_stream = head, tail
      @head, @tail        = if next_stream.is_a?(self.class)
        next_stream.instance_eval { [@head, @tail] }
      else
        Array(next_stream)
      end
      result
    end
    alias_method :tail!, :drop
    alias_method :next!, :drop
  end
end

When using our objectified LazyStream, users won't see a nil return for streams that terminate. Because of that, we should add methods for checking if we are at the end of a stream:
click to copy

module LazyStream
  class Node
    def end?
      @tail.nil?
    end

    def next?
      !end?
    end
  end
end

Let's add a quick LazyStream::Node#show and see how we have done. We will again toss in an alias, an I'm sorry, but the ugly Perl variables have to go:
click to copy

module LazyStream
  class Node
    def show(*limit_and_options)
      options = {:sep => " ", :end => "\n"}.merge!(
        limit_and_options.last.is_a?(Hash) ? limit_and_options.pop : Hash.new
      )
      limit = limit_and_options.shift

      while head && (limit.nil? or (limit -= 1) > -1)
        print drop, options[:sep]
      end
      print options[:end]
    end
    alias_method :display, :show
  end
end

On with the examples:
click to copy

#!/usr/local/bin/ruby -w

require "lazy_stream"

def upto(from, to)
  return if from > to
  LazyStream::Node.new(from) { upto(from + 1, to) }
end
upto(3, 6).show  # => 3 4 5 6

def upfrom(start)
  LazyStream::Node.new(start) { upfrom(start + 1) }
end
upfrom(7).show(10)  # => 7 8 9 10 11 12 13 14 15 16

We're making progress. This is starting to feel more like Ruby. Time for me to make good on my promise for a shorter constructor though. We can just add this to the end of lazy_stream.rb:
click to copy

module Kernel
  def lazy_stream(*args, &block)
    LazyStream::Node.new(*args, &block)
  end
end

That allows us to trim our functional usage to:
click to copy

#!/usr/local/bin/ruby -w

require "lazy_stream"

def upto(from, to)
  return if from > to
  lazy_stream(from) { upto(from + 1, to) }
end
upto(3, 6).show  # => 3 4 5 6

def upfrom(start)
  lazy_stream(start) { upfrom(start + 1) }
end
upfrom(7).show(10)  # => 7 8 9 10 11 12 13 14 15 16

Even better though, this is Ruby and we can make full objects:
click to copy

#!/usr/local/bin/ruby -w

require "lazy_stream"

class Upto < LazyStream::Node
  def initialize(from, to)
    if from > to
      super(nil, &nil)
    else
      super(from) { self.class.new(from + 1, to) }
    end
  end
end
Upto.new(3, 6).show  # => 3 4 5 6

class Upfrom < LazyStream::Node
  def initialize(from)
    super(from) { self.class.new(from + 1) }
  end
end
Upfrom.new(7).show(10)  # => 7 8 9 10 11 12 13 14 15 16

Now we can have our interface any way we like it. Some things still need work though…
Inside-out Iteration

So far, I've just copied MJD's external iterator interface. Those are certainly helpful with lazy streams, because you may want to pull values for a while, stop to do something else, and come back to the stream later.

However, Ruby just doesn't feel right without an #each method and Enumerable mixed-in. In this particular case, we really want two forms of iteration, one each for LazyStream::Node#tail and LazyStream::Node#drop so we can advance the stream, or just peek ahead.

It's easier to build the destructive version first. In fact, we already have the implementation coded up inside LazyStream::Node#show. Let's even keep the limit as a handy way to keep from going too deep:
click to copy

module LazyStream
  class Node
    def each!(limit = nil)
      loop do
        break unless limit.nil? || (limit -= 1) > -1

        yield(drop)

        break if end?
      end

      self
    end
  end
end

Then we can use that to build the standard iterator:
click to copy

module LazyStream
  class Node
    def each(limit = nil, &block)
      clone.each!(limit, &block)

      self
    end
    alias_method :peek, :each
    include Enumerable
  end
end

That let's us use standard Ruby iteration, for the most part. We can even set a limit to keep from going too far. We can also use methods like Enumerable#find on an infinite stream, since it will stop as soon as it finds a match.

Where this system has trouble is if we want to use something like Enumerable#map on an infinite stream. The problem here is that we have no good way to pass the limit down. It's also tricky to use LazyStream::Node#each! with the Enumerable methods. Let's fix both issues:
click to copy

require "enumerator"

module LazyStream
  class Node
    def limit(max_depth = nil)
      enum_for(:each, max_depth)
    end

    def limit!(max_depth = nil)
      enum_for(:each!, max_depth)
    end
  end
end

There's a little black magic there we need to see in action, but before we go back to examples we can simplify LazyStream::Node#show to use the new iterators:
click to copy

module LazyStream
  class Node
    def show(*limit_and_options)
      options = {:sep => " ", :end => "\n"}.merge!(
        limit_and_options.last.is_a?(Hash) ? limit_and_options.pop : Hash.new
      )
      limit = limit_and_options.shift

      each(limit) { |cur| print cur, options[:sep] }
      print options[:end]
    end
    alias_method :display, :show
  end
end

Okay, let's see what we have created. Here's an infinite stream iterator, using Enumerable#map:
click to copy

#!/usr/local/bin/ruby -w

require "lazy_stream"

class Step < LazyStream::Node
  def initialize(step, start = 1)
    super(start) { self.class.new(step, start + 1) }

    @step = step
  end

  def next_group(count = 10)
    limit!(count).map { |i| i * @step }
  end
end

evens = Step.new(2)

puts "The first ten even numbers are:"
puts evens.next_group.join(" ")  # => 2 4 6 8 10 12 14 16 18 20

# later...

puts
puts "The next ten even numbers are:"
puts evens.next_group.join(" ")  # => 22 24 26 28 30 32 34 36 38 40

puts
puts "The current index for future calculations is:"
puts evens.current # => 21

That feels a lot more like Ruby to me. Now we can get back to MJD's examples.
Adding #filter and #transform

MJD adds both a #filter and #transform method next. Technically, my last example is a transformation of the stream and we could do filtering the same way. Still it's nice to have these built-in and we should add them.

The #filter is easy enough, we just have to keep dropping items until we find a match and make sure setting a filter is viral to future nodes:
click to copy

module LazyStream
  class Node
    def tail
      result = if @tail.is_a?(Proc)
        @tail.call
      else
        @tail
      end

      result.filter(@filter) unless @filter.nil? || !result.is_a?(self.class)

      result
    end

    def filter(pattern = nil, &block)
      @filter = pattern || block

      drop until matches_filter?(@head)

      self
    end

    private

    def matches_filter?(current)
      case @filter
      when nil
        true
      when Proc
        @filter[current]
      else
        @filter === current
      end
    end
  end
end

We can add #transform by defining an actual getter for @head, instead of the attr_reader shortcut I've been using and, again, making the setting viral:
click to copy

module LazyStream
  class Node
    def head
      @transformer.nil? ? @head : @transformer[@head]
    end

    def tail
      result = if @tail.is_a?(Proc)
        @tail.call
      else
        @tail
      end

      result.filter(@filter)          unless @filter.nil? ||
                                      !result.is_a?(self.class)
      result.transform(&@transformer) unless @transformer.nil? ||
                                      !result.is_a?(self.class)

      result
    end

    def transform(&transformer)
      @transformer = transformer

      self
    end
  end
end

Here are trivial examples with both:
click to copy

#!/usr/local/bin/ruby -w

require "lazy_stream"

def letters(letter)
  lazy_stream(letter) { letters(letter.succ) }
end

letters("a").filter(/[aeiou]/).show(10)           # => a e i o u aa ab ac ad ae
letters("a").filter { |l| l.size == 2 }.show(3)   # => aa ab ac 

letters("a").transform { |l| l + "..." }.show(3)  # => a... b... c...

Recursive Streams

I think we can fix the recursive issues MJD discusses with ease in our Ruby version, just by passing the stream head to the promise block:
click to copy

module LazyStream
  class Node
    def tail
      result = if @tail.is_a?(Proc)
        @tail.call(head)
      else
        @tail
      end

      unless result == @tail
        result.filter(@filter)          unless @filter.nil? ||
                                        !result.is_a?(self.class)
        result.transform(&@transformer) unless @transformer.nil? ||
                                        !result.is_a?(self.class)
      end

      @tail = result
    end
  end
end

With that, MJD's example is trivial:
click to copy

#!/usr/local/bin/ruby -w

require "lazy_stream"

class Powers < LazyStream::Node
  def initialize(of, start = 1)
    super(start) { |last| self.class.new(of, last * of) }
  end
end

powers_of_two = Powers.new(2)
powers_of_two.show(10)  # => 1 2 4 8 16 32 64 128 256 512

In all honesty though, you seldom need that with the blocks being closures. You can just reference the local variables instead.

You also don't need merging to solve the Hamming Sequence. Here's a simple example:
click to copy

#!/usr/local/bin/ruby -w

require "lazy_stream"

class Hamming < LazyStream::Node
  def initialize(seq = [1])
    cur = seq.shift
    super(cur) do 
      self.class.new((seq << cur * 2 << cur * 3 << cur * 5).uniq.sort)
    end
  end
end
Hamming.new.show(20)  # => 1 2 3 4 5 6 8 9 10 12 15 16 18 20 24

Regexp String Generation

We don't need too many modifications to be able to create this example. First, let's build a LazyStream::union:
click to copy

module LazyStream
  def self.union(*streams)
    current = streams.shift or return
    Node.new(current.head) { union(*(streams << current.tail)) }
  end
end

We can even add a little syntax sugar for calling that:
click to copy

module LazyStream
  class Node
    def +(other_stream)
      LazyStream.union(self, other_stream)
    end
  end
end

Finally, because I made LazyStream::Node#transform modify the stream, we will need a LazyStream::Node#dup to build MJD's #concat method:
click to copy

module LazyStream
  class Node
    def dup
      if tail.nil? || tail.is_a?(Proc)
        self.class.new(head, &tail)
      else
        self.class.new(head) { tail }
      end
    end
  end
end

From there we can build a RegexpMatchesGenerator:
click to copy

#!/usr/local/bin/ruby -w

require "lazy_stream"

module RegexpMatchesGenerator
  extend self

  def literal(string)
    lazy_stream(string)
  end

  def concat(stream1, stream2)
    lazy_stream(stream1.head + stream2.head) do
      combinations = Array.new
      unless stream1.end?
        combinations << stream1.tail.dup.transform { |str| str + stream2.head }
      end
      unless stream2.end?
        combinations << stream2.tail.dup.transform { |str| stream1.head + str }
      end
      unless stream1.end? || stream2.end?
        combinations << concat(stream1.tail, stream2.tail)
      end
      LazyStream.union(*combinations)
    end
  end

  def star(stream, head = "")
    lazy_stream(head) { star(stream, head + stream.head) }
  end

  def char_class(string)
    LazyStream.union(*string.split("").map { |str| literal(str) })
  end

  def plus(stream)
    star(stream, stream.head)
  end
end

if __FILE__ == $0
  include RegexpMatchesGenerator

  # /^(a|b)(c|d)$/
  concat(literal("a") + literal("b"), literal("c") + literal("d")).show

  # /^(HONK)*$/
  puts star(literal("HONK")).limit(6).map { |str| str.inspect }.join(" ")

  # /^ab*$/
  puts(concat(literal("a"), star(literal("b"))).limit(10).to_a)
end

The Rest

That should be enough example translation to address most of the highlights from this chapter. All those math problems at the end make me drowsy, so I'll leave those as an exercise for the reader…
This post is part of a series. 

