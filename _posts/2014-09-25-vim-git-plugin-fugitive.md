---
layout: post
title: Fugitive.vim - a complement to command line git
---

## 简介
----

fugitive.vim插件是由[Tim Pope](https://github.com/tpope)创建的VIM插件。该插件与命令行git工具相辅相成，可以无缝的插入到工作流程中。 

Using the :Git command, you can run any arbitrary git command from inside Vim. I prefer to switch to the shell for anything that generates a log of output, such as git log for example. But commands that generate little or no output are fair game for running from inside Vim (:Git checkout -b experimental for example).

使用:Git 命令，可以在vim中运行任意的git 命令。对于生成大量log的命令，更加倾向于使用shell，例如 git log。但是，对于那些生成很少输出或者没有输出的命令，更加倾向于在vim中运行。

At Vim’s command line, the % symbol has a special meaning: it expands to the full path of the current file. You can use this to run any git command that expects a filepath as an argument, making the command act on the current file. But fugitive also provides a few convenience methods, some of which are summarized in this table:

在VIM的命令行中，%符号具有特殊的含义：他将扩展为当前文件的全路径。可以使用该命令来运行使用文件名作为参数的任意git命令，从而使得命令作用于当前的文件。但是fugitive也提供了一些便利的方法，其中的一些总结如下：

   git	        |   fugitive     |  	action
--------------- | -------------- | --------------------------------------------
:Git add %      |	:Gwrite        | Stage the current file to the index
:Git checkout % | :Gread 	       | Revert current file to last checked in version
:Git rm %       |	:Gremove 	     | Delete the current file and the corresponding Vim buffer
:Git  mv %      |	:Gmove 	       | Rename the current file and the corresponding Vim buffer


The :Gcommit command opens up a commit window in a split window. One advantage to using this, rather than running git commit in the shell, is that you can use Vim’s keyword autocompletion when composing your commit message.

:Gcommit命令在水平窗口打开一个提交窗口。使用这个而不是使用git commit命令行的优势是，这里可以使用VIM 的关键字补全的功能。

The :Gblame command opens a vertically split window containing annotations for each line of the file: the last commit reference, with author and timestamp. The split windows are bound, so that when you scroll one, the other window will follow.

:Gblame命令打开一个包含了每个文件的注释的垂直窗口：最后的提交引用，以及作者和时间戳。该垂直窗口是弹出的，所以滚动。

I'm not going to lie to you; fugitive.vim may very well be the best Git wrapper of all time. Check out these features:

View any blob, tree, commit, or tag in the repository with :Gedit (and :Gsplit, :Gvsplit, :Gtabedit, ...). Edit a file in the index and write to it to stage the changes. Use :Gdiff to bring up the staged version of the file side by side with the working tree version and use Vim's diff handling capabilities to stage a subset of the file's changes.

Bring up the output of git status with :Gstatus. Press - to add/reset a file's changes, or p to add/reset --patch. And guess what :Gcommit does!

:Gblame brings up an interactive vertical split with git blame output. Press enter on a line to edit the commit where the line changed, or o to open it in a split. When you're done, use :Gedit in the historic buffer to go back to the work tree version.

:Gmove does a git mv on a file and simultaneously renames the buffer. :Gremove does a git rm on a file and simultaneously deletes the buffer.

Use :Ggrep to search the work tree (or any arbitrary commit) with git grep, skipping over that which is not tracked in the repository. :Glog loads all previous revisions of a file into the quickfix list so you can iterate over them and watch the file evolve!

:Gread is a variant of git checkout -- filename that operates on the buffer rather than the filename. This means you can use u to undo it and you never get any warnings about the file changing outside Vim. :Gwrite writes to both the work tree and index versions of a file, making it like git add when called from a work tree file and like git checkout when called from the index or a blob in history.

Use :Gbrowse to open the current file on GitHub, with optional line range (try it in visual mode!). If your current repository isn't on GitHub, git instaweb will be spun up instead.

Add %{fugitive#statusline()} to 'statusline' to get an indicator with the current branch in (surprise!) your statusline.

Last but not least, there's :Git for running any arbitrary command, and Git! to open the output of a command in a temp file.

## 后记
-----

