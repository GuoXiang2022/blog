---
title: shell-script2
date: 2023-05-17 22:49:31
tags:
    - Linux
---

##	基本的 Shell 脚本



###	基本命令



####	1. 使用多个命令

shell脚本的关键在于输入多个命令并处理每个命令的结果。shell可以让你将多个命令串起来，一次执行完成。如果要两个命令一起运行，可以把它们放在同一行中，彼此间用分号隔开。

```bash
$date; who 
```

这种技术对于小型脚本尚可，但它有一个很大的缺陷：每次运行之前，你都必须在命令提示 符下输入整个命令。可以将这些命令组合成一个简单的文本文件，这样就不需要在命令行中手动输入了。在需要运行这些命令时，只用运行这个文本文件就行了。



####	2. 创建脚本文件

在创建shell脚本文件时，必须在文件的第一行指定要使用的shell。其格式为： 

```bash
#!/bin/bash 
```



####	3.显示消息



####	4.使用变量

- 环境变量

- 变量替换

- 命令替换

  两种方法执行命令替换：

  - 反引号字符（`）
  - $()格式

  示例：

  ```bash
  $testing=`date`
  $testing=$(date)
  ```

  注意：

  - 和管道类似，命令替换会创建一个子shell（子进程）来运行对应的命令。子进程复制状态，在子进程（子shell subshell）是无法修改父进程所创建的变量

  - 使用 `./` 运行命令的话，也会创建出子shell

####	5.输入输出重定向

- 输出重定向

- 输入重定向

  - 输入重定向

    ```bash
    $command < inputfile
    # 如:
    $wc < test.txt
    ```

  - 内联输入重定向（Here Documents）

    这种方法无需使用文件进行重定向，只需要在命令行中指定用于输入重定向的数据就可以了。 内联输入重定向符号是远小于号（<<）。除了这个符号，你必须指定一个文本标记来划分输 入数据的开始和结尾。任何字符串都可作为文本标记，但在数据的开始和结尾文本标记必须一致。

    ```bash
    command << marker
    data
    marker
    ```

    也被称为 **Here Documents**

    ```bash
    $ << EOF
    	here-document
    EOF
    ```

    默认情况下，here-document内容和双引号一样；有变量替换，命令替换等等。

    

    将负号附加到<<后具有忽略前导制表符的效果。

  - Here Strings

    是here-document的变种，形式是

    ```bash
    $ <<< word			# word 被扩展，提供给命令作为标准输入
    ```

    

####	6.管道

####	7.数学运算

- expr命令（原始做法，教麻烦）

- 使用方括号

  ```bash
  $[ operation ]
  ```

- 使用圆括号

  ```bash
  $(( operation ))
  ```



bash不提供浮点数运算，常用的解决方案是使用内置的bash计算器`bc`

- 在脚本中使用bc

  使用命令替换运行bc命令，并将输出赋给变量，如下

  ```bash
  $ var=$(echo "options; expression" | bc)
  ```

  如：

  ```bash
  var=$(echo "scale=4; 3/2" | bc)			# scale 保留几位有效小数
  echo $var
  ```

  如果需要进行大量运算，可以使用Here Documents

  ```bash
  variable=$(bc << EOF
  options
  statements
  expressions
  EOF
  ) 
  ```

  如：

  ```bash
  #!/bin/bash
  var1=10.46
  var2=43.67
  var3=33.2
  var4=71
  var5=$(bc << EOF
  scale = 4
  a1 = ( $var1 * $var2)
  b1 = ($var3 * $var4)
  a1 + b1
  EOF
  )
  ```

  



####	8.退出脚本



- 查看退出状态码

  Linux提供了一个专门的变量$?来保存上个已执行命令的退出状态码。

  ```bash
  $ date
  Sat Jan 15 10:01:30 EDT 2014
  $ echo $?
  0
  $ 
  ```

  **注意，状态码的范围在0-255**

  Linux错误退出状态码没有什么标准可循，但有一些可用的参考。

  ![image-20230516231345595](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230516231345595.png)

  

- exit 命令

  你可以返回自己的退出状态码。exit命令允许你在脚本结束时指定一个退出状态码。

  注意：如果你返回大于255，shell会通过模运算使其在0-255的区间内。



###	结构化命令



####	1.使用if-then



```bash
if command; then
	commands
fi
```







####	2.test命令



```bash
if test condition
then
	commands
