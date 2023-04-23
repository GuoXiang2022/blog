---
title: linux-command
date: 2023-04-13 14:13:51
tags:
    - Linux
---

> linux 相关指令

###	查看文件命令

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



###	编译相关

静态链接

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



预处理，编译，链接指令

```bash
gcc -E hello.c		# 显示预处理后的文件
gcc -c hello.c		# 生成hello.o（汇编）
ld hello.o			# 链接
```



###	gdb

...



###	查看进程相关



持续的监视进程的信息

```bash
top		# 查看进程以及进程所占用的资源
```



查看进程的瞬间信息（系统在过去执行的进程的静态快照）

```bash
ps aux  		# 可以持续的监视进程的信息。
ps -p <pid> 	# 查看指定进程
```



查看进程占用的端口号

```bash
netstat -tunlp 	# 列出所有正在使用的网络连接和监听的端口，以及与之关联的进程ID和名称等。
```



查看特定端口上正在运行的进程

```bash
netstat -tunlp | grep <port>

kill <PID>		# 查找占用指定端口的进程的PID，并杀死进程
```





###	常用的管道命令



用于屏幕阅读的文件阅读过滤器：

```bash
./a.out | less
./a.out | more					# less 和 more 的行为类似
```



对内容进行排序：

```bash
./a.out | less | sort
```



对内容进行去重

```bash
./a.out | less | uniq
```



显示内容的行数，字符数

```bash
./a.out | wc -l				# 显示行数
./a.out | wc -c				# 显示字符数

./a.out | wc -lc			# 显示行数和字符数
```



###	 重定向



覆盖式重定向

```bash
ls -l /usr/bin > ls-output.txt
```



追加式重定向

```bash
ls -l /usr/bin >> ls-output.txt
```







###	常用文件路径

用户文件

```bash
/usr 		# 存放用户程序和数据的目录。
```



日志文件

```bash
/var		# 存放系统日志文件、邮件、数据库等变化频繁的文件。
```



系统配置文件

```bash
/etc		# 存放系统配置文件。
```



用户的家目录

```bash
/home		# 存放用户的家目录，每个用户都有一个对应的家目录。
```



超级用户 root 的家目录

```bash
/root		# 超级用户 root 的家目录。
```



二进制文件

```bash
/bin		# 存放常用命令的二进制文件。
/sbin		# 存放系统管理命令的二进制文件。
/usr/bin	# 存放用户常用命令的二进制文件。
/usr/sbin	# 存放系统管理员使用的命令的二进制文件。
```



黑洞路径

```bash
/dev/null	# 黑洞。它非常等价于一个只写文件。所有写入它的内容都会永远丢失。而尝试从它那儿读			   取内容则什么也读不到。

cat $filename >/dev/null	# 文件内容丢失，而不会输出到标准输出。

0：表示标准输入流（stdin），

1：表示标准输出（stdout）。

2：表示标准错误输出（stderr）

rm $badname 2>/dev/null     # 这样错误信息[标准错误]就被丢到太平洋去了。

```







### 权限

更改文件的所有者的读、写和执行权限

```bash
sudo chmod u+rwx file.txt
```



更改文件所属组的读和执行权限

```bash
sudo chmod g+rx file.txt
```



更改其他用户的执行权限

```bash
sudo chmod o+x file.txt
```



更改所有用户的读权限和执行权限

```bash
sudo chmod a+rx file.txt
```



更改文件的所有权限

```bash
sudo chmod 777 file.txt
```



在以上命令中，`+`表示添加权限，`-`表示删除权限，`u`表示文件所有者，`g`表示文件所属组，`o`表示其他用户，`a`表示所有用户。权限表示为`r`（读取）、`w`（写入）和`x`（执行），可以根据需要组合使用。



###	网络



显示和管理系统的路由表

```bash
route
```



显示 IP 数据包从源到目标的路由路径

```bash
traceroute www.google.com
```



显示系统的网络状态和连接信息

```bash
netstat -tulnp
netstat -an
```



显示系统的网络套接字信息

```bash
ss
```



查询 DNS 记录

```bash
dig www.google.com
```



在网络上发送和接收数据

```bash
nc
```



查询 DNS 记录并查找域名的 IP 地址

```bash
nslookup
```



从 Web 上下载文件

```bash
wget https://www.example.com/file.zip
```



发送 HTTP 请求和接收响应

```bash
curl -I https://www.example.com
```



