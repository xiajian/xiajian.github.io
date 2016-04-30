---
layout: post
title: 学习如何编写 Homebrew formulae 脚本
description: '云计算， 人民公园，青云的分享'
category: note
---

## 前言

看到 一个 Lua 的包管理器 <https://luarocks.org/>,  使用 `brew search` 发现没有相关的包，想到可以将其集成到到 brew 中。

## 正文

创建 luarocks 的 formulae： 


```
brew create http://luarocks.org/releases/luarocks-2.3.0.tar.gz
==> Downloading http://luarocks.org/releases/luarocks-2.3.0.tar.gz
==> Downloading from http://keplerproject.github.io/luarocks/releases/luarocks-2.3.0.tar.gz
######################################################################## 100.0%
Please `brew audit --strict luarocks` before submitting, thanks.
```

生成的代码如下：

```ruby
# /usr/local/Library/Taps/homebrew/homebrew-core/Formula/luarocks.rb
# Documentation: https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Formula-Cookbook.md
#                http://www.rubydoc.info/github/Homebrew/brew/master/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Luarocks < Formula
  desc "LuaRocks is the package manager for Lua modules."
  homepage "https://luarocks.org/"
  url "http://luarocks.org/releases/luarocks-2.3.0.tar.gz"
  version "2.3.0"
  sha256 "68e38feeb66052e29ad1935a71b875194ed8b9c67c2223af5f4d4e3e2464ed97"

  def install
    # $ wget http://luarocks.org/releases/luarocks-2.3.0.tar.gz
    # $ tar zxpf luarocks-2.3.0.tar.gz
    # $ cd luarocks-2.3.0
    # $ ./configure; sudo make bootstrap
    system "./configure --with-lua-bin /usr/local/bin/lua"
    
    # system "cmake", ".", *std_cmake_arg
    system "make", "bootstrap" # if this fails, try separate make/make install steps
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test luarocks`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
```

编辑完上面的代码后， 运行 `brew install luarocks`，结果，各种报错：


正想着怎么编写的，切换到 `/usr/local/Library/Taps/homebrew/homebrew-core/Formula/` 目录， 想参考参考其他人怎么写的，结果发现了 `lua.rb` 中代码有如下的一段代码： 

```
resource "luarocks" do
  url "https://keplerproject.github.io/luarocks/releases/luarocks-2.3.0.tar.gz"
  sha256 "68e38feeb66052e29ad1935a71b875194ed8b9c67c2223af5f4d4e3e2464ed97"
end

...

# This resource must be handled after the main install, since there's a lua dep.
# Keeping it in install rather than postinstall means we can bottle.
if build.with? "luarocks"
  resource("luarocks").stage do
    ENV.prepend_path "PATH", bin

    system "./configure", "--prefix=#{libexec}", "--rocks-tree=#{HOMEBREW_PREFIX}",
                          "--sysconfdir=#{etc}/luarocks52", "--with-lua=#{prefix}",
                          "--lua-version=5.2", "--versioned-rocks-dir"
    system "make", "build"
    system "make", "install"

    (share+"lua/5.2/luarocks").install_symlink Dir["#{libexec}/share/lua/5.2/luarocks/*"]
    bin.install_symlink libexec/"bin/luarocks-5.2"
    bin.install_symlink libexec/"bin/luarocks-admin-5.2"
    bin.install_symlink libexec/"bin/luarocks"
    bin.install_symlink libexec/"bin/luarocks-admin"

    # This block ensures luarock exec scripts don't break across updates.
    inreplace libexec/"share/lua/5.2/luarocks/site_config.lua" do |s|
      s.gsub! libexec.to_s, opt_libexec
      s.gsub! include.to_s, "#{HOMEBREW_PREFIX}/include"
      s.gsub! lib.to_s, "#{HOMEBREW_PREFIX}/lib"
      s.gsub! bin.to_s, "#{HOMEBREW_PREFIX}/bin"
    end
  end
end  
```

在命令行下 tab 了一下，居然已经有了，看来是我想多了。

```
➜  Formula git:(master) ✗ luarocks
luarocks            luarocks-5.2        luarocks-admin      luarocks-admin-5.2
```

## 后记

昨夜兴致匆匆的想到，自己要贡献 homebrew 了，想想都激动啊。白天看着 redis， 晚上，开干时发现，别人已经做过了。 哎，又失去了一个机会。