fi
```



或是使用中括号，可以不写test

```bash
if [ condition ]; then
	commands
fi
```



test命令可以判断三类条件

- 数值比较
- 字符串比较
- 文件比较

![image-20230517143444675](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230517143444675.png)

![image-20230517143510996](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230517143510996.png)

![image-20230517143555840](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230517143555840.png)



####	3.复合条件测试



```bash
[ condition1 ] && [ condition2 ]
[ condition1 ] || [ condition2 ]
```





####	4.if-then的高级特性



**使用双括号 （高级数学表达式）**

双括号命令允许你在比较过程中使用高级数学表达式。test命令只能在比较中使用简单的 算术操作。双括号命令提供了更多的数学符号，这些符号对于用过其他编程语言的程序员而言并不陌生。双括号命令的格式如下：

```bash
(( expression ))
```

![image-20230517143928541](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230517143928541.png)



**使用双括号 （模式匹配）**

```bash
[[ expression ]]
```



双方括号里的expression使用了test命令中采用的标准字符串比较。但它提供了test命令未提供的另一个特性——**模式匹配（pattern matching 通配符）**。

如：

```bash
if [[ $USER == r* ]]
```



####	5.case命令



```bash
case variable in
pattern1 | pattern2) commands1;;
pattern3) commands2;;
*) default commands;;
esac 
```



###	更多结构化命令



####	1.for循环



####	5.更改字段分隔符

特殊的环境变量 IFS，叫作内部字段分隔符（internal field separator）。

IFS环境变量定义了bash shell用作字段分隔符的一系列字符。默认情况下，bash shell会将下列字符当作字段分隔符：

- 空格
- 制表符
- 换行符

如果bash shell在数据中看到了这些字符中的任意一个，它就会假定这表明了列表中一个新数 据字段的开始。在处理可能含有空格的数据（比如文件名）时，这会非常麻烦。

要解决这个问题，可以在shell脚本中临时更改IFS环境变量的值来限制被bash shell当作字段分隔符的字符。例如，如果你想修改IFS的值，使其只能识别换行符，那就必须这么做： IFS=$'\n' 



注意：在处理代码量较大的脚本时，可能在一个地方需要修改IFS的值，然后忽略这次修改，在脚本的其他地方继续沿用IFS的默认值。一个可参考的安全实践是在改变IFS之前保存原 来的IFS值，之后再恢复它。 这种技术可以这样实现： 

```bash
IFS_OLD=$IFS
IFS=$'\n'
<....>
IFS=IFS_OLD
```

这就保证了在脚本的后续操作中使用的是IFS的默认值。



如果要指定多个IFS字符，只要将它们在赋值行串起来就行。 

```bash
IFS=$'\n':;" 
```

这个赋值会将换行符、冒号、分号和双引号作为字段分隔符。如何使用IFS字符解析数据没 有任何限制。



####	2.C语言风格for



```bash
for (( var assignment ; condition; iteration process ))
```







###	呈现数据



####	1.理解输入和输出

​	Linux系统将每个对象当作文件处理。这包括输入和输出进程。Linux用文件描述符（file descriptor）来标识每个文件对象。文件描述符是一个非负整数，可以唯一标识会话中打开 的文件。每个进程一次最多可以有九个文件描述符。出于特殊目的，bash shell保留了前三个文 件描述符（0、1和2）

- STDIN 0

- STDOUT 1

- STDERR 2

  	如果需要重定向，如下：

1.将错误输出，标准输出重定向到不同文件中

```bash
ls -la badcommand 2> testerr 1> testout
```

2.将错误输出，标准输出重定向一个文件中

```bash
ls -la badcommand &> testall
```

注意一个细节；相对于标准输出，bash shell 自动赋予了错误消息更高的优先级。也就是错误输出会集中在文件的前面



####	2.在脚本中重定向输出

- 零时重定向行输出
- 永久重定向脚本中的所有命令



**临时重定向行输出**

如果有意在脚本中生成错误信息，可以将单独的一行输出重定向到STDERR，如：

```bash
#!/bin/bash
echo "This is an error" >&2		# 复制文件描述符
```

如果像平常一样运行这个脚本，你可能看不出什么区别。

```bash
bash test.sh
This is an error
```

记住，**默认情况下，Linux会将STDERR导向STDOUT**。但是，如果你在运行脚本时重定向了 STDERR，脚本中所有导向STDERR的文本都会被重定向。

```bash
bash test.sh 2> testerr
cat testerr
This is an error
```

这个方法非常适合在脚本中生成错误消息。如果有人用了你的脚本，他们可以像上面的例子 中那样轻松地通过STDERR文件描述符重定向错误消息。



**永久重定向**

如果脚本中有大量数据需要重定向，那重定向每个echo语句就会很烦琐。取而代之，你可 以用exec命令告诉shell在脚本执行期间重定向某个特定文件描述符。

```bash
#!/bin/bash
exec 1>testout
echo "dwadad"
```

**exec命令会启动一个新shell并将STDOUT文件描述符重定向到文件**。脚本中发给STDOUT的所有输出会被重定向到文件。

或是：

```bash
$ cat test11
#!/bin/bash
# redirecting output to different locations
exec 2>testerror
echo "This is the start of the script"
echo "now redirecting all output to another location"
exec 1>testout
echo "This output should go to the testout file"
echo "but this should go to the testerror file" >&2
$
$ ./test11
This is the start of the script
now redirecting all output to another location
$ cat testout
This output should go to the testout file
$ cat testerror
but this should go to the testerror file
$ 
```

当你只想将脚本的部分输出重定向到其他位置时（如错误日志），这个特性用起来非常方便。 不过这样做的话，会碰到一个问题。 一旦重定向了STDOUT或STDERR，就很难再将它们重定向回原来的位置。



####	3.在脚本中重定向输入

你可以使用与脚本中重定向STDOUT和STDERR相同的方法来将STDIN从键盘重定向到其他 位置。exec命令允许你将STDIN重定向到Linux系统上的文件中：

```bash
exec 0< testfile
```

这个命令会告诉shell它应该从文件testfile中获得输入，而不是STDIN。这个重定向只要在脚本需要输入时就会作用。下面是该用法的实例。

```bash
cnt=1
exec 0< foo.txt
while read li; do
    echo "Line #$cnt: $li"
    cnt=$[ $cnt + 1 ]
