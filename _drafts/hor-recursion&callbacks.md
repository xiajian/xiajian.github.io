---
layout: post
title: Recursion and Callbacks
---

[Higher-order Ruby](http://graysoftinc.com/higher-order-ruby)
I'm currently reading through Higher-Order Perl, by Mark Jason Dominus. (Yes, I read books about things other than Ruby.)

So far, I'm enjoying the title quite a bit. It certainly has me thinking and the Perl in it is very clean and easy to understand. That helps me translate the concepts to my language of interest.

I'll post some of my Ruby translations of the books example code here as I go along. Others familiar with the book might enjoy looking over them. Be warned, my comments might not make much sense to those who haven't read the book.
Recursion

The book starts with some very simple recursion examples trivially translated. Here's one for manually translating Integers to binary Strings (a long way to say str.to_i.to_s(2) in Ruby):
click to copy

#!/usr/local/bin/ruby -w

def binary(number)
  return number.to_s if [0, 1].include?(number)

  k, b = number.divmod(2)
  binary(k) + b.to_s
end

unless !ARGV.empty? && ARGV.all? { |n| n =~ /\A\d+\Z/ }
  abort "Usage:  #{File.basename($PROGRAM_NAME)} DECIMAL_NUMBERS"
end

puts ARGV.map { |num| binary(num.to_i) }.join(" ")

Here's another for calculating factorials:
click to copy

#!/usr/local/bin/ruby -w

def factorial(number)
  return 1 if number == 0

  factorial(number - 1) * number
end

unless !ARGV.empty? && ARGV.all? { |n| n =~ /\A\d+\Z/ }
  abort "Usage:  #{File.basename($PROGRAM_NAME)} DECIMAL_NUMBERS"
end

puts ARGV.map { |num| factorial(num.to_i) }.join(" ")

MJD does talk about how recursion can always be unrolled into an iterative solution. That leads to what is probably a more natural Ruby solution for examples like these. Here's how I would probably code factorial():
click to copy

def factorial(number)
  (1..number).inject { |prod, n| prod * n }
end

Of course, that's just not what this chapter is about.
Callbacks

This section starts off by showing just how cool Ruby's blocks can be:
click to copy

#!/usr/local/bin/ruby -w

def hanoi(disk, start, finish, extra, &mover)
  if disk == 1
    mover[disk, start, finish]
  else
    hanoi(disk - 1, start, extra, finish, &mover)
    mover[disk, start, finish]
    hanoi(disk - 1, extra, finish, start, &mover)
  end
end

disks = ARGV.empty? ? 64 : ARGV.first.to_i

positions = [nil] + ["A"] * disks
hanoi(disks, "A", "C", "B") do |disk, start, finish|
  if disk < 1 || disk > positions.size - 1
    raise "Bad disk number:  #{disk}.  Disks should be between 1 and #{disks}."
  end

  unless positions[disk] == start
    raise "Tried to move ##{disk} from #{start}, " +
          "but it is on peg #{positions[disk]}."
  end

  (1...disk).each do |smaller_disk|
    if positions[smaller_disk] == start
      raise "Cannot move #{disk} from #{start}, " +
            "because #{smaller_disk} is on top of it."
    elsif positions[smaller_disk] == finish
      raise "Cannot move #{disk} to #{finish}, " +
            "because #{smaller_disk} is already there."
    end
  end

  puts "Move ##{disk} from #{start} to #{finish}."
  positions[disk] = finish
end

Interestingly though, MJD quickly gets into passing around multiple anonymous functions, and Ruby has to do that just like Perl:
click to copy

#!/usr/local/bin/ruby -w

def dir_walk(top, file_proc, dir_proc)
  total = File.size(top)

  if File.directory?(top)
    results = Array.new
    Dir.foreach(top) do |file_name|
      next if %w{. ..}.include?(file_name)
      results += dir_walk(File.join(top, file_name), file_proc, dir_proc)
    end
    dir_proc.nil? ? Array.new : dir_proc[top, results]
  else
    file_proc.nil? ? Array.new : file_proc[top]
  end
end

if __FILE__ == $0
  require "pp"

  unless ARGV.size == 1 && File.exist? ARGV.first
    abort "Usage:  #{File.basename($PROGRAM_NAME)} FILE_OR_DIRECTORY"
  end

  file = lambda { |f|        [File.basename(f), File.size(f)] }
  dir  = lambda { |d, files| [File.basename(d), Hash[*files]] }

  pp dir_walk(ARGV.first, file, dir)
end

The above makes me want for a multi-block syntax.

It's probably worth noting here that the above is basically an attempt at direct translation. I am aware of the standard Find library and I do think we should be using that, for this kind of traversal.
Variable Scope

Twice in this chapter, MJD has to pause the discussion to school the reader on the dangers of using improperly scoped variables, which can easily wreck recursion. What I found interesting in reading these was that coding the correct Perl was always adding a step, but it Ruby you have to add a step to get it wrong. What Rubyists naturally want to type turns out to be the correct thing to do, at least in these cases. I think this is a good sign that Ruby got variable scope right.
Functional vs. OO Programming

We always talk about how Ruby is very Object Oriented, but after reading this side discussion about the two approaches, I wonder how true that really is. The way MJD described OO, is certainly not how a lot of idiomatic Ruby comes out. And I found myself seeing a few of the described Functional Programming elements in my favorite language. Perhaps Ruby is a hybrid Functional OO Programming Language? Food for thought…

