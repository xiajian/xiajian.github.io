---
layout: post
title: Iterators
---
[Higher-order Ruby](http://graysoftinc.com/higher-order-ruby)
Due to a printing error, these two chapters actually came out longer than intended. Originally their contents were: "Use Ruby."

All jokes aside, there's really not a whole lot for me to talk about from these chapters, since iterators are so internal to Ruby. Readers from our camp should run into a lot less surprises here that the intended audience. Just translate MDJ's anonymous subroutines to blocks, replace his returns with yields, and you are 90% of the way there.

Here are translations for some of the examples in these chapters. I think these all come out cleaner and more natural in Ruby, but you be the judge:
Permutations
click to copy

#!/usr/local/bin/ruby -w

def permute(items)
  0.upto(1.0/0.0) do |count|
    pattern = count_to_pattern(count, items.size) or break
    puts "Pattern #{pattern.join(' ')}:" if $DEBUG
    yield(pattern_to_permutation(pattern, items.dup))
  end
end

def pattern_to_permutation(pattern, items)
  pattern.inject(Array.new) { |results, i| results + items.slice!(i, 1) }
end

def count_to_pattern(count, item_count)
  pattern = (1..item_count).inject(Array.new) do |pat, i|
    pat.unshift(count % i)
    count /= i
    pat
  end
  count.zero? ? pattern : nil
end

if ARGV.empty?
  abort "Usage:  #{File.basename($PROGRAM_NAME)} LIST_OF_ITEMS"
end

permute(ARGV) { |perm| puts(($DEBUG ? "  " : "") + perm.join(" ")) }

Treasure Allocation
click to copy

#!/usr/local/bin/ruby -w

def find_shares(target, treasures)
  shares = target.zero? ? [[target, Array.new, Array.new]] :
                          [[target, treasures, Array.new]]

  until shares.empty?
    goal, pool, share = shares.pop
    first             = pool.shift

    shares << [goal, pool.dup, share.dup] unless pool.empty?
    if goal == first
      yield(share + [first])
    elsif goal > first && !pool.empty?
      shares << [goal - first, pool.dup, share + [first]]
    end
  end
end

unless ARGV.size >= 2
  abort "Usage:  #{File.basename($PROGRAM_NAME)} TARGET TREASURES"
end

find_shares(ARGV.first.to_i, ARGV[1..-1].map { |n| n.to_i }) do |share|
  puts share.join(" ")
end

Integer Partitioning
click to copy

#!/usr/local/bin/ruby -w

def partition(num)
  partitions = [[num]]

  until partitions.empty?
    current = partitions.shift

    yield(current)

    largest = current.shift
    (([current.first.to_i, 1].max)..(largest / 2)).each do |n|
      partitions << Array[largest - n, n, *current.dup]
    end

    partitions.sort! { |a, b| b <=> a }
  end
end

unless ARGV.size == 1
  abort "Usage:  #{File.basename($PROGRAM_NAME)} INTEGER"
end

partition(ARGV.first.to_i) { |partition| puts partition.join(" ") }

Internal vs. External

All of the the iterators MJD uses are "external iterators." That's just a fancy way of saying that he returns these magic objects you can query for each item in a series. When you are done with an item, you can just ask for the next one, and it will let you know when it runs out of items to give you. (Java's iterators are also external, if you are familiar with that language.)

Ruby uses a different approach, called "internal iterators." Instead of asking for the magic object (pulling data), we pass in the operations to do on the items we are iterating over (pushing data) in the form of blocks.

Both models have their advantages.

First think about this: Ruby's iterators don't suffer from the semipredicate issues MJD keeps describing in these pages. You never have to worry about whether or not each() is trying to tell you it's out of items, because it handles all of that. That's an advantage of internal iterators.

However, sometimes we need to work through a couple of iterators in tandem. Internal iterators struggle with this, because we hand the processing code off for another object to run and manage. In these cases, external iterators fair better.

You should remember two things from this.

First, most of the time there is little difference and in the typical cases and when that's true internal iterators tend to come out cleaner, in my opinion. See the three examples above.