done
```

同样，会碰到一个问题。 一旦重定向了STDIN，就很难再将它们重定向回原来的位置。





####	4.创建自定义的重定向

在脚本中重定向输入和输出时，并不局限于这3个默认的文件描述符。**在shell中最多可以有9个打开的文件描述符**。**其他6个从3~8的文件描述符均可用作输入或输出重定向**。 你可以将这些文件描述符中的任意一个分配给文件，然后在脚本中使用它们。



**恢复已重定向的文件描述符**

1.可以用一个文件描述符保存原始的

```bash
exec 3>&1		# 3 复制为 1
...
exec 1>test		# 1 重定向
...
exec 1>&3		# 1 复制为 3

```

恢复输入重定向同理

```bash
exec 3<&0							# 保存原始的
exec < foo							# 重定向
cnt=1
while read line; do
    echo "Line #$cnt: $line"
    cnt=$[ $cnt + 1 ]
done
exec 0<&3							# 恢复
read -p "Are you done now ? " ans
case $ans in
Y|y) echo "Bye";;
N|n) echo "Sorry, this is the end";;
*)  echo "Error!";;
esac
```



**创建读写文件描述符**

尽管看起来可能会很奇怪，但是你也可以**打开单个文件描述符来作为输入和输出**。可以用同 一个文件描述符对同一个文件进行读写。 **不过用这种方法时，你要特别小心**。

```bash
exec 3<> testfile
read line <&3
echo "Read: $line"
echo "This is a test line" >&3
```

这个例子用了exec命令将文件描述符3分配给文件testfile以进行文件读写。接下来，它 通过分配好的文件描述符，使用read命令读取文件中的第一行，然后将这一行显示在STDOUT上。 最后，它用echo语句将一行数据写入由同一个文件描述符打开的文件中。 在运行脚本时，一开始还算正常。输出内容表明脚本读取了testfile文件中的第一行。但如果 你在脚本运行完毕后，查看testfile文件内容的话，你会发现写入文件中的数据覆盖了已有的数据。 当脚本向文件中写入数据时，它会从文件指针所处的位置开始。read命令读取了第一行数据，所以它使得文件指针指向了第二行数据的第一个字符。在echo语句将数据输出到文件时， 它会将数据放在文件指针的当前位置，覆盖了该位置的已有数据。



**关闭文件描述符**

如果你创建了新的输入或输出文件描述符，shell会在脚本退出时自动关闭它们。然而在有些 情况下，你需要在脚本结束前手动关闭文件描述符。

要关闭文件描述符，将它重定向到特殊符号&-。脚本中看起来如下：

```bash
[n] <& digit-
[n] >& digit-

