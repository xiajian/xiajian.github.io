---
layout: post
title:  开发环境下工具收集
description: "收集一些供开发环境下使用的工具, 以及基本环境的搭建"
category: note
---

## 前言

工作之后，对环境有所挑剔，以及不间断的搜集一些常用工具软件。

第一原则： 懒且避免重复，DRY。

## 基本系统

ubuntu 14.04 64位系统。

基础软件: 

1. 软件源安装: `apt-get install  build-essential mysql-client vim curl redis zsh tmux nginx libmysql-ruby libmysqlclient-dev  -y`

2. 常用软件: Firefox ，Chrome ，VirtualBox ，KSysGuard，GIMP，WPS for Linux，Fcitx输入法，金山快盘

## 开发环境

### 版本控制工具 - git

使用git，以及使用git相关的版本托管工具 - gitlab, gitcafe, coding.net 

1. 生成ssh key 

```
git config --global user.name "xiajian"
git config --global user.email "jhqy2011@gmail.com"
ssh-keygen -t rsa -C "jhqy2011@gmail.com"           # 如果不设-C选项，默认使用主机名
```

2. 添加复制ssh public的文件到用户的profile中，注意： **不要做任何修改**

根据邮箱生成key可以跨机器使用，但是，使用默认的方式方式生成的key是机器相关的，不能跨机器使用。

> 备注: 公钥私钥可以映射为现实的钥匙，只不过是二进制数字串。

## RVM

多个Ruby和Rails版本的问题，使用RVM。RVM的安装，参考 <http://rvm.io/> 。

更改RVM的源: `sed -i 's!cache.ruby-lang.org/pub/ruby!ruby.taobao.org/mirrors/ruby!' ~/.rvm/config/db` 

> 备注，这里sed用`!`分隔，可以避免转义/。否则就是这样的: sed -i 's/cache.ruby-lang.org\/pub\/ruby/ruby.taobao.org\/mirrors\/ruby!' ~/.rvm/config/db` 

配置gem安装的源，也可直接编辑`.gemrc`文件: 

```
$ gem sources --remove https://rubygems.org/
$ gem sources -a http://ruby.taobao.org/
```

rvm的简单使用: 

```
rvm install 1.9.3   # 安装1.9.3的ruby 
rvm current         # 输出当前使用的ruby的版本， 输出结果:ruby-1.9.3-p547 
rvm use 1.9.3       # 使用1.9.3版本的Ruby。
rvm gemset create x # 创建该项目的gemset
rvm gemset empty    # 清空当前的gemset
rvm use 1.9.3@x     # 使用当前的gemset，可通过`--default`选项将该项目设置为默认，每次系统启动时都会使用该环境 
rvm remove 1.9.3    # 移除1.9.3所有相关的gem包
```

开发相关的库的安装: `sudo apt-get install redis-tools redis-server ImageMagick `

> 备注: 仔细想想，其实rvm也是相当复杂的一个工具。

## VIM

神一般编辑器，Linux下对中文支持最好的编译器(更爱)，配置分两处，其一 `.vimrc`, 其二 `.vim/`: 

`.vimrc`文件内容: 

```
"local user setting "
syntax enable                " 启动语法高亮
syntax on                    " 开启文件类型侦测
" common configure 
set autoindent               " 自动缩进
set history=200              " 设置vim记录的历史命令数
set bs=2                     " 在insert模式下用退格键删除
set wildmode=longest,list    " 设置ex命令的自动补全方式
set ignorecase smartcase     " 匹配忽略大小写
set showmatch                " 代码匹配
set smartindent              " 智能自动缩进
set ruler                    " 右下角显示光标位置的状态行
set laststatus=2             " 总是显示状态行 
set expandtab                " 以下三个配合使用
set shiftwidth=2             " 设置<>平移的空格数 
set tabstop=2               
"set cursorline               " 为光标所在行加下划线
set number                   " 显示行号
set autoread                 " 文件在Vim之外修改过，自动重新读入
set autowrite                " 在多个文件之间编辑时，自动保存
set hls                      " 高亮搜索
set is                       " 查找执行前预览匹配
set helplang=cn              " 将帮助系统设置为中文
"set selectmode+=mouse        " 设置选择模式
"set foldmethod=syntax        " 代码折叠
set foldcolumn=2             " 显示折叠
set nocompatible             " vi不兼容模式
"set formatoptions+=ro        " 设置注释
set mouse=a                  " 设置鼠标选择
set fileencodings=ucs-bom,utf-8,gb2312,gbk " 设置文件加载的编码
" 

