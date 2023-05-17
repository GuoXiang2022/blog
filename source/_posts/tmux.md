---
title: tmux
date: 2023-05-17 22:52:21
tags:
    - Linux
---

##	tmux



#### tmux的主要功能

1. 对终端实现分屏功能和便捷的多任务切换。
2. 允许断开terminal之后，继续后台运行执行中的进程。

#### tmux的结构

1. 一个tmux里可以包含多个会话`sessions`，一个`session`可以有多个窗口`windows`，一个`window`可以有多个窗格`panes`。
2. 所有的tmux命令都以`Ctrl + b`为前缀（特指进入tmux后的所有指令，在terminal里的指令不需要）。具体操作是先按下`Ctrl + b`后手指松开，然后再按其他键。在下面的表示中将其表示为`Ctrl + b` `<key>`。

####	tmux指令



可以新建一个session，其中包含一个window，该window中包含一个pane，pane里打开了一个shell对话框。

```bash
tmux
```



tmux创建的session的名字默认都是按数字排序，所以可以在进入tmux时对session自定义名字。

```bash
tmux new -s [session_name]
```



`Ctrl + b` `d` 在tmux里，如果需要重新退回terminal，可输入上面的命令。其中d表示**detaching**，运行后并不会真正关闭session，而是将session挂起，在tmux session里面的程序还是会在后台继续运行。

如果想要重新连接刚才退出的tmux session，可以输入下面命令：

```bash
tmux attach
tmux a
```



如果想连接到特定的session：

```bash
$ tmux attach -t [session_name]

#也可以将attach简写成a
$ tmux a -t [session-name]
```





查看当前存在哪些session，可以输入下方命令查看：

```bash
tmux ls
```





如果要关闭某个会话：

```bash
# 使用会话编号或具体名字
$ tmux kill-session -t 0
$ tmux kill-session -t <session-name>
```



####	快捷键

在某个session里时，

`Ctrl + b` `c`可以创建新的window。

`Ctrl+b` `0` 可以切换到0号window。

`Ctrl + b` `p`切换到上一个window。

`Ctrl + b` `n`切换到下一个window。

`Ctrl+b` `,` 对当前window进行重命名。

`Ctrl+b` `w` 可以从window列表里选择window，该显示结果与`Ctrl + b` + `s` 一样。

在新建的一个window里，默认只有一个pane，但是可以对其进行切分：

`Ctrl+b` `%` 可以将当前pane分成左右两个panes。

`Ctrl+b` `"` 可以将当前pane分成上下两个panes。

`Ctrl+b` `o`可以移动到下一个pane里。

`Ctrl+b` `;`可以切换到上一个pane里。

`Ctrl + b` `<arrow key>`也可以直接通过上下左右箭头来切换panes。

`Ctrl+b` `x`关闭当前所在pane，这种关闭，会在关闭前进行确认。

`Ctrl + b` `z` 可以将当前的pane进行放大/缩小。

`Ctrl + d` 或者 直接输入`exit`：直接关闭当前pane；如果当前window的所有pane均已关闭，则自动关闭当前window；直至所有window均已关闭，则自动关闭当前session。