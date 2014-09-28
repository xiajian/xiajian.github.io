---
layout: post
title: Javascript异步编程的笔记
---
JavaScript是多媒体、多任务、多内核网络世中的单线程的语言。

事件，多线程，复杂的事件集。单线程设计，setTimeout，回调，清晰，可维护性的异步代码。

多线程的语言，没有概念？

for (var i = 1; i <= 3; i++) {  
  setTimeout(function(){ console.log(i); }, 0);
};
# => 输出为 4 4 4
原因: 

- var i的变量的生命周期延伸到了内部函数中
- 循环结束后，i=4 
- js事件处理器在线程空闲之前不会运行

setTimeout，延时事件队列，事件循环。延迟执行，永不中断。

异步函数集，例如:setTimeout和setInterval。异步函数分类: I/O函数和计时函数。非阻塞式I/O。

有些I/O函数既有同步效应也有异步效应。 非阻塞式I/O，语言的核心优势。