Second, some problems just need an external iterator. Because of that, you need to know how to get one in Ruby. There are a couple of ways, but tuck this one away in your mind because it's so easy to remember: all Enumerable objects have a to_a() method and an Array can be an external iterator (using indices).

MJD had a great example of a problem that doesn't bend well to internal iterators in this section, when he was playing with gene combinations. He solved it like I just hinted at, using arrays and tracking indices. Here's another option in Ruby using the standard Generator library, which is for switching internal iterators into external iterators:

[Note: The following code uses a standard library that has been removed from Ruby. It's no longer needed now that any iterator is trivially switched into an Enumerator, Ruby's current system for getting external iterators.]
click to copy

#!/usr/local/bin/ruby -w

require "generator"

def permute_genes(pattern)
  tokens = pattern.split(/[()]/)
  (1...tokens.size).step(2) do |i|
    tokens[i] = Generator.new(tokens[i].split(""))
  end

  loop do
    incrementing = false
    permutation = tokens.inject(String.new) do |result, token|
      if token.is_a?(String)
        result + token
      else
        if incrementing
          result + token.current
        else
          next_result = result + token.next
          if token.end?
            token.rewind
          else
            incrementing = true
          end
          next_result
        end
      end
    end
    yield(permutation)
    break unless incrementing
  end
end

unless ARGV.size == 1
  abort "Usage:  #{File.basename($PROGRAM_NAME)} GENE_PATTERN"
end

permute_genes(ARGV.first) { |perm| puts perm }

I think that solution comes out very nice. However, I must warn you that Generator is pretty slow due to some implementation details. If you run into performance issues while using it, just remember the backup plan (to_a()).
A Web Robot

I took MJD's "extended example" and Rubyified it, to the best of my abilities. It requires my RobotRules port as well as the Rubyful Soup library by Leonard Richardson.

[Note: Rubyful Soup is no longer maintained and probably doesn't work on modern versions of Ruby.]
click to copy

#!/usr/local/bin/ruby

require "open-uri"
require "uri"

require "robot_rules"

require "rubygems"
require "rubyful_soup"

class SimpleRobot
  def initialize(&link_filter)
    filter(&link_filter)

    @sites = Hash.new
    @rules = RobotRules.new("SimpleRobot/1.0")
  end

  def filter(&link_filter)
    @filter = link_filter
  end

  def traverse(top)
    filter = @filter || lambda { |link| link =~ /\A#{Regexp.escape(top)}/ }
    links  = [[top, "Top link."]]
    seen   = Hash.new(0)

    until links.empty?
      url, referrer = links.pop

      next unless robot_safe?(url)

      open(url) do |page|
        content = nil

        if page.content_type =~ /\Atext\/html\b/i
          tags = BeautifulSoup.new(content = page.read)
          links.push( *tags.find_all("a").map { |l| l.attrs["href"] }.
                                          compact.
                                          map { |l| l.sub(/#.*\Z/, "") }.
                                          map { |l| l.sub(/\A(?!\w+:)/, top) }.
                                          select { |l| (seen[l] += 1) == 1 }.
                                          select(&filter).
                                          map { |l| [l, url] } )
        end

        yield(url, page.meta, referrer, content)
      end rescue yield(url, Hash.new, referrer, nil)
    end
  end

  def robot_safe?(url)
    uri      = URI.parse(url)
    location = "#{uri.host}:#{uri.port}"

    return true unless %w{http https}.include?(uri.scheme)

    unless @sites.include?(location)
      @sites[location] = true

      robot_url  = "http://#{location}/robots.txt"
      begin
        robot_file = open(robot_url) { |page| page.read }
      rescue
        return true
      end
      @rules.parse(robot_url, robot_file)
    end

    @rules.allowed?(url)
  end
end

You can use that to quickly make crawlers:
click to copy

#!/usr/local/bin/ruby

require "simple_robot"

bot = SimpleRobot.new
bot.traverse(ARGV.shift) do |url, head, referrer, html|
  puts url
end

