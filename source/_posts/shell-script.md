---
title: shell-script
date: 2023-05-08 20:48:01
tags:
    - Linux
---
###	选择 if



####	文件表达式

![image-20230507191528475](/images/mdpic/image-20230507191528475.png)

![image-20230507191538499](/images/mdpic/image-20230507191538499.png)



####	字符串表达式

![image-20230507191608702](/images/mdpic/image-20230507191608702.png)



####	整型表达式

![image-20230507191653313](/images/mdpic/image-20230507191653313.png)



####	现代的复合命令



```bash
[[ expression ]] 	# 支持字符串
(( expression ))	# 支持整数	
# 两者都默认将expr展开为数字，如果expr是字符串，则展开为0
```

增加了一个重要特性：

```bash
string1 =~ regex
```

使得支持正则表达式，如：

```bash
INT=-5
if [[ "$INT" =~ ^-?[0-9]+$ ]]; # 匹配整数
```



###	循环 while until for







####	for循环

```bash
for variable [in words]; do
	commands
done
```

或是

```bash
gx-mint:~$ for i in A B C; do echo $i; done
A
B
C
gx-mint:~$
```

或是:C语言格式

```bash
for (( expr1; expr2; expr3 )); do
	commands
done
```







###	字符串和数字



####	管理空变量的展开





```bash
${parameter:-word}
```

若 parameter 没有设置或者为空，展开结果是 word 的值。

若 parameter 不为空，则展开结果是 parameter 的值。





```bash
${parameter:=word}
```

若 parameter 没有设置或为空，展开结果是 word 的值。另外，word 的值会**赋值**给 parameter。

若 parameter 不为空，展开结果是 parameter 的值。





```bash
${parameter:?word}
```

若 parameter 没有设置或为空，这种展开导致脚本带有错误退出，并且 word 的内容会发送到**标准错误**。

 parameter 不为空，展开结果是 parameter 的值。





```bash
${parameter:+word}
```

若 parameter 没有设置或为空，展开结果为空。若 parameter 不为空，展开结果是 word 的值会替换掉 parameter 的值；

然而，parameter 的值不会改变。





####	返回变量名的参数展开

```bash
${!prefix*}
${!prefix@}
```

这种展开会返回以 prefix 开头的已有变量名。





####	字符串展开 (长度，切片，替换)



```bash
${#parameter}
```

展开成由 parameter 所包含的字符串的长度。



```bash
${parameter:offset}
${parameter:offset:length}
```

类似C++的substr



若 offset 的值为负数，则认为 offset 值是从字符串的末尾开始算起，而不是从开头。注意负数前面必须有一个空格，为防止与 ${parameter:-word} 展开形式混淆。length，若出现，则必须不能小于零。

```bash
bash#: foo="this string is long."
bash#: echo ${foo:5}
string is long.
bash#: echo ${foo:5:9}
string is
bash#: echo ${foo: -5}
long.
bash#: echo ${foo: -5:2}
lo
bash#:
```





```bash
${parameter#pattern}
${parameter##pattern}
```

这些展开会从 paramter 所包含的字符串中清除开头一部分文本，这些字符要匹配定义的 pattern。pattern 是**通配符模式**，就如那些用在路径名展开中的模式。

这两种形式的差异之处是该 # 形式清除最短的匹配结果，而该 ## 模式清除最长的匹配结果。

```bash
bash#: foo=file.txt.zip
bash#: echo ${foo#*.}
txt.zip
bash#: echo ${foo##*.}
zip
bash#:
```





```bash
${parameter%pattern}
${parameter%%pattern}
```

这些展开和上面的 # 和 ## 展开一样，除了它们清除的文本从 parameter 所包含字符串的**末尾**开始，而不是开头。







```bash
${parameter/pattern/string}
${parameter//pattern/string}
${parameter/#pattern/string}
${parameter/%pattern/string}
```

这种形式的展开对 parameter 的内容执行查找和替换操作。如果找到了匹配通配符 pattern 的文本，则用 string 的内容替换它。

在正常形式下，只有第一个匹配项会被替换掉。在该 // 形式下，所有的匹配项都会被替换掉。

该 /# 要求匹配项出现在字符串的开头，而 /% 要求匹 配项出现在字符串的末尾。

/string 可能会省略掉，这样会导致删除匹配的文本。