" conf for tabs,配置通过ctrl h/l切换标签
nnoremap <C-l> gt 
nnoremap <C-h> gT
nnoremap <F2> :NERDTreeToggle<CR>
nnoremap <C-A> :Ack 
nnoremap <F3> :wa<CR>
inoremap <F3> <Esc><F3>
nnoremap <F4> :wqa<CR>
inoremap <F4> <Esc><F4>
nnoremap <F5> :source ~/.vimrc<CR>
inoremap <F5> <Esc><F5>
nnoremap <F6> :wq<CR>
inoremap <F6> <Esc><F5>
" 关于退出保存，使用ZZ即可，仔细想想也就两次按键，不是特别麻烦
nnoremap <C-P> :CtrlP<CR>
inoremap <C-P> <Esc><C-P>
" <C-B>原有的功能是上下滚半屏
nnoremap <C-B> :CtrlPBuffer<CR>
inoremap <C-B> <Esc><C-B>
" <C-l>清除重绘先前的模式
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" gui configure 
set guifont=Monospace\ 12
"

" configure for plugins 
" disable powerline just because I hate muti-colour gui status bar
"powerline{ 
"set guifont=PowerlineSymbols\ for\ Powerline 
"set nocompatible 
"set t_Co=256 
"let g:Powerline_symbols = 'fancy' 
"} 

" pathogen 是Vim用来管理插件的插件 
"pathogen{ 
execute pathogen#infect() 
"}

" CommandT{
" command CT CommandT 
" command CB CommandTBuffer 
"}

" tComment{

"}

" emment{
let g:user_emmet_leader_key='<Tab>'
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall
"}
" SnipMate{
let g:snipMate = {}
let g:snipMate.scope_aliases = {}
let g:snipMate.scope_aliases['ruby'] = 'ruby,ruby-rails'
"}

" vim-ruby{
let g:ruby_indent_access_modifier_style = 'indent'
"}

" vim-indent-guides{
let g:indent_guides_auto_colors = 1
let g:indent_guides_guide_size = 1 

"autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=3
"autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=4

hi IndentGuidesOdd guibg=red ctermbg=3
hi IndentGuidesEven guibg=green ctermbg=4
" }
" Markdown vim{
let g:vim_markdown_folding_disabled=1   " disable folding
let g:vim_markdown_initial_foldlevel=1
" }
"
filetype indent on           " 针对不同的文件类型采用不同的缩进格式
filetype plugin on           " 针对不同的文件类型加载对应的插件
filetype plugin indent on    " 启用自动补全

" set man page windows
runtime! ftplugin/man.vim
runtime! macros/matchit.vim
```

安装的插件: 

```
▸ ack/  -  ack-grep 程序的VIM插件，可以在整个目录中查找特定的内容
▸ ctrlp/ - 在项目中快速寻找特定名字的文件
▸ delimitMate/ - 成对出现的符号工具
▸ emmet-vim/ - html的相关的辅助插件
▸ nerdtree/ - 目录树
▸ tcomment_vim/ - 注释插件
▸ tlib_vim/
▸ vim-addon-mw-utils/
▸ vim-angular/
▸ vim-bundler/
▸ vim-coffee-script/
▸ vim-haml/
▸ vim-indent-guides/
▸ vim-javascript/
▸ vim-markdown/
▸ vim-powerline/ - 强大的状态信息栏
▸ vim-rails/ - rails.vim插件
▸ vim-ruby/ - ruby.vim插件
▸ vim-snipmate/
▸ vim-snippets/
▸ vim-surround/
```

## Rails开发环境

Rails开发必备的gem包: 

* quiet_assets - 关闭开发环境下，静态资源的log的显示，可能比较罗嗦
* annotate -  注释 AR 的模型 
* `better_errors` - 和 `binding_of_caller` 提供web界面的错误调试
* meta_request - 与 chrome 插件 RailsPanel 相结合，可以在chrome想看相关的日志信息
* pry-rails - 强大的Rails Console环境
* pry-debugger  - 用来调试代码
* ruby-prof - rails代码执行时间度量工具
* rails_best_practices - Rails最佳实践工具
* rack-mini-profiler - 很好用的页面代码执行时间工具
* thin - Ruby的web应用服务器，基于强大的EventMachine工具
* capistrano - 部署代码使用的工具

代码度量的gem工具包: 

* [rubocop](https://github.com/bbatsov/rubocop): 静态代码检查工具
* [hound](https://github.com/thoughtbot/hound): 某持续集成工具
* [RubyBench](http://rubybench.org/): 基准测试工具
* [rails_best_practices](https://github.com/xinminlabs/rails-bestpractices.com)

几种不同的xxxfile

* Gemfile - [bundle](https://github.com/bundler/bundler)
* Rakefile - Rake相关的，用来加载一些内置的Rake任务
* Guardfile(与Guard有关) - 用来省去按F5的次数
* Procfile - [foreman](https://github.com/ddollar/foreman)

## 后记

好像也没什么好写的了。firefox的vim插件配置文件: 

```
"vimoperator的配置
nnoremap l <C-n>
nnoremap h <C-p>
"jk 加快上下翻页的速度
nnoremap  j  5j
nnoremap  k  5k
```

最近，发现，自己越来越蠢了，简直愚不可及。
