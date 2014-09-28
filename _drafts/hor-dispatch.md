---
layout: post
title: Dispatch Tables
---
[Higher-order Ruby](http://graysoftinc.com/higher-order-ruby)
I think in Ruby we tend to do a lot of this kind of work with method_missing(). I told you, Functional OO Programming.

Here's my attempt at something close to a direct translation of the RPN calculator example:
click to copy

#!/usr/local/bin/ruby -w

$stack = Array.new

def rpn(expression, operations_table)
  tokens = expression.split(" ")
  tokens.each do |token|
    type = token =~ /\A\d+\Z/ ? :number : nil

    operations_table[type || token][token]
  end

  $stack.pop
end

if ARGV.size == 2 && ARGV.first == "-i" && ARGV.last =~ /\A[-+*\/0-9 ]+\Z/
  require "pp"

  def ast_to_infix(ast)
    if ast.is_a?(Array)
      op, left, right = ast
      "(#{ast_to_infix(left)} #{op} #{ast_to_infix(right)})"
    else
      ast.to_s
    end
  end

  ast_table = Hash.new do |table, token|
    lambda { |op| s = $stack.pop; $stack << [op, $stack.pop, s] }
  end.merge(:number => lambda { |num| $stack << num.to_i })

  puts "AST:"
  pp(ast = rpn(ARGV.last, ast_table))
  puts "Infix:"
  pp ast_to_infix(ast)
elsif ARGV.size == 1 && ARGV.first =~ /\A[-+*\/0-9 ]+\Z/
  calculation_table = Hash.new do |table, token|
    raise "Unknown token:  #{token}."
    end.merge(
      :number => lambda { |num| $stack << num.to_i },
      "+"     => lambda { $stack << $stack.pop + $stack.pop },
      "-"     => lambda { s = $stack.pop; $stack << $stack.pop - s },
      "*"     => lambda { $stack << $stack.pop * $stack.pop },
      "/"     => lambda { d = $stack.pop; $stack << $stack.pop / d }
    )

    puts rpn(ARGV.first, calculation_table)
else
  puts "Usage:  #{File.basename($PROGRAM_NAME)} [-i] RPN_EXPRESSION"
end

I originally thought I was being clever using the default block of a Hash, but the lambda() trick in the AST translator feels bumpy. I also don't like the global $stack. And types are under used. Let me try to fix those issues and convert the API to something a bit more in Ruby's style:
click to copy

#!/usr/local/bin/ruby -w

class RPN
  def initialize
    @operations_table = Hash.new do |table, token|
      if table.include?(:default)
        table[:default]
      else
        raise "Unknow token:  #{token}."
      end
    end

    @types = [[:number, /\A\d+\Z/]]
  end

  def type(name, pattern)
    @types << [name, pattern]
  end

  def method_missing(meth, *args, &block)
    @operations_table[meth.to_sym] = block
  end

  def parse(expression, stack = Array.new)
    expression.split(" ").each do |token|
      case (type = find_type(token))
      when :binary_op
        call_binary_op(token, stack, &@operations_table[:binary_op])
      else
        @operations_table[type || token][token, stack]
      end
    end
    stack.pop
  end

  private

  def find_type(token)
    (type = @types.find { |t| t.last === token }) ? type.first : nil
  end

  def call_binary_op(operator, stack, &operation)
    right = stack.pop
    operation[operator, stack.pop, right, stack]
  end
end

if ARGV.size == 2 && ARGV.first == "-i" && ARGV.last =~ /\A[-+*\/0-9 ]+\Z/
  require "pp"

  def ast_to_infix(ast)
    if ast.is_a?(Array)
      op, left, right = ast
      "(#{ast_to_infix(left)} #{op} #{ast_to_infix(right)})"
    else
      ast.to_s
    end
  end

  calc = RPN.new
  calc.type(:binary_op, /\A[-+*\/]\Z/)
  calc.number { |num, stack| stack << num.to_i }
  calc.binary_op { |op, left, right, stack| stack << [op, left, right] }

  puts "AST:"
  pp(ast = calc.parse(ARGV.last))
  puts "Infix:"
  pp ast_to_infix(ast)
elsif ARGV.size == 1 && ARGV.first =~ /\A[-+*\/0-9 ]+\Z/
  calc = RPN.new
  calc.type(:binary_op, /\A[-+*\/]\Z/)
  calc.number { |num, stack| stack << num.to_i }
  calc.binary_op { |op, left, right, stack| stack << left.send(op, right) }

  puts calc.parse(ARGV.first)
else
  puts "Usage:  #{File.basename($PROGRAM_NAME)} [-i] RPN_EXPRESSION"
end

I'm not sure if I got everything perfect, but hopefully there's a good Ruby idiom or two hiding in there. It certainly feels more Rubyish. Of course, it is almost 30 lines longer…
