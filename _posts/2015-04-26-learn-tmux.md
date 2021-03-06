---
layout: post
title: 学习tmux
description: "tmux，linux"
---
 
## 前言

去年5月时候，管理实验室机房的服务器时，那时就发现，又是需要打开多个命令行终端，执行不同的任务，觉得很麻烦。希望能找到替代的解决方案，并发现了这样的工具: screen, tmux, Byobo。

今天，自己也深入学习一下，从而提高自己的工作效率。

## 正文

tmux的快捷键是以Ctrl-b开头的引导键序列。 使用的通用的c/s架构。

配置文件: `~/.tmux.conf`

```
unbind C-b
set -g prefix C-a     # 引导符
setw -g mode-keys vi  # 在选择模式下，启用vi模式

# split window like vim
# vim's defination of a horizontal/vertical split is revised from tumx's
bind s split-window -h
bind v split-window -v
# move arount panes wiht hjkl, as one would in vim after C-w
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# resize panes like vim
# feel free to change the "1" to however many lines you want to resize by,
# only one at a time can be slow
bind < resize-pane -L 10
bind > resize-pane -R 10
bind - resize-pane -D 10
bind + resize-pane -U 10

# bind : to command-prompt like vim
# this is the default in tmux already
bind : command-prompt
```

常用按键: 

```
tmux #开启tmux
tmux ls #列出会话 

tmux attach -t session #进入某个会话  
tmux -r 连接上次断开的session

C-b d 临时断开session 断开以后,还可以连上的哟:) 
C-b c 创建一个新的window
C-b 数字 直接跳到你按的数字所在的window 
C-b " 在下边分割出来一个pane  
C-b % 在右边分割出来一个pane
C-b o 在多个panes中切换 
C-b x 关闭当前光标处的pane 
C-b t 很酷的一个时钟
```

更多快捷键(以下按键为先导键之后的按键)，tmux的快捷键大多为单个键:

```
系统操作   
    ?   #列出所有快捷键；按q返回   
    d   #脱离当前会话；这样可以暂时返回Shell界面，输入tmux attach能够重新进入之前的会话   
    D   #选择要脱离的会话；在同时开启了多个会话时使用   
    Ctrl+z  #挂起当前会话   
    r   #强制重绘未脱离的会话   
    s   #选择并切换会话；在同时开启了多个会话时使用   
    :   #进入命令行模式；此时可以输入支持的命令，例如kill-server可以关闭服务器   
    [   #进入复制模式；此时的操作与vi/emacs相同，按q/Esc退出   
    ~   #列出提示信息缓存；其中包含了之前tmux返回的各种提示信息   
窗口操作   
    c   #创建新窗口   
    &   #关闭当前窗口   
    数字键 #切换至指定窗口   
    p   #切换至上一窗口   
    n   #切换至下一窗口   
    l   #在前后两个窗口间互相切换   
    w   #通过窗口列表切换窗口   
    ,   #重命名当前窗口；这样便于识别   
    .   #修改当前窗口编号；相当于窗口重新排序   
    f   #在所有窗口中查找指定文本   
面板操作   
    ”   #将当前面板平分为上下两块   
    %   #将当前面板平分为左右两块   
    x   #关闭当前面板   
    !   #将当前面板置于新窗口；即新建一个窗口，其中仅包含当前面板   
    Ctrl+方向键    #以1个单元格为单位移动边缘以调整当前面板大小   
    Alt+方向键 #以5个单元格为单位移动边缘以调整当前面板大小   
    Space   #在预置的面板布局中循环切换；依次包括even-horizontal、even-vertical、main-horizontal、main-vertical、tiled   
    q   #显示面板编号   
    o   #在当前窗口中选择下一面板   
    方向键 #移动光标以选择面板   
    {   #向前置换当前面板   
    }   #向后置换当前面板   
    Alt+o   #逆时针旋转当前窗口的面板   

    Ctrl+o  #顺时针旋转当前窗口的面板
```

此外，发现一个不太方便的地方，那就是在终端中，滚轮的作用被覆盖了。也就是无法上下翻滚，查看长的命令输入。能保持session，确实是个优点。

备注，不能翻屏，各种难用，shell的执行也不那么明朗。不如我原生的termial。 不过，我的终端gui总是容易崩溃，让人觉得稍微有些不爽，这也是我稍微羡慕 Apple 机器的一点。

## 参考文献

1. [为什么使用tmux](http://www.cnblogs.com/itech/archive/2012/12/17/2822170.html)
