---
layout: post
title: vim安装相关的配置
description: "自动化安装自己所需要的vim相关的插件"
category: life
---

## 前言

原本自己，在<coding.net>中备份了自己的工作配置，结果发现，没能将vim的插件备份到代码库中，为此，特定写一个脚本来处理自动安装vim插件。

## 正文

vim插件的管理是通过 pathogen.vim 来处理的，总共安装了如下的这些插件:

```
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
cd ~/.vim/autoload 
git clone https://github.com/mileszs/ack.vim
git clone https://github.com/tpope/vim-rails
git clone https://github.com/kien/ctrlp.vim
git clone https://github.com/mattn/emmet-vim
git clone https://github.com/scrooloose/nerdtree
git clone https://github.com/tomtom/tcomment_vim
git clone https://github.com/tomtom/tlib_vim
git clone https://github.com/tpope/vim-fugitive
git clone https://github.com/Lokaltog/vim-powerline
git clone https://github.com/plasticboy/vim-markdown
git clone https://github.com/pangloss/vim-javascript
git clone https://github.com/tpope/vim-haml
```