```bash
[me@linuxbox~]$ foo=JPG.JPG
[me@linuxbox ~]$ echo ${foo/JPG/jpg}
jpg.JPG
[me@linuxbox~]$ echo ${foo//JPG/jpg}
jpg.jpg
[me@linuxbox~]$ echo ${foo/#JPG/jpg}
jpg.JPG
[me@linuxbox~]$ echo ${foo/%JPG/jpg}
JPG.jpg
```





####	大小写转换

最新的 bash 版本已经支持字符串的大小写转换了。bash 有四个参数展开和 declare 命令的两个选项来支持大小写转换。



通过 declare 命令可以用来把字符串规范成大写或小写字符。使用 declare 命令，我们能强制一个变量总是包含所需的格式，无论如何赋值给它。

```bash
#! /bin/bash
declare -u upper
declare -l lower
if [[ $1 ]]; then
    upper="$1"
    lower="$1"
    echo $upper
    echo $lower
fi
```



通过四个参数展开，可以执行大小写转换操作

![image-20230508190738608](/images/mdpic/image-20230508190738608.png)



###	算术求值和展开



####	数基

![image-20230508191357008](/images/mdpic/image-20230508191357008.png)

```bash
gx-mint:~$ echo $((2#1111))
15
```





####	数组



遍历数组

```bash
for i in ${arr[*]}; do echo $i; done
for i in ${arr[@]}; do echo $i; done
```





确定数组元素个数

```bash
a[100]=foo
echo ${#a[@]} # number of array elements ${#a[*]} 同样效果
1
echo ${#a[100]} # length of element 100
3
```





获取数组使用的下标

```bash
${!array[*]}
${!array[@]}
```

这里的 array 是一个数组变量的名字。和其它使用符号 * 和 @ 的展开一样，用引号引起来 的 @ 格式是最有用的，因为它能展开成分离的词。

```bash
[me@linuxbox ~]$ foo=([2]=a [4]=b [6]=c)
[me@linuxbox ~]$ for i in "${foo[@]}"; do echo $i; done
a
b
c
[me@linuxbox ~]$ for i in "${!foo[@]}"; do echo $i; done
2
4
6
```





在数组末尾添加元素

```bash
[me@linuxbox~]$ foo=(a b c)
[me@linuxbox~]$ echo ${foo[@]}
a b c
[me@linuxbox~]$ foo+=(d e f)
[me@linuxbox~]$ echo ${foo[@]}
a b c d e f
```





排序数组

可以利用管道

```bash
arr=(6 5 4 3 2 1)
echo "Original array: ${arr[@]}"
a_sorted=($(for i in "${arr[@]}"; do echo $i; done | sort))
echo "Sorted array: ${a_sorted[@]}"
```





删除数组

```bash
[me@linuxbox ~]$ foo=(a b c d e f)
[me@linuxbox ~]$ echo ${foo[@]}
a b c d e f
[me@linuxbox ~]$ unset foo
[me@linuxbox ~]$ echo ${foo[@]}
[me@linuxbox ~]$
```

也可以使用 unset 命令删除单个的数组元素：

```bash
[me@linuxbox~]$ foo=(a b c d e f)
[me@linuxbox~]$ echo ${foo[@]}
a b c d e f
[me@linuxbox~]$ unset 'foo[2]'
[me@linuxbox~]$ echo ${foo[@]}
a b d e f
```

在这个例子中，我们删除了数组中的第三个元素，下标为 2。记住，数组下标开始于 0，而 不是 1！也要注意数组元素必须用引号引起来为的是**防止 shell 执行路径名展开操作**。 有趣地是，给一个数组赋空值不会清空数组内容：

```bash
[me@linuxbox ~]$ foo=(a b c d e f)
[me@linuxbox ~]$ foo=
[me@linuxbox ~]$ echo ${foo[@]}
b c d e f
```

任何没有下标的对数组变量的引用都指向数组元素 0：

```bash
[me@linuxbox~]$ foo=(a b c d e f)
[me@linuxbox~]$ echo ${foo[@]}
a b c d e f
[me@linuxbox~]$ foo=A
[me@linuxbox~]$ echo ${foo[@]}
A b c d e f
```



####	关联数组（哈希表？）

不同于整数索引的数组，仅仅引用它们就能创建数组，关联数组必须用带有 -A 选项的 declare 命令创建。

```bash
declare -A colors
colors["red"]="#ff0000"
colors["green"]="#00ff00"
colors["blue"]="#0000ff"

echo ${colors["blue"]}
```





###	奇珍异宝



####	组命令和子shell

组命令

```bash
{ command1; command2; [command3; ...] }
```

子shell

```bash
(command1; command2; [command3;...])
```