#	将文件描述符digit移动为文件描述符n, 或标准输入或输出(文件描述符 0或1)，如果没有指定 n 的话。
#	digit 复制为 n 之后就被关闭了。
```

一旦关闭了文件描述符，就不能在脚本中向它写入任何数据，否则shell会生成错误消息。



####	5.列出打开的文件描述符

你能用的文件描述符只有9个，你可能会觉得这没什么复杂的。但有时要记住哪个文件描述 符被重定向到了哪里很难。为了帮助你理清条理，bash shell提供了lsof命令。

```bash
lsof # list open files
```

lsof命令会列出整个Linux系统打开的所有文件描述符。这是个有争议的功能，因为它会向 非系统管理员用户提供Linux系统的信息。鉴于此，许多Linux系统隐藏了该命令，这样用户就不会一不小心就发现了。

**该命令会产生大量的输出**。它会显示当前Linux系统上打开的每个文件的有关信息。这包括后台运行的所有进程以及登录到系统的任何用户。 有大量的命令行选项和参数可以用来帮助过滤lsof的输出。**最常用的有-p和-d，前者允许指定进程ID（PID），后者允许指定要显示的文件描述符编号。** 要想知道进程的当前PID，可以用特殊环境变量$$（shell会将它设为当前PID）。-a选项用来对其他两个选项的结果执行布尔AND运算，这会产生如下输出。

```bash
│gx-mint:~/ttt$ lsof -a -p $$ -d 0,1,2
~                                                                             │lsof: WARNING: can't stat() fuse.gvfsd-fuse file system /run/user/112/gvfs
~                                                                             │      Output information may be incomplete.
~                                                                             │COMMAND  PID     USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
~                                                                             │bash    4400 guoxiang    0u   CHR  136,2      0t0    5 /dev/pts/2
~                                                                             │bash    4400 guoxiang    1u   CHR  136,2      0t0    5 /dev/pts/2
~                                                                             │bash    4400 guoxiang    2u   CHR  136,2      0t0    5 /dev/pts/2
~                                                                             │gx-mint:~/ttt$
~                                                                             │
```



####	6.阻止命令输出

要解决这个问题，可以将STDERR重定向到一个叫作null文件的特殊文件。null文件跟它的名 字很像，文件里什么都没有。shell输出到null文件的任何数据都不会保存，全部都被丢掉了。 在Linux系统上null文件的标准位置是/dev/null。你重定向到该位置的任何数据都会被丢掉， 不会显示。

```bash
$ ls -al > /dev/null
$ cat /dev/null
$ 
```



####	7.创建临时文件

Linux系统有特殊的目录，专供临时文件使用。Linux使用/tmp目录来存放不需要永久保留的文件。大多数Linux发行版配置了**系统在启动时自动删除/tmp目录的所有文件**。 

系统上的任何用户账户都有权限在读写/tmp目录中的文件。这个特性为你提供了一种创建临时文件的简单方法，而且还不用操心清理工作。 有个特殊命令可以用来创建临时文件。mktemp命令可以在/tmp目录中创建一个唯一的临时文件。shell会创建这个文件，**但不用默认的umask值**。它会将文件的读和写权限分配给文件的属主，并将你设成文件的属主。一旦创建了文件，你就在脚本中有了完整的读写权限， 但其他人没法访问它（当然，root用户除外）。

1. **创建本地临时文件**

   ```bash
   mktemp	-d[创建目录而非文件] -t[在/tmp里面创建，并返回全路径名]
   ```





####	8.记录消息

将输出**同时发送到显示器和日志文件**，这种做法有时候能够派上用场。你不用将输出重定向 两次，只要用特殊的tee命令就行。

```bash
tee - 从标准输入读入并写往标准输出和文件
```

默认为覆盖写入文件

```bash
$ who | tee testfile
rich pts/0 2014-10-17 18:41 (192.168.1.2)
$ cat testfile
rich pts/0 2014-10-17 18:41 (192.168.1.2)
```

如果你想将数据追加到文件中，必须用-a选项。

```bash
date | tee -a testfile 
```

