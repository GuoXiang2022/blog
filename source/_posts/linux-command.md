---
title: linux-command
date: 2023-04-13 14:13:51
tags:
    - Linux
---
##	2.

> 查看文件命令：



查看文件的信息

```bash
file a.out

a.out: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=4ebd1342118461f6fda0894bd8ae17db171dfdad, for GNU/Linux 3.2.0, not stripped
```



查看文件的大小，权限，创建时间

```c++
ls -l a.out
    
-rwxrwxr-x 1 guoxiang guoxiang 16520  4月 10 19:06 a.out
```



打开可执行二进制文件，找出汇编代码（反汇编）

```bash
objdump -d a.out | less
```





> 编译相关



不动态链接

```bash
gcc 1.c -static
```



查看所有编译选项 

```c++
gcc 1.cpp --verbose
```



查看所有链接选项

```c++
gcc hello.c -static -Wl, --verbose
```



```bash
gcc -E hello.c		# 显示预处理后的文件
gcc -c hello.c		# 生成hello.o（汇编）
ld hello.o			# 生成
```







> gdb



