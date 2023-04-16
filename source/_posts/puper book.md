---
title: Puper Book
date: 2023-04-12 19:58:47
#type: "algorithm"
#categories: - [algorithm,puperbook]
#categories: 
#    - algorithm
tags:
    - algorithm
---




## 1.printf控制符.*控制显示精度

```c++
printf("%.*lf\n",c,(double) a / b);
```




## 1.scanf("%s")

**scanf("%s", s)； 遇到空格或者TAB会停下来。   scanf("%s", s)；会读入一个不含空格，tab和回车的字符串**

```c++
char s[100];
scanf("%s", s);
printf("%s", s);
//如果输入abc efg
//则程序输出s为abc， efg没有读取！
```



```c++
// intput:  abc def 
while(scanf("%s %s") != EOF)	//EOF = -1

//intput:	abc
//    		def
while(scanf("%s%s") != EOF)

//input: 	is the question 包含空格的字符串
fgetc(fin) 或 getchar() 或 fgets(buf,maxn,fin) 或 gets() (已经删除)
while((c = getchar()) != EOF)
```

**对于其他的格式串控制符（如scanf(%d)）**

**scanf()会跳过空白字符（空格符，制表符，换行符）**

**scanf()中的格式串字符：**

**1.空白字符**

​	**scanf()中的格式串中的一个空白字符可以和输入中的任意数量（包括零个）空白字符相匹配，这意味着格式串中有一个或多个连续的空白字符的作用都是一样的，数量是无关紧要的**

**2.其他字符**

​	**scanf()中格式串的其他字符需要严格匹配，如果不匹配则将不匹配字符放回输入中并异常退出**



## 2.fgetc(fin)与getchar()

​	**读取一个打开的文件fin，读取一个字符，然后返回一个int值。为什么是int不是char，因为如果文件结束，fgetc将返回一个特殊标记EOF，它并不是一个char。如果要从标准输入读取一个字符，可以用getchar，它等价于fgetc(stdin)。**



## 3.fgets(buf,maxn,fin)和gets()

​	**读取完整的一行，和fgetc一样，fgets也有一个标准输入版gets。遗憾的是，gets和它的兄弟fgets差别比较大，其用法是gets(s)没有指明读取的最大字符数，这就出现了一个问题：gets将不停地往s中存储内容，而不管是否存储得下! 所以gets已经被废除了，但为了向后兼容，仍然可以使用它。事实上，在C11标准里，gets函数已被正式删除**



## 4.putchar()输出一个字符



##	5.scanf()的返回值：

**1.正整数：表示正确输入参数的个数**

**2.0：表示用户输入不匹配**

**3.EOF：这是stdio.h里面定义的常量（通常是-1），表示输入流已经结束**



##	1.统计字符1的个数

```c++
#define maxn 10000000 + 10
void sss(){
    char s[maxn];
    scanf("%s", s);
    int tot = 0;
    for(int i = 0; i < strlen(s); ++i)
        if(s[i] == 1) tot++;
    printf("%d\n", tot);
}
```

####	该程序至少有三个问题，一个导致程序无法运行，另一个导致结果不正确，还有一个导致效率低下。

```c++
#define maxn 10000000 + 10
char s[maxn];	//数组设置过大，应将数组声明在全局
void sss(){
	scanf("%s", s);
	int tot = 0;
	for(int i = 0; s[i]; ++i)	//如果输入字符串过长，那么strlen计算的时间就会加长，会降低效率
		if(s[i] == '1')	tot++;	//字符数组应该和字符匹配
	printf("%d\n", tot);
}
```

  

##	1.leetcode 2293

![img](https://assets.leetcode.com/uploads/2022/04/13/example1drawio-1.png)

```c++
//我的方案
class Solution {
public:
    int minMaxGame(vector<int>& nums) {
        int n = nums.size(), l = 0, r = n - 1, k = 0;
        while(l < r){    
            bool flag = true;
            for(int i = 0; i <= r; i += 2){
                int v = flag ? min(nums[i],nums[i + 1]) : max(nums[i],nums[i + 1]);
                nums[k++] = v;
                flag = !flag;
            }
            r = k - 1;
            k = 0;
        } 

        return nums[0];
    }
};
```



##	题解：

###	方法一：模拟

```c++
class Solution{
public:
	int minMaxGame(vector<int>& nums){
		int n = nums.size();
		while(n != 1){
			vector<int> newNums(n / 2);
			for(int i = 0; i < newNums.size(); i++){
				if(i & 0x01)
					newNums[i] = min(nums[2 * i], nums[2 * i + 1]);
				else
					newNums[i] = max(nums[2 * i], nums[2 * i + 1]);
			}
			nums = newNums;
			n /= 2;
		}
		return nums[0];
	}
}
```

###	方法二：递归

```c++
class Solution{
public:
	int minMaxGame(vector<int>& nums){
		int n = nums.size();
		if(n == 1)
			return nums[0];
		vector<int> newNums(n / 2);
		for(int i = 0; i < newNums.size(); i++){
			if(i & 0x01)
				newNums[i] = min(nums[2 * i], nums[2 * i + 1]);
			else
				newNums[i] = max(nums[2 * i], nums[2 * i + 1]);
		}
		return minMaxGame(newNums);
	}
}
```

###	方法三：原地修改

```c++
class Solution{
public:
    int minMaxGame(vector<int>& nums){
        int n = nums.size();
        while(n != 1){
            int m = n >> 1;
            for(int i = 0; i < m; i++){
                if(i & 0x01)
                	nums[i] = min(nums[2 * i], nums[2 * i + 1]);
                else
                    nums[i] = max(nums[2 * i], nums[2 * i + 1]);
                
            }
            n = m;
        }
        return nums[0];
    }  
}
```





##	1. exe3-2 分子量 UVa1586

###		方法：模拟

```c++
#include <stdio.h>
#include <cctype>
#include <unordered_map>
int main(){
    unordered_map<int,double> hash;
    hash['C'] = 12.01, hash['H'] = 1.008, hash['O'] = 16.00, hash['N'] = 14.01;
    char s[30];
    int t; scanf("%d", &t);
    while(t--){
    	scanf("%d", s);
        double ans = 0;
        int n = strlen(s);
        for(int i = 0; i < n; ++i){
            char c = s[i];
            if(i + 1 == n || isalpha(s[i + 1]))
                ans += hash[c];
            else{
                int sum = 0;
                while(i + 1 < n && isdigit(s[i + 1])){
                    sum = sum * 10 + s[i + 1];
                    i++;
                }
                ans += sum * hash[c];
            }
            printf("%.3lf\n", ans);
        }    
    }
}
```



##	2. exe3-4 周期串 UVa455

###		方法：暴力枚举

```c++
#include <stdio.h>
#include <cstring>
int main(){
    char s[100];
    int t; scanf("%d", &t);
    while(t--){
        scanf("%s", s);
        int n = strlen(s);
        for(int i, d = 1; d <= n; ++d){
     		if(n % d == 0){
             	for(i = d; i < n; ++i)
                	if(s[i] != s[i % d])
                        break;
            	if(i == n){
                    printf("%d\n", d);
                    break;
                }
            }
        }    
        if(t)	printf("\n");
    }
}
```



##	3. exe3-9 子序列 UVa 10340

###	方法：双指针

```c++
#include <stdio.h>
#include <cstring>
int s[1000000],t[1000000];   //不能 s[1e7];
//s <- t
int main(){
    while(scanf("%s %s",s,t) != EOF){
		int n1 = strlen(s), n2 = strlen(t);
        int k = 0;
        if(n1 > n2){
            printf("No\n");
            continue;
        } 
        for(int i = 0 ; i < n2; ++i){
            if(s[k] == t[i])
                ++k;                  
        }
        if(k == n1)	printf("Yes\n");
        else	printf("No\n");        
    }        
}
```



##	4. ‘\0’和‘ ’

**'\0'不代表空格，’\0'的ASCII码为0，' '的ASCII码为32**



##	5. vscode 快捷键

###	1.向上/向下 移动代码行

​	**alt+ 下箭头/上箭头**

###	2.向上/向下 复制代码行

​	**shift+alt+ 下箭头/上箭头**

###	3.快速定位到某一行

​	**ctrl + g**

###	4.选择某个区块

​	**按住alt + shift 然后拖动鼠标**

###	5.光标定位到单词首/尾

​	**Ctrl + 左箭头/ 右箭头**

###	6.光标定位到行首/尾

​	**Home/End**

###	7.增加/减少缩进

​	**Ctrl + [ / ]**





#   第四章	函数和递归



##	1.算法竞赛中的函数

​	1.在算法竞赛中，总是让main函数返回0。

​	2.typedef 和 struct

​			typedef struct { 域定义; } 类型名;



##	2.计算组合数

**有问题的做法  （会溢出）**

```c++
long long fun(int n){
    long long m = 1;
    for(int i = 1; i <= n; ++i)
    	m *= i;
    return m;
}
long long C(int n,int m){
    return fun(n) / (fun(m) * fun(n - m));
}
```

**正确做法  （约分化简）**

```c++
long long C(int n,int m){
    if(m < n - m)	m = n - m;	//C25 = C52
    long long ans = 1;
    for(int i = m + 1; i <= n; ++i)
        ans *= i;
    for(int i = 1; i <= n - m; ++i)	
        ans /= i;
    return ans;    
}
```



##	3.素数判定

**有问题的做法 （溢出）**

```c++
bool is_prime(int n){	//is_prime == is it a prime
    for(int i = 2; i * i <= n; ++i)	//当i过大时，i*i会溢出为负数
        if(n % i)	return false;
   	return true;
}
```

**正确做法**

```c++
#include <cmath>
bool is_prime(int n){
    if(n <= 1)	return false;	//特殊判断
    int m = floor(sqrt(n) + 0.5);	//向上取整
    for(int i = 2; i <= m; ++i)
        if(n % i == 0)	return false;
    return true;       
}
```

```c++
double floor(double arg)	//返回不大于arg的最大整数值  向下取整
double ceil(double arg)		//返回不小于arg的最小整数值  向上取整
```



**注意：以上只是初级做法，当n很大时，上述函数并不能很快计算出结果。对此在竞赛篇会有更详细的讨论**



##	4. 调用栈	Call Stack

**调用栈Call Stack和栈帧Stack Frame**



##	5.函数指针

**格式： 函数的返回回类型  (*指针名) (函数的参数列表)**

```c++
char *const *(*next)();
//next是一个指向函数的指针，该函数返回一个指向只读指针的指针，且此只读指针指向一个字符变量
```



##	6.递归中的段错误与栈溢出

**段错误 Segmentation fault**

​	**段是指二进制文件内的区域，所有特定类型信息都被保存在这里面。调用栈在运行时创建，调用栈所在的段称为堆栈段Stack Segment。和其他段一样，堆栈段也有自己的大小，不能被越界访问，否则会出现段错误。**

​	**每次递归调用都需要往调用栈里增加一个栈帧。久而久之就越界了。这种情况叫做栈溢出。**

​	**别忘了，局部变量也时放在堆栈段的。栈溢出不一定时递归调用太多，也可能时局部变量太大。只要总大小超过了允许的范围，就会产生栈溢出，从而出现段错误报错。故建议把较大的数组放在函数的外面**





#	1.25



##	1. exe4-3 救济金发放	UVa 133

**在循环(环状)数组中实现双向移动**

```c++
input:			output:
10 4 3			空空4空空8, 
 0 0 0				
```

```c++
#include <stdio.h>
#include <cstring>
int n, k, m, arr[30];
int solve(int p,int n,int d){
    do{
        p = (p + d + n - 1) % n;
        /*
        	p ∈ [1,n]
        	(p + 1) % n ∈ [2,n - 1] and 0
        	
        	(p - 1) % n + 1 ∈ [1,n] 控制结果范围可以为n
        	(p - 1 + d) % n + 1  if (p - 1 + d) < 0 ?
        	
        	n % m == (n + m) % m 解决减法的负数问题
        	所以最终 (p + d + n - 1) % n
        */
    }
    while(arr[p]);
    return p;
}
int main(){
    while(scanf("%d%d%d", &n, &k, &m) == 3 && n){
        memset(arr,0,sizeof(arr));
        int s = n, p1 = n, p2 = 1;	//注意这里
        while(s){
            p1 = solve(p1,s,1), p2 = solve(p2,s,-1);
            printf("%3d", p1);
            s--;
            if(p1 != p2)	{printf("%3d", p2), s--;}
            arr[p1] = arr[p2] = 1;
            printf(",");         
        }
        printf("\n");
    }
    return 0;
}
```



## 2. exe4-4 信息解码	UVa 213

**模拟**

```c++
#include <cstdio>
#include <cstring>
#include <string>
int code[8][1<<8];

int readchar(){
	while(true){
		int ch = getchar();
		if(ch != '\n' && ch != '\r' && ch != ' ')	return ch;
        //注意 ch != ' '
	}
}

int getint(int n){
	int res = 0;
	while(n--)	res = res * 2 + readchar() - '0';
	return res;
}

int readcodes(){
	memset(code,0,sizeof(code));
	code[1][0] = readchar();
	for(int len = 2; len <= 7; ++len){
		for(int i = 0; i < (1 << len) - 1; ++i){
			int ch = getchar();
			if(ch == EOF)	return 0;
			if(ch == '\n' || ch == '\r')	return 1;
			code[len][i] = ch;
		}
	}
	return 1;
}
int main(){
	while(readcodes()){
		while(true){
			int len = getint(3);
			if(len == 0)	break;
			while(true){
				int v = getint(len);
				if(v == (1 << len) - 1)	break;
				putchar(code[len][v]);	
			}
		}
		putchar('\n');
	}
	return 0;
}
```



#	**第五章	C++与STL入门**



##	1.C++中用C的头文件

**C++能编译大多数C预言程序。虽然C语音中大多数头文件在C++中仍然可以使用，但推荐的方法是在C头文件之前加一个小写的c字母，然后去掉.h后缀**



##	2.使用cin输入数据

**while(cin >> a >> b)**

​	**含义是从标准输入中读取a，它的返回值是一个已经读取了a的新流，然后从这个新流中继续读取b。如果流已经读完，while循环将退出。**

​	**当然C++流也不是完美的，其最大缺点就是运行太慢。一般可以关闭stdio同步以加快速度,即调用ios::sync_with_stdio(false)**



##	3.C++中的字符输入

**考虑这样一个题目：输入数据的每行包含若干个以空格隔开的整数，输出每行中所有整数之和**

```c++
#include <iosteam>
#include <string>
#include <sstream>
using namespace std;
int main(){
    string line;
    while(getline(cin,line)){	//getline 类似 fgets,但由于使用string类，无需指定字符串最大长度
        int sum = 0;
        stringstream ss(line);
        while(ss >> x)	sum += x;
        cout << sum << "\n";
    }
    return 0;
}
```

**缺点就是string较慢，sstream更慢**

##	4. C++的结构体与模板

**1.C++不再需要用typedef的方式定义一个struct，C++中struct和class最主要的区别是默认访问权限和继承方式不同，其他方面的差异很小**

**2.模板在工程中的应用很广，而且功能十分强大，但是在算法竞赛中很少需要亲自编写模板，学习模板的主要在于让我更好的理解STL**



##	5. STL初步

####	1.排序与搜索 UVa10474

```c++
#include <cstdio>
#include <algorithm>

int main(){
	int n, q, k, arr[10000], c = 1;
	while(scanf("%d%d", &n, &q) == 2){
		printf("CASE# %d:\n", c++);
		for(int i = 0; i < n; ++i)	scanf("%d", &arr[i]);
		std::sort(arr, arr + n);
		while(q--){
			scanf("%d", &k);
			int p = std::lower_bound(arr, arr + n, k) - arr;	//lower_bound也可以手写二分
			if(p < n && arr[p] == k)	printf("%d found at %d\n", k, p + 1);
			else	printf("%d not found\n", k);
		}
	}

	return 0;
}
```

####	2.集合set UVa10815

```c++
#include <string>
#include <sstream>
#include <cctype>
#include <set>
using namespace std;
int main(){
    string s,buf;
    set<string> st; 
    while(cin >> s){
    	for(auto &ch:s)
            if(isalpha(ch))	ch = tolower(ch);	else ch = ' ';
        stringstream ss(s);
        while(s >> buf)	st.insert(buf);	               
    }
    for(auto &str:st)
        cout << str << endl;
    return 0;
}
```



####	3.映射map UVa156

```c++
#include <string>
#include <iostream>
#include <map>
#include <algorithm>
#include <vector>
using namespace std;

string solve(const string& s){
	string res;
	for(auto &ch:s)
		res.push_back(tolower(ch));
	sort(res.begin(),res.end());
	return res;
}

int main(){
	string s;
	map<string,int> hash;
	vector<string> words;
	while(cin >> s && s != "#"){
		words.push_back(s);
		hash[solve(s)]++;
	}
	vector<string> ans;
	for(auto &word:words){
		if(hash[solve(word)] == 1)	ans.push_back(word);
	}
	sort(ans.begin(),ans.end());
	for(auto &s:ans)
		cout << s << endl;
	return 0;
}
```

**没有想到标准化(全部转换为小写)这个思路和良好的代码设计，是很难用map简化代码的！**



####	4.栈，队列与优先队列

##### **1.uva12096 实现集合栈**

实现一个集合栈，支持一下操作：

PUSH:空集”{}“入栈

DUP:把当前栈顶元素复制一份后再入栈

UNION:出栈两个集合，然后把二者的并集入栈

INTERSECT:出栈两个集合，然后把两者的交集入栈

ADD:出栈两个集合，然后把先出栈的集合加入到后出栈的集合中，把结果入栈

每次操作后，输出栈顶集合的大小（元素个数）

#####	此题是一道非常有质量的题，考察了你的思路和STL综合水平

```c++
#include <iostream>
#include <string>
#include <algorithm>
#include <set>
#include <map>
#include <vector>
#include <stack>
#include <itreator>
map<set<int>,int> hash;	//集合->id
vector<set<int>> arr;	//id->集合

int getid(set<int> x){
    if(hash.count(x))	return hash[x];
    arr.push_back(x);
    return hash[x] = arr.size() - 1;	//为了id->集合，id设置为数组下标
}

#define ALL(x)	x.begin(),x.end()
#define INS(x)	inserter(x,x.begin())

void solve(){
    stack<int> stk;	//存储集合id
    int n;	cin >> n;
    while(n--){
        string op;
        cin >> op;
        if(op == "PUSH")	stk.push(getid(set<int>()));
        else if(op == "DUP")	stk.push(stk.top());
        else{
            auto x1 = arr[stk.top()];	stk.pop();
            auto x2 = arr[stk.top()];	stk.pop();
            set<int> x;
            if(op == "UNION")	set_union(ALL(x1),ALL(x2),INS(x));
            if(op == "INTERSECT")	set_intersect(ALL(x1),ALL(x2),INS(x));
            if(op == "ADD")	{x = x2; x.insert(x1);}
            stk.push(x);
        }
       	cout << arr[stk.top()].size() << endl;
    }
	cout << "***" << endl;     
}

int main(){
    int t; cin >> t;
    while(t--){
        solve();
    }
    return 0;
}
```

**此题考察了：**

1. **集合与id映射的思路**
2. **STL中的map和set容器**
3. **STL algorithm库中的set_union(),set_intersect()函数**
4. **插入迭代器**

关于插入迭代器：

​	**itreator category :** 

1. input_iterator
2. output_iterator    （独立于1345之外）
3. forward_iterator
4. bidirectional_iterator
5. random_access_iterator

其中output_iterator常用的：

1. ostream_iterator
2. ostreambuf_iterator
3. insert_iterator
4. back_insert_iterator
5. front_insert_iterator

如insert_iterator

```c++
#include <iterator>
#include <set>
#include <algorithm>
#include <vector>
#define ALL(x)	x.begin(),x.end()
int main(){
    set<int> s1 = {1,2,3}, s2 = {1,2,4};
    vector<int> arr;
    set_union(ALL(s1),ALL(s2),insert_iterator<vector<int>>(arr,arr.end()));
    //set_union(ALL(s1),ALL(s2),inserter(arr,arr.begin()));
    //可以通过inserter()函数模板来简化
    for(auto x:arr)
        cout << x << endl;
}
```



##### **2.uva540	团体队列**

有 t个团队的人正在排长队。每有一个新来的人时，他会从队首开始向后搜寻，如果发现有队友正在排队，他就会插队到他队友的身后；如果没有发现任何一个队友排队，他就只好站在长队的队尾。

输入每个团队中所有队员的编号，要求支持如下 33 种指令：

`ENQUEUE x`：编号为 x* 的人进入长队。

`DEQUEUE`：长队的队首出队。

`STOP`：停止模拟。

对于每个 `DEQUEUE` 指令，输出出队的人的编号。

```c++
#include <bits/stdc++.h>
using namespace std;
int main(){
    int t;
	while(cin >> t && t){
        map<int,int> team;
        int x,n;
        cin >> n;
        for(int i = 0; i < t; ++i)
            while(n--){cin >> x; team[x] = i;}
        queue<int> q;
        vector<queue<int>> arr(t,queue<int>());
        string op;
      	while(true){
            cin >> op;
            if(op == "STOP")	break;
            int id; cin >> id;
            if(op == "ENQUEUE"){
                int pos = team[id];
                if(arr[pos].empty())	q.push(pos);
                arr[pos].push(id);
            }
            if(op == "DEQUEUE"){
                int pos = q.front();
                cout << arr[pos].front();
                arr[pos].pop();
                if(arr[pos].empty())	q.pop();
            }
        }
        cout << endl;
    }
    return 0;    
}
```

**此题考察：**

1. **队列的应用**



#####	3. uva136 丑数

题意描述：丑数是一些因子只有2,3,5的数。数列1,2,3,4,5,6,8,9,10,12,15……写出了从小到大的前11个丑数，1属于丑数。现在请你编写程序，找出第1500个丑数是什么。

没有输入

```c++
#include <bits/stdc++.h>
using namespace std;
int base[] = {2,3,5};
int main(){
    set<long long> st;	//去重
    priority_queue<long long,vector<long long>,greater<long long>> heap;
    st.insert(1);
    heap.push(1);
    for(int i = 1; i <= 1500; ++i){
        long long x = heap.top();
        heap.pop();
        if(i == 1500){cout << "The 1500'th ugly number is " << x << ".\n";	break;}
        for(int j = 0; j < 3; ++j){
            long long nx = x * base[j];
            if(!st.count(nx))	{st.insert(nx); heap.push(nx);}
        }
    }
    return 0;
}
```

**此题考察：**

1. **priority_queue优先队列的使用**
2. **set去除重复元素**



####	5.测试STL

1. cstdlib中的rand()，它生成一个闭区间[0,RAND_MAX]内的均匀随机整数
2. srand(time(null))，目的是初始化随机树种子，不然种子相同，每次随机数序列也相同



##	6.应用：大整数类

​	由于语言性质，会出现很多整数溢出的情形。如果运算结果很大，就需要用到所谓的高精度算法，既用数组来存储整数，并模拟手算的方法进行四则运算。

​	知识点：

1. static关键字

   1. **static关键字属于存储类说明符**，存储类说明符包括：static，extern，thread_local，mutable。

   2. **存储期**：程序中的所有对象都具有下列存储期之一：

      1. **自动（automatic)存储期。**这类对象的存储在代码块开始分配，并在结束时销毁。未声明为`static`，`extern`或`thread_local`的所有局部对象均拥有期存储期。
      2. **静态（static）存储期。**这类对象的存储在程序开始时分配，并在程序结束时候销毁。这类对象只存在一个实例。带有`static`或`extern`的对象均拥有此存储期
      3. **线程（thread）存储期。**这类对象的存储在线程开始时分配，并在线程结束时解分配。每个线程拥有它自身的对象实例。只有声明为 `thread_local` 的对象拥有此存储期。`thread_local` 能与 `static` 或 `extern` 一同出现，它们用于调整链接。
      4. **动态（dynamic）存储期。**这类对象的存储是通过使用[动态内存分配](https://zh.cppreference.com/w/cpp/memory)函数来按请求进行分配和解分配的。关于具有此存储期的对象的初始化的细节，见 [new 表达式](https://zh.cppreference.com/w/cpp/language/new)。

   3. **链接**：https://zh.cppreference.com/w/cpp/language/storage_duration

   4. **静态局部变量**：在块作用域声明且带有 `static` 或 `thread_local` (C++11 起) 说明符的变量拥有静态或线程 (C++11 起)存储期，但在控制首次经过它的声明时才会被初始化（除非它被[零初始化](https://zh.cppreference.com/w/cpp/language/zero_initialization)或[常量初始化](https://zh.cppreference.com/w/cpp/language/constant_initialization)，这可以在首次进入块前进行）。在其后所有的调用中，声明都会被跳过。

   5. **静态成员函数和静态成员变量**：

      1. 静态成员函数：没有this指针，所以不能访问成员变量和成员函数，只能访问静态成员变量。

      2. 静态成员变量：打破不同对象的成员变量的独立性。每个对象都共用一个实列。static成员变量属于类，不属于某个具体的对象，只为它分配一份内存。static成员变量必须在类声明的外部初始化。在初始化时不能再加static，但是必须要有数据类型！被 private、protected、public 修饰的静态成员变量都可以用这种方式初始化。没有在类外初始化的static成员变量不能使用。注意：static 成员变量不占用对象的内存，而是在所有对象之外开辟内存，即使不创建对象也可以访问。

      3. 示例：

         ```c++
         #include <bits/stdc++.h>
         using namespace std;
         
         struct ss{
         	static int x;
         	static void fun(){cout << x << endl;}
         
         };
         
         int ss::x = 666;
         
         int main(){
         	ios::sync_with_stdio(false);
         	
         	ss::fun();
         
         	ss obj;
         	obj.fun();
         
         	ss *p = new ss;
         	p->fun();
         	delete p;
         
         	ss::fun();
         
         	return 0;
         }
         ```


      大整数的实现见技巧点.md

##	7.竞赛题目举例

####	1.uva400 unix is命令

输入正整数`n` 以及`n` 个文件名，排序后按列优先的方式左对齐输出。假设最长文件名有`M` 字符，则最右边有`M` 字符，其他列都是`M+2 `字符,至多有60列

```c++
#include <bits/stdc++.h>
using namespace std;
const int maxcol = 60;
void print(const string& s,int n,char ch){
    cout << s;
    for(int i = 0; i < n - s.size(); ++i)
        cout << ch;
}
int main(){
 	int n;
    //freopen(".out","w",stdout);	//可以把标准输出内容保存到文件中
    while(cin >> n){
        vector<int> arr(n);
        int m = 0;
        for(int i = 0; i < n; ++i)	{ cin >> arr[i]; m = max(m,(int)arr[i].size());}
        int c = (maxcol - m) / (m + 2) + 1, r = (n - 1) / c + 1;	//向上取整
        sort(arr.begin(),arr.end());
        print("",60,'-');
        cout << endl;
        for(int i = 0; i < r; ++i){
            for(int j = 0; j < c; ++j){
                int idx = r * j + i;	//按列输出  可以举例子验证
                if(idx < n)	print(arr[idx], j == c - 1 ? m : m + 2, ' ');
            }
            cout << endl;
        }
    }
    //fcolse(stdout);
    return 0;
}
```

知识点：

1. 向上取整
2. 把标准输出保存到文件中方便debug
3. 按列输出



##	8.习题

####	1.uva1593 代码对齐 

```c++
#include <bits/stdc++.h>
using namespace std;

const int maxrow = 1010;
const int maxcol = 200;

vector<vector<string>> lines(maxrow,vector<string>());
vector<int> arr(maxcol,0);


void print(const string& s,int n){
	cout << s;
	for(int i = 0; i < n - s.size(); ++i)	// s.size()的返回值是unsigned_int,  n是int, unsigned_int比int表示的数值范围要大，n会整型提升为unsigned_int。 如果 n - s.size() 为负数， 在unsigned_int里面将表示成一个很大的数！
		cout << ' ';
}


int main(){
	ios::sync_with_stdio(false);
	freopen(".out","w",stdout);
	string line, word;
	int n = 0;
	while(getline(cin,line)){
		stringstream ss(line);
		while(ss >> word)	lines[n].push_back(word);	
		++n;
	}

	for(int i = 0; i < n; ++i){
		for(int j = 0; j < lines[i].size(); ++j)
			arr[j] = max(arr[j], (int)lines[i][j].size() + 1);
	}

	for(int i = 0; i < n; ++i){
		for(int j = 0; j < lines[i].size(); ++j){
			if(j != lines[i].size() - 1)	print(lines[i][j], arr[j]);
			else	print(lines[i][j],lines[i][j].size());
		}
		cout << endl;
	}
	fclose(stdout);
	return 0;
}
```

知识点：

1. 二维vector
2. **stringstream对字符串的处理**



####	2.uva1594 Ducci序列

```c++
#include <bits/stdc++.h>
using namespace std;
int main(){
    ios::sync_with_stdio(false);
    int n;
    cin >> n;
    set<vector<int>> st;
    while(n--){
        int k;
        cin >> k;
        vector<int> arr(k),zero(k,0);
        for(int i = 0; i < k; ++i)	cin >> arr[i];
        while(true){
            vector<int> tmp(k);
            for(int i = 1; i < k; ++i)	tmp[i - 1] = abs(arr[i] - arr[i - 1]);
            tmp[k - 1] = abs(arr[k - 1] - arr[0]);
            if(st.count(tmp))	{cout << "LOOP" << endl; break;}	
            if(tmp == zero)	{cout << "ZERO" << endl; break;}
            arr = tmp;
            st.insert(arr);
        }
    }
    return 0;
}
```

知识点：

1. **set	利用set判断是否出现循环**

​	

####	3.uva10935 卡牌游戏

```c++
#include <bits/stdc++.h>
using namespace std;
int main(){
    ios::sync_with_stdio(false);
    int n;
    while(cin >> n && n){
        queue<int> q;
        for(int i = 1; i <= n; ++i)	q.push(i);
        cout << "Discarded cards:";
        while(q.size() > 1){
            if(q.size() == n)	cout << " ";
            else	cout << ", ";
            cout << q.front();
            q.pop();
            q.push(q.front());
            q.pop();
        }
        cout << endl << "Remaining card: " << q.front() << endl;
    }
    return 0;
}
```



####	4.uva10763 交换学生

第一版本

```c++
#include <bits/stdc++.h>
using namespace std;

const int maxn = 500010;
vector<pair<int,int>> arr(maxn);

int main(){
	ios::sync_with_stdio(false);
	freopen(".out","w",stdout);
	int n;
	map<pair<int,int>,int> hash_;
	
	while(cin >> n && n){
		hash_.clear();
		for(int i = 0; i < n; ++i)	cin >> arr[i].first >> arr[i].second;
		for(int i = 0; i < n; ++i){
			pair<int,int> tmp = {arr[i].second,arr[i].first}; 
			if(hash_.count(tmp))	{--hash_[tmp]; if(hash_[tmp] == 0)	hash_.erase(tmp);}
			else	++hash_[arr[i]];	
		}
		if(hash_.empty())	cout << "YES";
		else	cout << "NO";
		cout << endl;
		//for(auto p:hash_)
		//	cout << "(" << p.first << "," << p.second << ")" << endl;
	}
	fclose(stdout);
	return 0;
}
```

第二版本

```c++
#include <bits/stdc++.h>
using namespace std;

int main(){
	ios::sync_with_stdio(false);
	freopen(".out","w",stdout);
	int n;
	map<pair<int,int>,int> hash_;
	while(cin >> n && n){
		hash_.clear();
		int a,b;
		for(int i = 0; i < n; ++i)	{cin >> a >> b; ++hash_[{a,b}];}
		bool flag = true;
		for(auto &p:hash_){
			if(p.second != hash_[{p.first.second,p.first.first}])	flag = false;
		}
		if(flag)	cout << "YES";
		else	cout << "NO";
		cout << endl;

	}
	fclose(stdout);
	return 0;
}
```

**版本二更简洁！**

知识点：

1. map



####	5.uva10391 复合词

```c++
#include <bits/stdc++.h>
using namespace std;
int main(){
    ios::sync_with_stdio(false);
    string s;
    set<string> st;
    while(cin >> s)	st.insert(s);
    for(auto str:st){
        //枚举左右两个单词的长度
        int i;
        for(i = 1; i < n; ++i){
            if(st.count(str.substr(0,i)) && st.count(str.substr(i))){
                cout << str << endl;
                break;
            }
        }
    }
}
```

知识点：

1. 利用set判断是否有出现的字符串

2. 枚举子字符串的长度，利用string的substr函数

3. substr函数细节：

   ![image-20230203181935132](/images/mdpic/image-20230203181935132.png)





####	6.uva1595 对称轴

```c++
#include <bits/stdc++.h>
using namespace std;
bool solve(vector<pair<int,int>>& arr){
    auto aux = arr;	//关键的辅助函数
    sort(arr.begin(),arr.end(),[](pair<int,int> a,pair<int,int> b){return a.first != b.first ? a.first < b.first : a.second < b.second;})
    sort(aux.begin(),aux.end(),[](pair<int,int> a,pair<int,int> b){return a.first != b.first ? a.first > b.first : a.second < b.second;})
    double a = (arr[0] + aux[0]) / 2.0;	//注意！必须要2.0，不然(arr[0] + aux[0]) / 2 会等于整型  如：33 / 2 = 16！
   	int i, n = arr.size();
    for(i = 0; i < n; ++i){
        if(arr[i].first != (2 * a - arr[i].first) || arr[i].second() != aux[i].second())	break;    
    }
    return i == n;
}
int main(){
    ios::sync_with_stdio(false);
    int t;
    cin >> t;
    while(t--){
        int n;
        cin >> n;
        vector<pair<int,int>> arr(n);
        for(int i = 0; i < n; ++i)	cin >> arr.first >> arr.second;
        if(solve(arr))	cout << "YES";
        else	cout << "NO";
        cout << endl;
    }
    return 0;
}
//	关键在于这个aux数组
//	arr : [5,10],[5,14],[6,10],[6,14]
//	aux : [6,10],[6,14],[5,10],[5,14]
//	如果想在arr上直接比较(i = 0,j = n-1 前后指针)	可以看到上面这个例子，是比较不上的！

```

知识点：

1. lambda表达式自定义sort

2. 对称轴的知识：如果 a 是对称轴，则必有 f(x) == f(2a - x)

3. 辅助数组的构造，思路！

   

####	7.uva12100 打印队列

```c++
#include <bits/stdc++.h>
using namespace std;
int main(){
    ios::sync_with_stdio(false);
    int t;
    cin >> t;
    while(t--){
        int n,k,lv;
        cin >> n >> k;
        queue<pair<int,int>> q(n);	//first表示位置，second表示优先级
        priority_queue<int> heap;
        for(int i = 0; i < n; ++i){
            cin >> lv;
            q.push({i,lv});
            heap.push(lv);
        }
        int res = 0;
        while(true){
            int cur = heap.top();	heap.pop();
            while(cur != q.front().second)	{ q.push(q.front()); q.pop();}
            ++res;
            if(q.front().first == k)	{ cout << res << endl; break; }
            q.pop();
        }
    }
    return 0;
}
```



#	**第六章 数据结构基础**



##	1.再谈栈和队列

####	1.uva514 铁轨

![image-20230206151611806](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230206151611806.png)

```c++
#include <bits/stdc++.h>
using namespace std;
const int maxn = 1010;
int target[maxn];
int main(){
    ios::sync_with_stdio(false);
    int n;
    while(cin >> n && n){
        while(cin >> target[1] && target[1]){
            for(int i = 2; i <= n; ++i)	cin >> target[i];
            int A = 1, B = 1;
            stack<int> stk;
            bool flag = true;
            while(B <= n){
                if(A == B)	{++A,++B;}
                else if(!stk.empty() && stk.top() == target[B])	{stk.pop(); ++B;}
                else if(A <= n)	stk.push(A++);
                else	{flag = false; break;}
            }
            if(flag)	cout << "Yes";	else	cout << "No";
            cout <<endl;
        }
		cout <<endl;
    }
    return 0;
}
```

知识点：

1. 栈
2. 分类讨论



####	2.uva442 矩阵链乘

![image-20230206171958758](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230206171958758.png)

分析：简单的表达式解析可以借助栈来完成，此题保证输入格式是合法的

1.我的版本

```c++
#include <bits/stdc++.h>
using namespace std;

int main(){
	ios::sync_with_stdio(false);
	freopen(".out","w",stdout);
	
	unordered_map<string,pair<int,int>> hash;
	int n;
	//char ch;
	string s;
	cin >> n;
	for(int i = 0; i < n; ++i){
		cin >> s;
		cin >> hash[s].first >> hash[s].second;
	}

	stack<string> stk;
	while(getline(cin,s)){
		int res = 0;
		if(s.size() == 1)	{cout << 0 << endl; continue;}	
		//cout << "curr string =" << s << endl;
		for(auto ch:s){
			if(ch == ')'){
				string a,b = stk.top();
				int r1,c1,r2 = hash[b].first, c2 = hash[b].second;
				stk.pop();
                //不知道输入一定合法，不存在（A）,所以这里还多加了判断
				if(stk.top() != "(")	{a = stk.top(); r1 = hash[a].first, c1 = hash[a].second; stk.pop();}
				stk.pop();	//'('弹出
				if(c1 != r2)	{cout << "error" << endl; res = 0; break;}
				string tmp = a + b;
				res += r1 * c1 * c2;
				hash[tmp].first = r1,hash[tmp].second = c2;
				stk.push(tmp);
			}
			else{
				string tmp;
				tmp += ch;
				stk.push(tmp);
			}
		}
		if(res)	cout << res << endl;
	}
	fclose(stdout);
	return 0;
}
```

2.紫书版本

```c++
#include <bits/stdc++.h>
using namespace std;
struct Matrix{
    int a,b;
    Matrix(int a = 0,int b = 0):a(a),b(b){}
}m[26];
stack<Matrix> s;
int main(){
    int n;
    cin >> n;
    for(int i = 0; i < n; ++i){
        char ch;
        cin >> ch >> m[ch - 'A'].a >> m[ch - 'A'].b;
    }
    string expr;
    while(cin >> expr){
       	int len = expr.size(), ans = 0;
        bool error = false;
        for(int i = 0; i < len; ++i){
            if(isalpha(expr[i]))	s.push(m[expr[i] - 'A']);
            else if(expr[i] == ')'){
                Matrix m2 = s.top(); s.pop();
                Matrix m1 = s.top(); s.pop();
                if(m1.b != m2.a)	{ error = true; break; }
                ans += m1.a * m1.b * m2.b;
                stk.push(Matrix(m1.a,m2.b));
            }
        }
        if(error)	cout << "error"; else cout << ans;
        cout << endl;
    }
    
    return 0；
}
```

知识点：

1. 利用栈来处理简单的表达式解析
2. 在竞赛中，常常会使用结构体



##	2.链表

**链表的实现并不一定要用指针。可以详见技巧点**



####	1.uva11988 破损的键盘

![image-20230207154945869](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230207154945869.png)

STL链表版

```c++
#include <bits/stdc++.h>
using namespace std;
int main(){
    ios::sync_with_stdio(false);
	string s;
    while(cin >> s){
     	list<char> li;
        auto it = li.begin();
        for(auto ch:s){
            if(ch == '[')	it = li.begin();
            else if(ch == ']')	it = li.end();
            else{
                li.insert(it,ch);
            }
        }
        for(auto ch:li)
            cout << ch;
        cout << endl;
    }
  	return 0;
}

```

知识点：

1. 分析这类题，我们可以看到在开头保存内容，如果用传统数组需要大量的拷贝移动，会TLE；

2. 主要考察是否想到使用链表

   

####	2.uva12657 移动盒子 （提高题）

![image-20230207204925658](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230207204925658.png)

分析：

1. 根据上一题的经验可以知道，用数组肯定会tle，本题依旧使用链表，而操作1需要把X移动到Y的左边（前面）,所以需要使用双向链表
2. 在双向链表这样的复杂链式结构中，往往会编写一些辅助函数用来设置链接关系，可以大大简化代码，且不容易出错

第一版本

```c++
#include <bits/stdc++.h>
using namespace std;

int main(){
	ios::sync_with_stdio(false);
	freopen(".out","w",stdout);
	
	int n, k,kase = 0;
	while(cin >> n >> k){
		vector<int> nxt(n+1),prev(n+1);
		for(int i = 1; i <= n; ++i){
			//nxt[i] = i + 1;
			nxt[i] = (i + 1) % (n + 1);
			prev[i] = i - 1;
		}
		nxt[0] = 1;
		prev[0] = n;
		bool flag = false;	

		while(k--){
			int op, x, y;
			cin >> op;
			if(op < 4){
				cin >> x >> y;
				int yp = prev[y], yn = nxt[y];
				if(op < 4){
                    //判断特殊情况
					if(flag && op != 3)	op = 3 - op;
					if(op == 3 && nxt[y] == x)	swap(x,y);
					if(op == 1 && x == prev[y])	continue;
					if(op == 2 && x == nxt[y])	continue;
					nxt[prev[x]] = nxt[x];
					prev[nxt[x]] = prev[x]; 
					if(op == 1){
						nxt[yp] = x;
						prev[x] = yp;
						nxt[x] = y;
						prev[y] = x;
					}
					else if(op == 2){
						prev[yn] = x;
						nxt[x] = yn;
						nxt[y] = x;
						prev[x] = y; 
					}
					else{
					
						// (a) x (b) (c) y (d)
						// a y b --- c x d

						// (a) x y (b)
						// a y x b
						if(nxt[x] != y){
							int a = prev[x], b = nxt[x], c = prev[y], d = nxt[y];
							nxt[a] = y; prev[y] = a;
							nxt[y] = b; prev[b] = y;

							nxt[c] = x; prev[x] = c;
							nxt[x] = d; prev[d] = x; 
						}
						else{
							int a = prev[x], b = nxt[y];
							nxt[a] = y; prev[y] = a;
							nxt[y] = x; prev[x] = y;
							nxt[x] = b; prev[b] = x;
						}
						
					}
				}			
			}
			else{
				flag = !flag;
			}
			/*
			for(int i = 0; i <= n; ++i)
				cout << nxt[i] << " ";
			cout << endl;  */

		}

		int cur = 0;
		long long ans = 0;

		for(int i = 1; i <= n; ++i){
			cur = nxt[cur];
			if(i & 0x1)	ans += cur;
		}
		if(flag && !(n & 0x1))	ans = (long long) n * (n + 1) / 2 - ans;
		cout << "Case " << ++kase  << ": " << ans << endl;
	}

	
	fclose(stdout);
	return 0;
}
```

**知识点**

1. **如果数据结构上的某一个操作很耗时，有时可以用加标记的方式处理，而不需要真的执行那个操作。但同时，该数据结构的所有其他操作都要考虑这个标记。**

2. **本题最tricky的是操作4。如果枚举反转则会TLE。我们分析`n的奇偶`,`反转次数`,`反转后执行操作123`，可以总结出规律：**

   1. **反转次数为偶数等于没有反转**
   2. **反转后的操作1等于不反转的操作2，**
   3. **n是奇数的情况下，答案输出奇数位，n是偶数的情况下，答案需要输出偶数位**

3. **还有一些tricky的地方在于，需要特判一些情况，如在操作3中 x 和 y相临等等。**

4. **非常考验总结，细心，逻辑以及数据结构的一道模拟题**

   

####	3.总结

**1.复杂的链式数据结构往往容易写错。**

如何测试上述代码的正确性呢？一个行之有效的办法是：再找一份完成同样功能的代码与之对比。对于移动盒子这到题来说，可以先写一个基于数组的版本。虽然这个版本会很慢，但正确性比较容易保证。接下来编写一个数据生成器（rand()等），并且反复执行下面的操作：生成随机数据，分别执行两个程序，比较它们的结果（俗称：**对拍**）。

**2.测试数据结构程序的常用方法是对拍：写一个功能相同但速度较慢的简易版本，再写一个数据生成器，不停对比快慢两个程序的输出。简易版本的代码越简单越好，因为重点不在效率，而在正确性。**

如果发现让两个程序答案不一致的数据，最好别急着对它进行调试。可以尝试着减少数据生成器中的n和m，试图找到一组尽量简单的错误数据。一般来说，数据越简单，越容易调试。如果发现只有很大的数据才会出错，通常意味着程序在处理极限数据方法有问题，列如，is_prime中遇到了过大的n，或者数组开得不够大等，这些都是很实用的技巧，需要多多积累

**3.数据的复杂性会大大影响调试的难度，因此在找到让程序出错的数据之后最好别急着调试，而应尝试简化数据，或者直接用更小的参数调用数据生成器，以找到更简单的错误数据。**



##	3.树和二叉树



###	1.二叉树的编号

####	1.uva679 小球下落

![image-20230208152817483](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230208152817483.png)

版本一：模拟整个过程

```c++
#include <bits/stdc++.h>
using namespace std;
const int maxd = 20;
bool st[(1 << maxd) - 1];
int main(){
    ios::sync_with_stdio(false);
    int t;
    cin >> t;
    while(t--){
        memset(st,0,sizeof(st));
        int d, n. cur;
        cin >> d >> n;
        int maxn = (2 << d) - 1;
        for(int i = 0; i < n; ++i){
            cur = 1;
            while(cur <= maxn){
                st[cur] = !st[cur];
                cur = st[cur] ? 2 * cur : 2 * cur + 1;
            }
        }
        cout << cur / 2 << endl;
    }
    
   	return 0;  
}
```

版本二：分析规律

对于每一个节点，都有：

1. 若小球是经过当前节点的奇数个小球，往左走
2. 若是偶数个，往右走
3. 对于下一个节点，也执行同样的操作，直到走到叶节点结束

对于本题来说：

1. 每一个小球都落到根节点上
2. 落到每一个非叶节点的小球，奇数个会往左子树落，偶数个会往右子树落。
3. 如：有5个小球落到根节点上，有3个会往左落，有2个会往右落。直到最后一个小球

```c++
#include <bits/stdc++.h>
using namespace std;
int main(){
    ios::sync_with_stdio(false);
    int t;
    cin >> t;
    while(t--){
        int d, n, ans = 1;
        cin >> d >> n;
        //枚举 2 到 d 层  根节点这一次无需枚举
        for(int i = 0; d - 1; ++i){
            if(n & 0x1)	{ ans = 2 * ans; n = (n + 1) / 2;}
            eles	{ ans = 2 * ans + 1; n /= 2;}
        }
        cout << ans << endl;
    }
    return 0;
}
```

知识点：

1. 满二叉树编号
2. 分析问题，总结规律的能力，我比较缺乏



###	2.二叉树的层序遍历

####	1.uva122 树的层次遍历 （困难题）

![image-20230208173458410](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230208173458410.png)

![image-20230208173509722](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230208173509722.png)

分析：

1. 需要正确处理输入
2. 建立二叉树，可以是动态，静态和动态化静态
3. 执行层序遍历，输出结果

版本一

```c++
//动态建立二叉树
#include <bits/stdc++.h>
using namespace std;

int maxn = 10000 + 10;
char s[maxn];
bool flag;

struct TreeNode{
    int val;
    TreeNode *left,*right;
    TreeNode():val(0),left(nullptr),right(nullptr){}
}*root;	//顺便建立全局根节点

//将operator new 封装到函数中
TreeNode* newnode()	{ return new TreeNode; }

void addnode(int v,char *s){
    TreeNode* cur = root;	//从根节点往下走
    int n = strlen(s);
    for(int i = 0; i < n; ++i){
        if(s[i] == 'L'){
            if(cur->left == nullptr)	cur->left = newnode();	//节点不存在，建立新节点
            cur = cur->left;
        }
        if(s[i] == 'R'){
            if(cur->right == nullptr)	cur->right = newnode();
            cur = cur->right;
        }
        //忽略其他其他情况，既最后那个多余的右括号。同时 如果是根节点 形如（5，) 不做处理，cur == root
    }
    if(cur->val)	flag = true;	//已经赋过值，表名输入有误
    cur->val = v;
}

bool read(){
    flag = false;
    while(true){
    	if(scanf("%s", s) != 1)	return false;
    	//遇到()说明该组数据输入结束  使用strcmp进行字符数组的比较 相同返回0
        if(!strcmp(s,"()"))	break;    
        int v;
        //读入节点值，如"(11，LL)",&s[1]表示"11,LL)"
        sscanf(&s[1],"%d",&v);
        //strchr函数，查找字符串中的字符，返回指向该字符的指针。未找到返回nullptr
        addnode(v,strchr(s,',')+1);
    }
    return true;
}

bool solve(vector<int>& ans){
 	queue<TreeNode*> q;
    q.push(root);
    while(!q.empty()){
        TreeNode* cur = q.front();
        q.pop();
        if(cur->val == 0)	return false;	//有节点没有被赋值，说明输入有误
        ans.push_back(cur->val);
        if(cur->left)	q.push(cur->left);
        if(cur->right)	q.push(cur->right);
    }
    return true;	//输入正确
}

int main(){
    ios::sync_with_stdio(false);
    while(read()){
        vector<int> arr;
     	if(flag || !solve(arr))	{ cout << "not complete" << endl; continue; }
        cout << arr[0];
        for(int i = 1; i < arr.size(); ++i)
            cout << " " << arr[i];
        cout << endl;
    }
    return 0;
}

```

版本二：与链表一样，二叉树不一定要用指针实现

```c++
//数组静态实现
//#include <bits/stdc++.h>
#include <cstdio>
#include <cstring>
#include <vector>
#include <queue>

using namespace std;

const int maxn = 10000 + 10;

char s[maxn];
bool flag;

int left[maxn],right[maxn],val[maxn];

const int root = 1;
int cnt;

int newnode(){
	int u = ++cnt;
	left[u] = right[u] = 0;
	return u;
}
//待优化
void newtree(){
	//left[root] = right[root] = 0;
	//val[root] = 0;
	memset(left,0,sizeof(left));
	memset(right,0,sizeof(right));
	memset(val,0,sizeof(val));
	cnt = root;
}

void addnode(int v,char *s){
	int cur = root;
	int n = strlen(s);
	for(int i = 0; i < n; ++i){
		if(s[i] == 'L'){
			if(left[cur] == 0)	left[cur] = newnode();
			cur =  left[cur];
		}
		if(s[i] == 'R'){

			if(right[cur] == 0)	right[cur] = newnode();
			cur = right[cur];
		}
	}
	if(val[cur])	flag = true;
	val[cur] = v;
}

bool read(){
	flag = false;
	//root = newnode();
	newtree();
	while(true){
		if(scanf("%s", s) != 1)	return false;
		if(!strcmp(s,"()"))	break;
		int v;
		sscanf(&s[1], "%d", &v);
		addnode(v,strchr(s, ',') + 1);
	}
	return true;
}


bool solve(vector<int>& ans){
	queue<int> q;
	q.push(root);
	while(!q.empty()){
		int cur = q.front();
		q.pop();
		if(val[cur] == 0)	return false;
		ans.push_back(val[cur]); 
		if(left[cur])
			q.push(left[cur]);
		if(right[cur])
			q.push(right[cur]);
	}
	return true;
}





int main(){
	//ios::sync_with_stdio(false);
	freopen(".out","w",stdout);
	
	while(read()){
		vector<int> ans;
		if(flag || !solve(ans))	 {  printf("not complete\n") ; continue; } 
		
		printf("%d",ans[0]);
		for(int i = 1; i < (int)ans.size(); ++i)
			printf(" %d",ans[i]);
		printf("\n");

	}
	
	fclose(stdout);
	return 0;
}
```

用指针直接访问比数组+下标的方式略快，因此有的选手喜欢用结构体+指针的方式处理动态数据结构，但在申请结点时仍然用这里的动态化静态的思想，把newnode函数写成：

```c++
TreeNode* newnode(){
    TreeNode* u = &node[++cnt];
    u->left = u->right = nullptr;
    u->val = 0;
    return u;
}

```

其中，node是静态申请的结构体数组。

这些写的坏处在于释放内存很不方便。并且如果反复执行新建节点和删除节点，cnt会一直增加，但是用完的内存却无法重用。在大多数算法竞赛题目中，这不会出问题。但是有一些对内存要求高的题目就会出现问题。

常见的解决方案是写一个简单的内存池。如：

```c++
queue<TreeNode*> freenodes;
TreeNode node[maxn];
void init(){
    for(int i = 0; i < maxn; ++i)	freenodes.push(&node[i]);
}
TreeNode* newnode(){
    TreeNode* u = freenodes.front();
    u->left = u->right = nullptr;	//重新初始化该节点
    u->val = 0;
    freenodes.pop();
    return u;
}
void deletenode(TreeNode* u){
    freenodes.push(u);
}
```



###	3.二叉树的递归遍历

####	1.uva548 树

![image-20230209134511734](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230209134511734.png)

分析：

1. 中序和后序或前序可以构成唯一的一颗二叉树，层序和中序可以构成唯一二叉树。
2. 将二叉树构造出来后遍历一遍即可得到答案

版本一：

```c++
#include <bits/stdc++.h>
using namespace std;

const int maxn = 100000 + 10;
int val[maxn],l[maxn],r[maxn];
vector<int> in,post;

int create(int l1,int r1,int l2,int r2){
	if(l1 > r1)	return 0;	//空树
	int root = post[r2];
	int p = l1;
	while(in[p] != root)	++p;
	int cnt = p - l1;	//左子树节点个数
	l[root] = create(l1,p-1,l2,l2+cnt-1);
	r[root]	= create(p+1,r1,l2+cnt,r2-1);
	return root;
}



int sum,best,ans;
void dfs(int root){
	if(root == 0)	return;	//空节点
	sum += root;
	//cout << "````" << sum << endl;
	if(!l[root] && !r[root]){
		if(sum < best)	{ best = sum; ans = root;}
		else if(sum == best)	{ ans = min(root,ans); }
		//sum -= root;
		//return;	
	}
	dfs(l[root]);
	dfs(r[root]);
	sum -= root;
}
//也可以不用全局sum
void dfs2(int root,int sum){
	if(!root)	return;
	sum += root;
	if(!lch[root] && !rch[root]){
		if(sum < best_sum || (sum == best_sum && root < best))	{best = root; best_sum = sum;}
	}
	dfs(lch[root],sum);
	dfs(rch[root],sum);
}

int main(){
    //读取时用stringstream处理空白符，用ios::sync_with_stdio会出现问题！
	//ios::sync_with_stdio(false);
	freopen(".out","w",stdout);
	string s1,s2;
	while(getline(cin,s1)&&getline(cin,s2)){

		in.clear(); post.clear();
		stringstream ss1(s1),ss2(s2);
		int x;
		while(ss1 >> x)	in.push_back(x);
		while(ss2 >> x)	post.push_back(x);
		create(0,in.size()-1,0,post.size()-1);
		best = 100000000;
		dfs(post.back());
		cout << ans << endl;
	}

	fclose(stdout);
	return 0;
}

```

版本二：在建立二叉树的同时统计答案

```c++
#include <bits/stdc++.h>
using namespace std;

const int maxn = 10000 + 10;
int lch[maxn], rch[maxn];
vector<int> in,post;
//int n;
int best,best_sum,sum;

int create(int l1,int r1,int l2,int r2){
	if(l1 > r1)	return 0;	//空树
	int root = post[r2], p = l1;
	sum += root;
	while(in[p] != root)	++p;
	int cnt = p - l1;	//左子树节点个数
	lch[root]	= create(l1,p-1,l2,l2+cnt-1);
	rch[root]	= create(p+1,r1,l2+cnt,r2-1);
	if(!lch[root] && !rch[root]){
		if(sum < best_sum || (sum == best_sum && root < best))	{ best_sum = sum; best = root; }
	}

	sum -= root;	//回溯
	return root;
}

int main(){
	//ios::sync_with_stdio(false);
	freopen(".out","w",stdout);
	string s1,s2;
	while(getline(cin,s1) && getline(cin,s2)){
		in.clear(); post.clear();
		stringstream ss1(s1),ss2(s2);
		int x;
		while(ss1 >> x) in.push_back(x);
		while(ss2 >> x)	post.push_back(x);
		sum = 0;
		best_sum = 1000000;
		create(0,in.size()-1,0,post.size()-1);
		cout << best << endl;
	}
	fclose(stdout);
	return 0;
}
```

知识点：

1. ios::sync_with_stdio的副作用
2. DFS和回溯
3. 通过中序和后序重新构建出二叉树：根据后序遍历确定根节点，根据根节点通过中序遍历确定左右子树的节点个数，然后不短递归此过程直到空树



####	2.uva839 天平 （好题）

![image-20230209160113612](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230209160113612.png)

![image-20230209160128721](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230209160128721.png)

分析：

1. 需要理解题意，本质是要计算出左子天平和右子天平的重量，再判断力矩是否相等
2. 

```c++
#include <bits/stdc++.h>
using namespace std;
//关键在于这个引用
bool solve(int& w){
    int w1, d1, w2, d2;
    cin >> w1 >> d1 >> w2 >> d2;
    bool b1 = true, b2 = true;
    if(!w1)	solve(w1);	//如果w1 == 0，说明这是一个天平，递归下去
    if(!w2)	solve(w2);
    w = w1 + w2;	//该节点是叶子节点，把更新左右质量，回溯给父节点
    return b1 && b2 && (w1 * d1 == w2 * d2);
}

int main(){
    ios::sync_with_stdio(false);
    int t, w;
    cin >> t;
    while(t--){
        if(solve(w))	cout << "YES";	else	cout << "NO";
        cout << endl;
        if(t)	cout << endl;  
    }
    return 0;
}
```

知识点：

1. 这个递归的手法



####	3.uva699 下落的树叶 (好题)

![image-20230209174002914](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230209174002914.png)

分析：

1. 根据输入构造二叉树
2. 可以变构造边统计答案

```c++
#include <bits/stdc++.h>
using namespace std;
const int maxn = 10000 + 10;
int sum[maxn];

void build(int p){
	int v; cin >> v;
	if(v == -1)	return; //空树
	sum[p] += v;
	build(p-1); build(p+1);
}
bool init(){
	int v; cin >> v;
	if(v == -1)	return false;
	memset(sum,0,sizeof(sum));
	int pos = maxn / 2;
	sum[pos] = v;
	build(pos - 1); build(pos + 1);
	return true;
}
int main(){
	ios::sync_with_stdio(false);
	freopen(".out","w",stdout);
	int k = 0;
	while(init()){
		int p = 0;
		while(sum[p] == 0)	p++;	//找到最左边的叶子节点
		cout << "Case " << ++k << ":" << endl << sum[p++];
		while(sum[p] != 0)	cout << " " << sum[p++];	//避免多余空格；
		cout << endl << endl;
	}
	fclose(stdout);
	return 0;
}

```

知识点：

1. 根据输入递归的构造二叉树



###	4.非二叉树

####	1.uva297 四分树 (好题，提高题)	![image-20230210161414476](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230210161414476.png)

分析：

1. 根据题意，我们肯定能通过给出的先序遍历就能建立整颗树。（'e' 或 ’f‘ 代表是叶子节点)
2. 递归的去创建树，可以边建立边统计

```c++
#include <bits/stdc++.h>
using namespace std;
const int maxn = 1024 + 10;
const int len = 32;
int buf[len][len];
string s;
int cnt;
void draw(int& p,int r,int c,int w){
    char ch = s[p++];
    //	2 1
    //  3 4
    if(ch == 'p'){
        draw(p,r,c+w/2,w/2);
        draw(p,r,c,w/2);
        draw(p,r+w/2,c,w/2);
        draw(p,r+w/2,c+w/2,w/2);
    }else if(ch == 'f'){
     	for(int i = r; i < r + w; ++i)	//染色
            for(int j = c; j < c + w; ++j)
                if(buf[i][j] == 0)	{ buf[i][j] = 1; ++cnt; }
    }  
}

int main(){
    int t; cin >> t;
    while(t--){
        cnt = 0;
        memset(buf,0,sizeof(buf));
     	for(int i = 0; i < 2; ++i){
            cin >> s;
            int p = 0;
            draw(p,0,0,len);
        }
        cout << "There are " << cnt << " black pixels." << endl;
    }
}
```

知识点：

1. 遇到这种正方形，应该想到用二维数组来确定答案
2. 此题的本质是有一个黑白正方形，只不过黑色和白色的信息通过四分树给你
3. 相加的过程就是染色
4. 也可以用指针的方式来做，需要多编写一个合并的过程。且统计答案的时候需要再写一个DFS或BFS



##	4.图

###	1.用DFS求连通块

####	1.uva572 油田

![image-20230211202827750](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230211202827750.png)



分析：

1. 图的常用算法dfs和bfs

版本一 dfs

```c++
#include <bits/stdc++.h>
using namespace std;
vector<vector<int>> arr(110,vector<int>(110));
int r, c;
void dfs(int x,int y){
    if(x < 0 || y < 0 || x >= r || y >= c || arr[x][y] == '*')	continue;
    arr[x][y] = '*';
    for(int i = -1; i <= 1; ++i)
        for(int j = -1; j <= 1; ++j){
            if(i != 0 || j != 0){
                dfs(x+i,y+j);
            }
        }
}
int main(){
    ios::sync_with_stdio(false);
    while(cin >> r >> c){
        if(!r)	break;
        for(int i = 0; i < r; ++i)
            for(int j = 0; j < c; ++j)	cin >> arr[i][j];
        int ans = 0;
        for(int i = 0; i < r; ++i)
            for(int j = 0; j < c; ++j) 
                if(arr[i][j] == '@')	{ dfs(i,j); ++ans; }
        
    }
    return 0;
}
```

版本二bfs

```c++
#include <bits/stdc++.h>
using namespace std;

```





###	2.BFS求最短路(单源不带权)

####	1.uva816 Abbott的复仇 （好题，提高题）

![image-20230214145344215](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230214145344215.png)

分析：

​	1.此题是困难版的迷宫问题

```c++
#include <bits/stdc++.h>
using namespace std;

struct Node{
	int r, c, dir;
	//面朝dir 位于(r,c)
	Node(int r = 0,int c = 0,int dir = 0):r(r),c(c),dir(dir){}
};

//maze:
//	1 2 3
//	2
//	3

const char* dirs = "NESW"; //顺时针 上右下左
const char* turns = "FLR"; //转弯方式 直行 左转 右转


int dir_id(char c) { return strchr(dirs,c) - dirs; }
int turn_id(char c) { return strchr(turns,c) - turns; }

//(-1,0) (0,1) (1,0) (0,-1)	顺时针
const int dr[] = {-1, 0, 1, 0};  
const int dc[] = {0 , 1, 0, -1};

Node walk(const Node& u,int turn){
	int dir = u.dir;	//当前朝向
	if(turn == 1) dir = (dir + 3) % 4;	//左转 逆时针走一步相当于顺时针走三步
	if(turn == 2) dir = (dir + 1) % 4;  //右转 顺时针
	return Node(u.r + dr[dir], u.c + dc[dir], dir);
}

const int maxr = 9, maxc = 9;
int r0, c0, r1, c1, r2, c2;
char dir;  //初始的方向
int has_edge[maxr][maxc][4][3];		//坐标 (r,c)，面朝四种方向，三种转弯方式
int d[maxr][maxc][4];		//初始状态到(r,c,div)的最短路径长度，亦可充当vis数组的作用
Node p[maxr][maxc][4];		//保存状态(r,c,div)在BFS树种的父节点，用于回溯答案
string s;

bool isinside(int r,int c){
	return r >= 1 && r <= 9 && c >= 1 && c <= 9;
}

void print_ans(Node);

void solve(){
	queue<Node> q;
	memset(d,-1,sizeof(d)); //初始化最短长度都为0
	Node u(r1,c1,dir_id(dir));	//真正的起点
	d[u.r][u.c][u.dir] = 0;
	q.push(u);
	while(!q.empty()){
		Node u = q.front(); q.pop();
		if(u.r == r2 && u.c == c2)	{ print_ans(u); return; }
		for(int i = 0; i < 3; ++i){	//三种转弯方式
			Node nxt = walk(u,i);
			if(has_edge[u.r][u.c][u.dir][i] && isinside(nxt.r, nxt.c) && d[nxt.r][nxt.c][nxt.dir] < 0){
				d[nxt.r][nxt.c][nxt.dir] = d[u.r][u.c][u.dir] + 1;
				p[nxt.r][nxt.c][nxt.dir] = u;
				q.push(nxt);
			}
		}
	}

	cout << "  No Solution Possible" << endl;
}

void print_ans(Node u){
	vector<Node> nodes;
	while(true){
		nodes.push_back(u);
		if(d[u.r][u.c][u.dir] == 0)	break;
		u = p[u.r][u.c][u.dir];
	}
	nodes.push_back(Node(r0,c0,dir));

	//cout << s << endl;
	int cnt = 0;
	for(int i = nodes.size() - 1; i >= 0; --i){
		if(cnt % 10 == 0)	cout << " ";	//行末没有空格
		cout <<" " << "(" << nodes[i].r << "," << nodes[i].c << ")";
		if(++cnt % 10 == 0)	cout << endl;
	}
	if(nodes.size() % 10 != 0)	cout << endl;
}

bool read(){
	cin >> s;
	if(s == "END")	return false;
    cout << s << endl;
	memset(has_edge,0,sizeof(has_edge));
	cin >> r0 >> c0 >> dir >> r2 >> c2;
	//确定前进方向  初始 r0,c0 节点不会转弯!
	int dir1 = dir_id(dir);
	r1 = r0 + dr[dir1];
	c1 = c0 + dc[dir1];

	string tmp;
	while(true){
		int nr,nc;
		cin >> nr;
        if(!nr) break;
        cin >> nc;

		while(cin >> tmp && tmp != "*"){
			//位于nr nc, 朝向dir，三种可能允许的转弯
			for(int i = 1; i < (int)tmp.size(); ++i)	has_edge[nr][nc][dir_id(tmp[0])][turn_id(tmp[i])] = 1;
		}
	}
	return true;
}

int main(){
	ios::sync_with_stdio(false);
	freopen(".out","w",stdout);
	while(read()){
		solve();
	}
	fclose(stdout);
	return 0;
}
```



###	3.拓扑排序

####	1.uva10305 给任务排序

![image-20230212215342578](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230212215342578.png)

分析：

1. 拓扑排序：在图论中，由一个有向无环图(DAG)的顶点组成的序列，当且仅当满足下列条件时，称为该图的一个拓扑排序：

   1. 每个顶点出现且只出现一次

      

2. 可以用bfs或者dfs实现

版本一：DFS

```c++
#include <bits/stdc++.h>
using namespace std;

const int maxn = 100 + 10;
int G[maxn][maxn];
int topo[maxn], vis[maxn], n, t, cnt;
bool read(){
	cin >> n >> t;
	if(!n && !t)	return false;
	cnt = n;
	int u, v;  // u -> v
	memset(G,0,sizeof(G));
	while(t--){
		cin >> u >> v;
		G[u-1][v-1] = 1;
	}
	return true;
}
bool dfs(int u){
	vis[u] = -1;
	for(int v = 0; v < n; ++v)if(G[u][v]){
		if(vis[v] < 0)	return false;
		else if(!vis[v] && !dfs(v))	return false;  
	}
	vis[u] = 1; topo[--cnt] = u;
	return true;
}
bool solve(){
	memset(vis,0,sizeof(vis));
	memset(topo,0,sizeof(topo));
	for(int u = 0; u < n; ++u){
		if(!vis[u]){
			if(!dfs(u))	return false;
		}
	}
	return true;	
}
int main(){
	ios::sync_with_stdio(false);
	freopen(".out","w",stdout);
	
	while(read()){
		if(!solve())	cout << "-1";
		else{
			cout << topo[0] + 1;
			for(int i = 1; i < n; ++i)	cout << " " << topo[i] + 1;
		}
		cout << endl;		
	}
	
	fclose(stdout);
	return 0;
}
```

版本二：BFS

```c++
#include <bits/stdc++.h>
using namespace std;
const int maxn = 100 + 10;
int G[maxn][maxn];
int indegree[maxn], topo[maxn], n, k ,t; //BFS需要借助入度数组	此时入度数组可以兼任vis

bool read(){
    cin >> n >> k;
    if(!n && !k)	return false;
    memset(G,0,sizeof(G));
    int u, v;
    while(k--){
        cin >> u >> v;
        if(!G[u][v]){	//避免相同的输入，影响到indegree
            G[u][v] = 1;
            ++indegree[v];
        } 
    }
    return true;
}

bool bfs(){
    queue<int> q;	t = 0;
    for(int u = 1; u <= n; ++u)	if(!indegree[u])
        q.push(u);
    while(!q.empty()){
        int u = q.front();	q.pop();
        topo[t++] = u;
        for(int v = 1; v <= n; ++v)	if(G[u][v] && --indegree[v] == 0)
            q.push(v);       
    }
    return t == n;	//如果有环路，t一定不等于n
}

bool topo_sort(){
    return bfs();
}

int main(){
	ios::sync_with_stdio(false);
	freopen(".out","w",stdout);
	
	while(read()){
		if(!topo_sort())	cout << "-1";
		else{
			cout << topo[0];
			for(int i = 1; i < n; ++i)	cout << " " << topo[i];
		} 
		cout << endl;
	}	
    
	fclose(stdout);
	return 0;
}

```

知识点：

1. 拓扑排序是图的重要应用，需要熟知模板



###	4.欧拉回路

七桥问题，由大数学家欧拉首先提出，并给出了完美的解答

能否从**无向图**中的一个节点出发，每条边恰好只经过一次。这样的路线称为欧拉路径，也可以形象的称为一笔画。

不难发现，在欧拉道路中，进和出是对应的，除了起点和终点外，其他点的进出次数应该相等。换句话说，除了起点和终点，其他点的度数应该是偶数，既：

1. 如果一个**无向图**是连通的，且最多只有两个奇点，则一定存在欧拉路径。（充分条件）
2. 如果有两个奇点，则必须从其中一个奇点出发，另一个奇点终止。
3. 如果奇点不存在，则可以从任意点出发，最后一定会回到该点（称为**欧拉回路**）

用类似的推理方式可以得到**有向图**欧拉路径的结论：

1. 在忽略边的方向后，图必须是连通的	**(为什么要忽略边的方向呢？还不清楚)**
2. 最多只能有两个点的入度不等于出度，而且必须是其中一个点的出度恰好比入度大于1(把它作为起点)，另一个入度比出度大1(把它作为终点)

更专业的说：

1. 如果图G中的一个路径包括每一个边恰好一次，则该路径称为欧拉路径(Euler path)
2. 如果一个回路是欧拉路径，则称为欧拉回路(Euler circuit)
3. 具有欧拉回路的图称为**欧拉图**(简称E图)。具有欧拉路径但不具有欧拉回路的图称为**半欧拉图**



![image-20230213204801049](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230213204801049.png)

```c++
//如果是欧拉路径，则u必须是起点
void euler(int u){
    for(int v = 0; v < n; ++v)	if(G[u][v] && !vis[u][v]){
        vis[u][v] = vis[v][u] = 1;	//无向图
        euler(v);
        cout << u << " " << v << endl;		//输出的结果是逆序的
    }
}
```

####	1.uva10129 单词 （好题，提高题）

![image-20230214151803992](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230214151803992.png)

分析：

1. 根据有向图欧拉路径的判断条件，先判断基图(忽略边方向的无向图)是否连通，再判断图的奇点。
2. 图的连通性可以使用dfs或者**并查集**判断

```c++
#include <bits/stdc++.h>
using namespace std;

const int maxn = 100000 + 10;

int G[30][30]; 
int vis[30];
int indegree[30], outdegree[30], k;

void dfs(int u){
	vis[u] = 1;
	for(int v = 0; v < 26; ++v)	if(G[u][v] && !vis[v])
		dfs(v);
}

bool solve(){
	for(int i = 0; i < 26; ++i)	if(indegree[i] || outdegree[i])
		{ dfs(i); break; }
	for(int i = 0; i < 26; ++i)	if((indegree[i] || outdegree[i]) && !vis[i])	return false;	//底图不连通

	int cntin = 0, cntout = 0;
	for(int i = 0; i < 26; ++i) if(indegree[i] != outdegree[i]){
		if(indegree[i] - outdegree[i] == 1)	++cntin;
		else if(outdegree[i] - indegree[i] == 1)	++cntout;
		else return false;
	}
	if((cntin == 1 && cntout == 1) || (cntin == 0 && cntout == 0))	return true; //有向图欧拉路径的判定条件
	return false;
}


int main(){
	ios::sync_with_stdio(false);
	freopen(".out","w",stdout);
	
	int t; cin >> t;
	while(t--){

		cin >> k;
		string s;
		memset(G,0,sizeof(G));
		memset(vis,0,sizeof(vis));
		memset(indegree,0,sizeof(indegree));
		memset(outdegree,0,sizeof(outdegree));
		for(int i = 0; i < k; ++i){
			cin >> s;
			int a = s.front() - 'a', b = s.back() - 'a';
			G[a][b] = G[b][a] = 1;	//创建底图
			++outdegree[a];	++indegree[b];

		}

		if(solve())	cout << "Ordering is possible.";
		else	cout << "The door cannot be opened.";
		cout << endl;
	}

	fclose(stdout);
	return 0;
}

```



###	5.竞赛题目选讲：

####	2.uva12171 雕塑 (难题，再此之前的最难题，也是道好题)

![image-20230214222544481](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230214222544481.png)

分析：

1. 本题的ticky的地方在于，雕塑中间可能有封闭区域，还可能相互嵌套，直接计算长方体的体积是十分困难的
2. 方向思考，我们可以假设雕塑四周充满空气，我们只需要把空气的体积求出来，用总体减去空气的体积即可
3. 可以用floodfill来统计空气，唯一的不同就是floodfill从二维情形的4个方向增加到了三维情形的6个方向
4. 还有一个大问题：空间占用，坐标为1~500的整数，一共需要500^3个单元，太大了，需要进行离散化：每个维度最多只有2n<=100个不同的坐标，因此可以把500 * 500 * 500的网格离散化成100 * 100 * 100。在floodfill时直接使用离散化后的新坐标，但在统计表面积和体积时则需要使用原始坐标

```c++
//#include <bits/stdc++.h>	用万能头文件的副作用时，在某些编译环境下，会有头文件的定义名和自己定义的名字重复产生二义性从而CE
#include <iostream>
#include <cstring>
#include <queue>
#include <algorithm>
using namespace std;

const int maxn = 50 + 5;
const int maxc = 1000 + 10;


//原始数据
int n, x0[maxn], y0[maxn], z0[maxn], x1[maxn], y1[maxn], z1[maxn];

//floodfill
int dx[] = {1,-1,0,0,0,0};
int dy[] = {0,0,1,-1,0,0};
int dz[] = {0,0,0,0,1,-1};

//离散化
int xs[maxn*2], ys[maxn*2], zs[maxn*2];
int nx, ny, nz;
int vis[maxn*2][maxn*2][maxn*2];

void discretization(int *arr,int &n){
	sort(arr,arr+n);
	n = unique(arr,arr + n) - arr ;	//unqiue返回序列的尾迭代器
}

int ID(int *arr,int n,int x){
	return lower_bound(arr,arr+n,x) - arr;
}


struct Point{
	int x, y, z;
	Point(int x = 0, int y = 0, int z = 0):x(x),y(y),z(z){}
	int volume() { return (xs[x+1]-xs[x]) * (ys[y+1]-ys[y]) * (zs[z+1]-zs[z]); }
	int area(int i){
		if(dx[i] != 0) return (ys[y+1]-ys[y]) * (zs[z+1]-zs[z]);
		else if(dy[i] != 0)	return (xs[x+1]-xs[x]) * (zs[z+1]-zs[z]);
		else	return (xs[x+1]-xs[x]) * (ys[y+1]-ys[y]);
	}
	Point neighbor(int i) { return Point(x+dx[i],y+dy[i],z+dz[i]); }
	bool valid() const { return x >= 0 && y >= 0 && z >= 0 && x < nx - 1 && y < ny - 1 && z < nz - 1; }
	void setVis() const { vis[x][y][z] = 2; }
	bool isVis() const { return vis[x][y][z] == 2; }
	bool solid() const { return vis[x][y][z] == 1; }
};

void floodfill(int &v, int &s){
	v = s = 0;
	queue<Point> q;
	Point a;
	a.setVis();
	q.push(a);
	while(!q.empty()){
		Point cur = q.front(); q.pop();
		v += cur.volume();
		for(int i = 0; i < 6; ++i){
			Point nxt = cur.neighbor(i);
			if(!nxt.valid()) continue;
			if(nxt.solid())	s += nxt.area(i);
			else if(!nxt.isVis()){
				nxt.setVis();
				q.push(nxt);
			}
		}
	}
	v = maxc*maxc*maxc - v;
}

int main(){
	ios::sync_with_stdio(false);
	freopen(".out","w",stdout);
	int t; cin >> t;
	while(t--){
		nx = ny = nz = 2;
		xs[0] = ys[0] = zs[0] = 0;
		xs[1] = ys[1] = zs[1] = maxc;	
		cin >> n;
		for(int i = 0; i < n; ++i){
			cin >> x0[i] >> y0[i] >> z0[i] >> x1[i] >> y1[i] >> z1[i];
			x1[i] += x0[i]; y1[i] += y0[i]; z1[i] += z0[i];
			xs[nx++] = x0[i]; xs[nx++] = x1[i];
			ys[ny++] = y0[i]; ys[ny++] = y1[i];
			zs[nz++] = z0[i]; zs[nz++] = z1[i];
		}

				
		discretization(xs,nx);
		discretization(ys,ny);
		discretization(zs,nz);

		//标记长方体
		memset(vis,0,sizeof(vis));
		for(int i = 0; i < n; ++i){
			int X1 = ID(xs,nx,x0[i]), X2 = ID(xs,nx,x1[i]);		//原始坐标映射到离散化vis的坐标
			int Y1 = ID(ys,ny,y0[i]), Y2 = ID(ys,ny,y1[i]);
			int Z1 = ID(zs,nz,z0[i]), Z2 = ID(zs,nz,z1[i]);
			for(int X = X1; X < X2; ++X)
				for(int Y = Y1; Y < Y2; ++Y)
					for(int Z = Z1; Z < Z2; ++Z)
						vis[X][Y][Z] = 1;
		}
		int v, s;
		floodfill(v,s);
		cout << s << " " << v << endl;
	}	

	fclose(stdout);
	return 0;
}
```



####	3.uva1572 自组合

![image-20230216221932541](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230216221932541.png)

分析：

1. 可以旋转和翻转。
2. 无限大的结构并不一定能铺满整个平面，只需要能连出一条无限长的即可
3. 不需要正方形本身重复，把标号看成点，正方形看作边，得到一个有向图。则当且仅当图中存在有向环时有解。只需要要做一次拓扑排序即可。

```c++
#include <bits/stdc++.h>
using namespace std;

const int maxn = 52 + 10;
int G[maxn][maxn];
int c[maxn];

int ID(char ch1,char ch2){
    return (ch1 - 'a') * 2 + (ch2 == '+' ? 0 : 1);
}

void connect(char a1,char a2,char b1,char b2){
   	if(a1 == '0' || b1 == '0')	return;
    int u = ID(a1,a2) ^ 1, v = ID(b1,b2);	//与1异或 A+ 变 A-
    G[u][v] = 1;
}

bool dfs(int u){
    c[u] = -1;
    for(int v = 0; v < 52; ++v) if(G[u][v]){
        if(c[u] < 0)	return false;
        if(!c[u] && !dfs(v))	return false;
    }
    c[u] = 1; 
    return true;
}

bool topo_sort(){
    for(int u = 0; u < 52; ++u) if(!c[u])
        if(!dfs(u))	return false;
    return true;
}

int main(){
    int n;
    while(cin >> n){
        string s;
        while(n--){
            cin >> s;
            for(int i = 0; i < 4; ++i)
                for(int j = 0; j < 4; ++j) if(i != j)
            		connect(s[2*i],s[2*i+1],s[2*j],s[2*j+1]);  
        }
        if(topo_sort())	cout << "bounded";
		else	cout << "unbounded";
		cout << endl;
    }
}
```

知识点：

1. 判断有向图有没有环，首先想到拓扑排序
2. 用异或来优化代码，这个语法是我想不到的，connect函数值得细细品味
3. 这种把某个东西看成点，某个东西看成边从而构建图的思路我需要记住，此举和uva10129单词这题有相同的思想

####	4.uva1599 理想路径 (难题)

![image-20230217153326283](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230217153326283.png)

分析：

1. 无向图下的单源最短路问题
2. 单源最短路应该想到BFS
3. 关键在于处理颜色的字典序
4. 为什么要反向BFS

![img](https://img-blog.csdnimg.cn/20190218005121398.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0Nhc3NpZV96a3E=,size_16,color_FFFFFF,t_70)

```c++
#include <bits/stdc++.h>
using namespace std;

const int maxn = 100000 + 10;
const int INF = 1000000000;

struct Edge{
	int u, v, c;
	Edge(int u = 0, int v = 0, int c = 0):u(u),v(v),c(c) {}
};

//数据量太大，无法用邻接矩阵来存储图，故使用邻接表来存储
vector<Edge> edges;  //边集
vector<int> G[maxn];  //点集


void add_edge(int u,int v,int c){
	edges.push_back(Edge(u,v,c));
	int idx = edges.size() - 1;
	G[u].push_back(idx);
}

int n, vis[maxn], d[maxn];

//反向BFS，遍历整个图，标记每个节点到终点的距离。实际是为了给第二次BFS缩小范围。
void rbfs(){
	memset(vis,0,sizeof(vis));
	queue<int> q;
	d[n-1] = 0;
	q.push(n-1);
	vis[n-1] = true;

	while(!q.empty()){
		int u = q.front(); q.pop();
		for(int i = 0; i < G[u].size(); ++i){
			int v = edges[G[u][i]].v;
			if(!vis[v]){
				d[v] = d[u] + 1;
				vis[v] = true;
				q.push(v);
			}
		}
	}
}

vector<int> ans;

void bfs(){
	memset(vis,0,sizeof(vis));
	ans.clear();

	vector<int> nxt;
	vis[0] = true;
	nxt.push_back(0);
	for(int i = 0; i < d[0]; ++i){
		int min_color = INF;

		for(int j = 0; j < nxt.size(); ++j){
			int u = nxt[j];
			for(int k = 0; k < G[u].size(); ++k){
				int e = G[u][k];
				int v = edges[e].v;
				if(d[v] == d[u] - 1)	min_color = min(min_color,edges[e].c);
			}
		}

		ans.push_back(min_color);

		vector<int> nxt2;
		for(int j = 0; j < nxt.size(); ++j){
			int u = nxt[j];
			for(int k = 0; k < G[u].size(); ++k){
				int e = G[u][k];
				int v = edges[e].v;
				if(d[v] == d[u] - 1 && edges[e].c == min_color && !vis[v]){
					vis[v] = true;
					nxt2.push_back(v);
				}
			}

		}
		nxt = nxt2;
	}
	//cout << d[n-1] << endl;
	cout << d[0] << endl;
	cout << ans[0];
	for(int i = 1; i < ans.size(); ++i)	cout << " " << ans[i];
	cout << endl;
}

int main(){
	//ios::sync_with_stdio(false);
	//cin.tie(nullptr);
	freopen(".out","w",stdout);
	freopen("uva.in","r",stdin);
	int t, u, v, c;
	while(cin >> n >> t){
		for(int i = 0; i < n; ++i)	G[i].clear();
		edges.clear();
		while(t--){
			cin >> u >> v >> c;
			add_edge(u-1,v-1,c);
			add_edge(v-1,u-1,c);
		}
		rbfs();
		bfs();
	}
	fclose(stdin);
	fclose(stdout);
	return 0;
}
```

####	5.uva11853 战场  （难题）

![image-20230219143440053](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230219143440053.png)

分析：

1. 先简化一下题目；先判断是否有解，再考虑如何求出最靠北的位置
2. 对偶图的经典应用（暂时还不明白对偶图）
3. 如果圆(每个点的攻击范围)从上边界连续到下边界则无解（可以使用dfs判断），否则与左边界相交时的最小的交点(0,y)值是入点，与右边界相交时的最小的交点(1000,y)值是出点（dfs过程中顺带判断）

![image-20230219162131939](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230219162131939.png)

```c++
#include <bits/stdc++.h>
using namespace std;

const int maxn = 1000 + 10;
const double W = 1000.0;

int n;
double x[maxn], y[maxn], r[maxn], Left, Right;
bool flag, vis[maxn];

//判断两个圆是否相交
bool xj(int idx1,int idx2){
	//两个圆心之间的距离小于两个圆的半径之和就是相交，等于时相切
	return sqrt((x[idx1]-x[idx2])*(x[idx1]-x[idx2])+(y[idx1]-y[idx2])*(y[idx1]-y[idx2])) <= r[idx1] + r[idx2];
}

//选择出入点
void check(int u){
	//与左边界相交
	if(x[u] < r[u])	Left = min(Left,y[u]-sqrt(r[u]*r[u]-x[u]*x[u]));
	//与有边界相交
	if(x[u] + r[u] > W) Right = min(Right,y[u]-sqrt(r[u]*r[u]-(W-x[u])*(W-x[u])));
}


bool dfs(int u){
	if(vis[u])	return false;
	vis[u] = true;
	if(y[u] - r[u] < 0)	return true;
	for(int v = 0; v < n; ++v){
		if(xj(u,v) && dfs(v))	return true;
	}
	check(u);
	return false;
}



int main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	freopen(".out","w",stdout);
	while(cin >> n){
		for(int i = 0; i < n; ++i)	cin >> x[i] >> y[i] >> r[i];
		
		Left = Right = W;
		flag = true;
		memset(vis,0,sizeof(vis));
		for(int u = 0; u < n; ++u)	if(!vis[u] && y[u] + r[u] >= W)	flag = !dfs(u);
		if(flag)	cout << fixed << setprecision(2) << 0.00 << " " <<  Left << " " << W << " " << Right << endl;

	}

	fclose(stdout);
	return 0;
}
```



###	6.训练参考

####	1.uva673 平衡的括号

![image-20230219220841790](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230219220841790.png)

分析：

1. [(]) 这样不合法！

```c++
#include <bits/stdc++.h>
using namespace std;

string s;

char rev(char ch){
    if(ch == ')')	return '(';
    return '[';
}


bool solve(){
    if(s.empty())	return true;
    if(s.size() & 0x1)	return false;
    stack<char> stk;
    for(auto ch:s){
        if(ch == ']' || ch == ')'){
      		if(!stk.empty() && stk.top() == rev(ch)) { stk.pop(); continue; }
            else	return false;
        }
        stk.push(ch);
    }
  return stk.empty();
}

int main(){
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    int t; cin >> t;
    cin.ignore(1);	//吃掉回车键
    while(t--){
        getline(cin,s);
        if(solve())	cout << "Yes";
        else	cout << "No";
        cout << endl;
    }
    return 0;
}
```



####	2.uva712 S树

![image-20230219220920189](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230219220920189.png)

分析：

1. 一定要先考虑**性质**，再考虑建树

```c++
#include <bits/stdc++.h>
using namespace std;

int n;
string s;

int main(){
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    int t, k = 0;
    while(cin >> n && n){
        cin.ignore(1);
        getline(cin,s);
        string q, ans;
        while(t--){
            cin >> q;
            int idx = 0;
            for(auto ch:q)	idx = idx * 2 + (ch == '0' ? 1 : 2);
            idx -= (1 << n) - 1;
            ans += s[idx];
        }
        cout << "S-Tree #" << ++k << ":" << endl << ans << endl << endl;
        
    }  
    return 0;
}
```



####	3.uva536 二叉树重建

![image-20230219221004068](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230219221004068.png)

分析：

1. 同样，先分析性质再考虑建树
2. 此题可以在重建时直接输出序列，当然也可以建树再遍历

```c++
#include <bits/stdc++.h>
using namespace std;

string pre_s, in_s;

void solve(int l1,int r1,int l2,int r2){
	if(l1 > r1 || l2 > r2)	return;
	
	int cnt = 0;	// cnt：为子树的节点数
	while(in_s[l2+cnt] != pre_s[l1])	++cnt;
	solve(l1+1,l1+cnt,l2,l2+cnt-1);
	solve(l1+cnt+1,r1,l2+cnt+1,r2);
	cout << pre_s[l1];

}

int main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	freopen(".out","w",stdout);
	
	while(cin >> pre_s >> in_s){
		solve(0,pre_s.size()-1,0,in_s.size()-1);
		cout << endl;
	}
	fclose(stdout);
	return 0;
}
```



####	4.uva439 骑士的移动

![image-20230220183621362](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230220183621362.png)

![image-20230220183633353](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230220183633353.png)

分析：

1. 求最短路问题，优先想到bfs
2. 模板题

```c++
#include <bits/stdc++.h>
using namespace std;

string s, e;

pair<int,int> Start, End;

int d[8][8];
int dx[] = {-2,-1,1,2,2,1,-1,-2};
int dy[] = {1,2,2,1,-1,-2,-2,-1};

bool inside(int r,int c){
	return r >= 0 && c >= 0 && r <= 7 && c <= 7;
}

void bfs(){
	memset(d,0,sizeof(d));
	d[Start.first][Start.second] = 1;
	queue<pair<int,int>> q;
	q.push(Start);
	while(!q.empty()){
		auto u = q.front(); q.pop();
		int r = u.first, c = u.second;
		if(u == End) { cout << "To get from " << s << " to "<< e << " takes " << d[r][c] - 1 << " knight moves." << endl; return; }
		for(int v = 0; v < 8; ++v){
			int nr = r + dx[v], nc = c + dy[v];
			if(inside(nr,nc) && !d[nr][nc]){
				d[nr][nc] = d[r][c] + 1;
				q.push({nr,nc});
			}
		}
	}
}

int main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	freopen(".out","w",stdout);
	
	while(cin >> s >> e){
		//不处理纵(x)坐标也可以
        Start = make_pair(s[0] - 'a', (s[1] - '1') % 8), End = make_pair(e[0] - 'a', (e[1] - '1') % 8);
		bfs();
	}

	
	fclose(stdout);
	return 0;
}
```



####	5.uva1600 巡逻机器人

![image-20230222184611895](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230222184611895.png)

分析：

1. tricky：如果先前也到达过这个位置但是两次连续穿越的障碍数不一样，那么机器人也是可以走到这个位置的
2. 利用三维数组vis来表示不同的穿越障碍次数。



```c++
#include <bits/stdc++.h>
using namespace std;


int r, c, k, ans;

struct Point{
	int x, y, cnt, step;
	Point(int x,int y,int cnt,int step):x(x),y(y),cnt(cnt),step(step) {}
};

const int maxn = 20 + 5;

int tmp[] = {0,1,0,-1,0};
int G[maxn][maxn], vis[maxn][maxn][maxn*maxn];

bool inside(int x,int y){
	return x >= 1 && y >= 1 && x <= r && y <= c;
}

void bfs(){
	memset(vis,0,sizeof(vis));
	queue<Point> q;
	q.push(Point(1,1,0,0));
	while(!q.empty()){
		auto cur = q.front(); q.pop();
		if(cur.x == r && cur.y == c) { ans = cur.step; return; }
		vis[cur.x][cur.y][cur.cnt] = 1;
		for(int i = 1; i < 5; ++i){
			int nx = cur.x + tmp[i-1], ny = cur.y + tmp[i];
			if(inside(nx,ny)){
				if(G[nx][ny] && !vis[nx][ny][cur.cnt+1] && cur.cnt+1 <= k)	//不超过最大次数
					q.push(Point(nx,ny,cur.cnt+1,cur.step+1));
				else if(!G[nx][ny] && !vis[nx][ny][0])	//当前没有障碍
					q.push(Point(nx,ny,0,cur.step+1));		//cnt要清空，没有连续穿越了

			}
		}
	}
}

void solve(){
	ans = -1;
	bfs();
	cout << ans << endl;
}

int main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	freopen(".out","w",stdout);
	
	int t; cin >> t;
	while(t--){
		cin >> r >> c >> k;
		for(int i = 1; i <= r; ++i)
			for(int j = 1; j <= c; ++j)	cin >> G[i][j];
		solve();
	}	
	
	fclose(stdout);
	return 0;
}
```

####	6.uva12166 修改天平 （难）

![image-20230222214153228](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230222214153228.png)

分析：

1. 这一层的重量和上一层有什么关系？

2. 设一个节点深度为n，自身重量为x，如果节点平衡，则以当前节点为根的子树的总重量为：

   `x*2^n`

   ![image-20230222214455722](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230222214455722.png)

```c++
//#include <bits/stdc++.h>
#include <unordered_map>
#include <iostream>
#include <algorithm>

using namespace std;

int cnt, depth;
unordered_map<long long,int> has;
string s;

void solve(){
	has.clear();
	cnt = depth = 0;
	for(int i = 0; i < (int)s.size(); ++i){
		if(s[i] == '[')	{ ++depth; continue; }
		else if(s[i] == ']')	{ --depth; continue; }
		else if(isdigit(s[i])){
			long long val = s[i] - '0';
			while(isdigit(s[++i]))	val = val * 10 + s[i] - '0';
			long long w = val << depth;
			--i;
			++has[w];
			++cnt;
		}
	}

	auto k = max_element(has.begin(),has.end(),[](pair<long long,int> a,pair<long long,int> b){ return a.second < b.second; });
	cout << cnt - k->second << endl;
}

int main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	freopen(".out","w",stdout);
	freopen(".in","r",stdin);
	int t; cin >> t;
	while(t--){
		cin >> s;
		solve();
	}
	fclose(stdin);
	fclose(stdout);
	return 0;
}
```

####	11.uva10410 树重建

![image-20230222224411063](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230222224411063.png)

分析：

1. 由于DFS遍历位序前一位的节点是父节点或者兄弟节点。所以我们主要用dfs重建数，bfs为辅助。
2. DFS位序前一位的节点，在BFS中的位序绝对比当前节点要小。
3. 如果DFS位序前一位的节点是兄弟节点，那么它们在BFS的位序相差为1，前一位的值要小于当前的。（题意给出从小到大遍历）
4. 综上所述，我们需要判断节点的值和节点的位序，还要一个保存父节点的数组（根据下标保存。主要是兄弟节点公用一个父节点，当我们判断到一个兄弟节点时，当前节点的父节点一定和兄弟节点一样，此时直接使用父节点数组即可），以及一个答案vector，所以我们可以存储DFS的值，BFS的遍历位序，然后在DFS从后往前遍历，存储每一个节点的父节点，并更新答案vector

```c++
#include <bits/stdc++.h>
using namespace std;

const int maxn = 1000 + 10;
int n, depth, dfs[maxn], bfs[maxn], father[maxn];
vector<int> ans[maxn];

void solve(){
	father[dfs[2]] = dfs[1];
	ans[dfs[1]].push_back(dfs[2]);
	int pre;
	for(int i = 3; i <= n; ++i){
		pre = i - 1;
		while(bfs[dfs[pre]] + 1 > bfs[dfs[i]]) --pre;	
		if(bfs[dfs[pre]] + 1 == bfs[dfs[i]] && dfs[pre] < dfs[i]){	//兄弟
			father[dfs[i]] = father[dfs[pre]];
			ans[father[dfs[i]]].push_back(dfs[i]);
		}else{														//父节点
			father[dfs[i]] = dfs[pre];
			ans[dfs[pre]].push_back(dfs[i]);

		}
	}

	for(int i = 1; i <= n; ++i){
		cout << i << ":";
		for(int j = 0; j < ans[i].size(); ++j)
			cout << " " << ans[i][j];
		cout << endl;
	}
}
int main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	freopen(".out","w",stdout);
	
	while(cin >> n){
		int a;
		for(int i = 1; i <= n; ++i)	{ cin >> a; bfs[a] = i; }	//存储的是序号
		for(int i = 1; i <= n; ++i)	{ cin >> dfs[i]; ans[i].clear(); }
		solve();
	}
	fclose(stdout);
	return 0;
}
```

知识点：

1. DFS，BFS遍历树的特点
2. 归纳总结的能力

####	14.uva12118 检查员的难题

![image-20230223101951915](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230223101951915.png)

分析：

1. 根据题意，要找一条最短的道路，常用的方法是BFS或者是构造欧拉路径。
2. 无向图欧拉路径的条件是，恰好只有两个度数是奇数的点，且连通的。
3. 我们可以统计每个连通块的度数是奇数的点，最后减去2(欧拉路径恰好只有两个度数是奇数)。一条边可以抵消两个奇数点，所以最后需要添加的边数是 （cnt - 2) / 2。
4. 细节：
   1. 可能会出现，要求的边恰好组成了**欧拉回路（度数全为偶数）**，所以要max(dfs(i),2)。(因为后面要减2除2)
   2. 要求走过的边数可以是0，所有最后要和0去max

```C++
#include <bits/stdc++.h>
using namespace std;

const int maxn = 1000 + 10;

vector<int> G[maxn];
bool vis[maxn];
int n, e, t, k, add, ans;


int dfs(int u){
	if(vis[u])	return 0;
	vis[u] = 1;
	int ans = (G[u].size() & 0x1);
	for(int i = 0; i < (int)G[u].size(); ++i)
		ans += dfs(G[u][i]);
	return ans;
}



void solve(){
	add = 0;
	memset(vis,0,sizeof(vis));
	for(int i = 1; i <= n; ++i){
		if(!G[i].empty() && !vis[i])
			add += max(dfs(i),2);
	}
	ans = max((add-2)/2,0) + e;
	cout << "Case " << ++k << ": " << t * ans << endl; 
}



int main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	freopen(".out","w",stdout);
	freopen(".in","r",stdin);
	k = 0;
	while(cin >> n >> e >> t){
		if(!n && !e && !t)	break;
		for(int i = 1; i <= n; ++i)	G[i].clear();
		int u, v;
		for(int i = 0; i < e; ++i){
			cin >> u >> v;
			G[u].push_back(v);
			G[v].push_back(u);
		}
		solve();
	}

	fclose(stdin);
	fclose(stdout);
	return 0;
}
```

知识点：

1. 构造欧拉路径







#	第七章 暴力求解法



##	1.简单枚举



**既是是用暴力求解，对问题进行一定的分析往往会让算法更简洁搞高效*

####	1.uva725 除法

![image-20230223200452003](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230223200452003.png)

分析：

1. 不用枚举每一个数。只需要枚举分子或者分母

```c++

```



####	2.uva11059 最大乘积

![image-20230223200631505](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230223200631505.png)

分析：

1. 连续子序列，即连续区间，枚举起点和终点即可

```c++
#include <bits/stdc++.h>
using namespace std;

int n, arr[20];
long long ans;

void solve(){
	ans = -1;
	for(int i = 0; i < n; ++i){
		for(int j = i; j < n; ++j){
			long long cur = 1;
			for(int l = i, r = j; l <= r; ++l)
				cur *= arr[l];
			ans = max(cur,ans);
		}
	}
	if(ans < 0)	ans = 0;
}

int main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	freopen(".out","w",stdout);
	int k = 0;
	while(cin >> n){
		for(int i = 0; i < n; ++i)	cin >> arr[i];
		solve();
		cout << "Case #" << ++k << ": The maximum product is " << ans << ".\n";
		cout << endl;
	}
	fclose(stdout);
	return 0;
}
```





####	3.uva10976 分数拆分

![image-20230223214308348](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230223214308348.png)

分析：

1. 根据式子和x的范围可以变形，得到不等式从而缩小枚举范围

```c++
#include <bits/stdc++.h>
using namespace std;

// k <= 10000

//必有一个解
int k, x, y;

vector<pair<int,int>> ans;

void solve(){
	ans.clear();
	y = k + 1;
	while(y <= 2 * k){
		if(!(y*k % (y-k)))
			ans.push_back({y*k/(y-k),y});
		++y;
	}
}
int main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	freopen(".out","w",stdout);
	freopen(".in","r",stdin);
	while(cin >> k){
		solve();
		cout << ans.size() << endl;
		for(auto& p:ans)
			cout << 1 << "/" << k << " = " << 1 << "/" << p.first << " + " << 1 << "/" << p.second << endl;
	}		


	fclose(stdin);
	fclose(stdout);
	return 0;
}
```



##	2.枚举排列



###	1.枚举不重集的排列

给定一个不包含重复元素的序列 ，***按任意顺序*** 返回所有的全排列。



模板：

```c++
int n;
string s;				//枚举的集合
vector<string> ans;		
void solve(vector<bool>& vis,string& arr,int cnt){
	if(cnt == n){
		ans.push_back(arr);
		return;
	}
	for(int i = 0; i < n; ++i) if(!vis[i]){
		vis[i] = true;
		arr.push_back(s[i]);
		solve(vis,arr,cnt+1);
		arr.pop_back();		//回溯 backtrack
		vis[i] = false;
	}
}
```



###	2.枚举可重集的排列

给定一个可包***含重复元素***的序列 ，***按任意顺序*** 返回所有***不重复***的全排列。

模板：

```c++
// 核心在于: i > 0 && arr[i] == arr[i-1] && !vis[i-1]
vector<vector<int>> ans;
int n;
void solve(vector<int>& arr,vector<int>& tmp,vector<bool>& vis,int cnt){
    if(cnt == n){
        ans.push_back(tmp);
        return;
    }
    for(int i = 0; i < n; ++i) if(!vis[i]){
        if(i > 0 && arr[i] == arr[i-1] && !vis[i-1]) continue;
        vis[i] = true;
        tmp.push_back(arr[i]);
        solve(arr,tmp,vis,cnt+1);
        vis[i] = false;
        tmp.pop_back();
    }
}
```





###	3.下一个排列

​	枚举所有排列的另一个方法是从字典序最小的排列开始，不停调用求下一个排列的过程。如何求下一个排列呢?

​	C++ STL algorithm中提供了一个库函数`next permutation`

```c++
void solve(){
	sort(s.begin(),s.end());
	do{
		ans.push_back(s);
	}
	while(next_permutation(s.begin(),s.end()));
}
```



##	3.枚举子集



###	1.二进制法

枚举0到n-1的子集，使用n位二进制数，第`k`位为1说明子集有k。

```c++
void solve(int n){						// 0到n-1个状态
    for(int i = 0; i < (1<<n); ++i){
        //对每个子集的处理
    }
}
```



```c++
void print_subset(int n,int s){			//输出子集
    for(int i = 0; i < n; ++i)
        if(s & (1 << i))	cout << i << " ";
    cout << endl;
}

void sole(int n){
    for(int i = 0; i < (1<<n); ++i)
        print_subset(n,i);
}
```



##	4.回溯法

​	无论是排列生成还是子集枚举，都是两个思路：递归构造和直接枚举。

**递归构造中，生成和检查过程可以有机结合起来，从而减少不必要的枚举，即回溯法（backtracking）**

​	回溯法的应用范围很广，只要能把待求解的问题分成不太多的步骤，每个步骤又只有不太多的选择，都可以考虑回溯法。如果太多，解答树的节点数会是天文数字

####	1.八皇后问题



```c++
int n, ans;
bool vis[3][1000];

void solve(int cur){
	if(cur == n)	++ans;
	for(int i = 0; i < n; ++i) if(!vis[0][i] && !vis[1][cur+i] && !vis[2][cur-i+n]){
		vis[0][i] = vis[1][cur+i] = vis[2][cur-i+n] = true;
		solve(cur+1);
		vis[0][i] = vis[1][cur+i] = vis[2][cur-i+n] = false;
	}
}
```



####	2.uva524 素数环

![image-20230226211123449](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230226211123449.png)

分析：

1. 符合回溯法两个不太多的要求



```c++
#include <bits/stdc++.h>
using namespace std;

int n, arr[20];
bool vis[20];

bool is_prime(int n){
	if(n <= 1)	return false;
	int m = floor(sqrt(n) + 0.5);
	for(int i = 2; i <= m; ++i)
		if(n % i == 0)	return false;
	return true;
}

void solve(int cur){
	if(cur == n && is_prime(arr[0]+arr[n-1])){
		cout << 1;
		for(int i = 1; i < n; ++i)	cout << ' ' << arr[i];
		cout << endl;
	}
	for(int i = 2; i <= n; ++i) if(!vis[i] && is_prime(i + arr[cur-1])){
		arr[cur] = i;
		vis[i] = true;
		solve(cur+1);
		vis[i] = false;
	}
}


int main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	freopen(".out","w",stdout);
	
	int k = 0;
	while(cin >> n){
		if(k)	cout << endl;
		cout << "Case " << ++k << ":" << endl;
		memset(arr,0,sizeof(0));
		arr[0] = 1;
		solve(1);
	}
	
	fclose(stdout);
	return 0;
}
```

知识点：

1. 如果最坏情况下枚举量很大，应该使用回溯法而不是生成-测试法



####	3.uva129 困难的串

![image-20230226220418809](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230226220418809.png)

分析：

1. 使用回溯法，考虑提早退出（剪枝）避免递归次数过多导致栈溢出



```c++
#include <bits/stdc++.h>
using namespace std;

int s[100];
int L, n, cnt;

bool check(int n){
	bool flag = true;
	for(int i = 1; i <= (n + 1) >> 1; ++i){
		flag = false;
		for(int j = 0; j < i; ++j)
			if(s[n-j] != s[n-j-i])	{ flag = true; break; }
		if(!flag)	  break; 
	}

	return flag;
}

int solve(int cur){
	if(cnt++ == n){
		for(int i = 0; i < cur; ++i){
			if(i % 64 == 0 && i > 0) cout << endl;
			else if(i % 4 == 0 && i > 0)	cout << " ";
			char ch = 'A' + s[i];
			cout << ch;
		}
		cout << endl;
		cout << cur << endl;

		return 0;
	}

	for(int i = 0; i < L; ++i){
		s[cur] = i;
		if(check(cur))	if(!solve(cur+1))	return 0;
	}
	return 1;
}

int main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	freopen(".out","w",stdout);
	
	while(cin >> n >> L && n && L){
		cnt = 0;
		solve(0);
	}

	
	fclose(stdout);
	return 0;
}
```







####	4.uva140 带宽

![image-20230304223245000](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230304223245000.png)

分析：

1. 可以记录目前已经找的最小带宽k，如果发现已经有两个节点的距离大于或等于k，再怎么扩展也不可能比当前解更优，应该剪枝





```c++
#include <bits/stdc++.h>
using namespace std;

const int maxn = 10;

string s;
int G[maxn][maxn], vis[maxn], n, k;

// id: 
int id[256], letter[maxn], ans;

bool read(){
	n = 0;
	cin >> s;
	if(s == "#")	return false;
	for(char  ch = 'A'; ch <= 'Z'; ++ch){
		if(s.find(ch) != string::npos){
			id[ch] = n++;
			letter[id[ch]] = ch;
 		}
	}
	memset(G,0,sizeof(G));
	
	for(int i = 0; i < (int)s.size(); ++i){
		char u = s[i++];
		while(i + 1 < s.size() && s[++i] != ';'){
 			G[id[s[i]]][id[u]] = G[id[u]][id[s[i]]] = 1;
		}
	}

	return true;
}


void solve(){
	int P[maxn], pos[maxn], bestP[maxn];
	ans = n;
	for(int i = 0; i < n; ++i)	P[i] = i;
	//cout << n << endl;

	do{
		memset(vis,0,sizeof(vis));
		for(int i = 0; i < n; ++i)	pos[P[i]] = i;

		int bw = 0;
		
		for(int u = 0; u < n; ++u)
			for(int v = 0; v < n; ++v) if(G[u][v]){
				bw = max(bw,abs(pos[u]-pos[v]));
		
			}
        //剪枝
		if(bw < ans){
			ans = bw;
			memcpy(bestP,P,sizeof(P));
		}

	}while(next_permutation(P,P+n));

	for(int i = 0; i < n; ++i){
		char ch = letter[bestP[i]];
		cout << ch << ' ';
	}
	cout << "-> " << ans << endl;

}



int main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	freopen(".out","w",stdout);
	
	while(read()){
		solve();

	}
	fclose(stdout);
	return 0;
}
```

知识点：

​	在求最优解的问题中，应尽量考虑最优性剪枝；这往往需要记录当前最优解，并想办法预测一下从当前节点除法是否可以扩展到更好的方案。

​	具体来说；先计算一下最理想情况可以得到怎样的解，如果连理想情况都无法得到比当前最优解更好的方案，则剪枝



##	5.路径寻找问题

​	**路径寻找问题通常归结为图的问题，也可以说时隐式图；以状态为节点，状态的转移为边。**

和回溯法不同；回溯法一般是找到一个（或者所有）满足约束的解（或者某种意义下的最优解），而状态空间搜索一般是要找到一个从初始状态到终止状态的**路径**



####	1.八数码问题

![image-20230304224643942](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230304224643942.png)

分析：

1. 以状态为节点，状态的转移为边，则此题变为求最短路
2. 求无权单源最短路问题，应该首先想到BFS
3. 状态量很大，应该想办法去除重复的状态
4. 双向BFS会大大的提高速度；从起点和终点同时bfs，当两者出现相交的状态时为最短路。



```c++
#include <bits/stdc++.h>
using namespace std;

int target = 123804765, start;
int arr[9], tmp[] = {0,1,0,-1,0}, ans;


void bfs(queue<int>& q,unordered_map<int,int>& ha,unordered_map<int,int>& hb){

	int pre = q.front(); q.pop();
	int z, n = pre;
	for(int i = 8; i >= 0; --i){
		arr[i] = n % 10;
		n /= 10;
		if(!arr[i]) z = i;
	}
	int zx = z / 3, zy = z % 3;
	for(int i = 1; i < 5; ++i){
		int nx = zx + tmp[i-1], ny = zy + tmp[i];
		if(nx >= 0 && ny >= 0 && nx < 3 && ny < 3){
			swap(arr[z],arr[nx*3+ny]);
			int cur = 0;
			for(int i = 0; i < 9; ++i)	cur = cur * 10 + arr[i];
			if(hb.count(cur)){
				ans = ha[pre] + hb[cur] + 1;
				return;
			}
			if(!ha.count(cur)){
				q.push(cur);
				ha[cur] = ha[pre] + 1;
			}
			swap(arr[z],arr[nx*3+ny]);
		}

	}

}

void solve(){
	if(start == target)	{ cout << 0 << endl; return; }
	queue<int> qa, qb;
	unordered_map<int,int> ha, hb;
	ha[start] = hb[target] = 0;
	qa.push(start);	qb.push(target);
	ans = 0;
	while(!qa.empty() && !qb.empty()){
		if(ans > 0)	break;
		if(qa.size() <= qb.size())	bfs(qa,ha,hb);
		else	bfs(qb,hb,ha);
	
	}
	cout << ans << endl;
}

int main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	freopen("1.out","w",stdout);
	cin >> start;
	solve();
	fclose(stdout);
	return 0;
}
```



##	6.迭代加深搜索













#	第八章 高效算法设计



##	1.算法分析初步

> **最大连续和问题**

![image-20230306172700437](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230306172700437.png)

	####	1.渐进时间复杂度

​		暴力做法：枚举每一个连续子序列的起点和终点。

```c++
int ans = arr[0];
for(int i = 0; i < n; ++i)
    for(int j = i; j < n; ++j){
        int sum = 0;
        for(int k = i; k <= j; ++k)	sum += arr[k];
        if(sum > ans)	ans = sum;
    }
```

​	时间复杂度n^3



####	2.上界分析

​		稍作优化：使用前缀和，可以在o1的时间取得任意区间的的连续和

```c++
// 方便处理边界问题，下标从1开始
s[0] = 0;
for(int i = 1; i <= n; ++i)	s[i] = s[i-1] + arr[i];
int ans = arr[1];
for(int i = 1; i <= n; ++i)
    for(int j = i; j <= n; ++j)
        ans = max(ans,s[j]-s[i-1]);

```

​	时间复杂度n^2



####	3.分治法

分治法一般分三个步骤：

- 划分问题：把问题的实例分成子问题
- 递归求解：递归求解子问题
- 合并问题：合并子问题的解得到原问题的解

![image-20230306183652721](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230306183652721.png)

```c++
int solve(int l,int r){	//[l,r]
    if(l >= r)	return arr[l];
    int m = l + r >> 1;
    int maxs = max(solve(l,m),solve(m+1,r));
    int L = arr[m], R = arr[m+1], sum = 0;
    for(int i = m; i >= 0; --i)	L = max(L,sum += arr[i]);
    sum = 0;
    for(int i = m+1; i < n; ++i) R = max(R,sum += arr[i]);
    return max(maxs,sum);
}	
    
```





##	2.再谈排序和检索

####		

####		1.归并排序

- 划分问题
- 递归求解
- 合并问题

版本一

```c++
int tmp[maxn];
void merge_sort(int *arr,int l,int r){		// [l,r]
    if(l >= r)	return;
    int m = l + r >> 1;
    merge_sort(arr,l,m);	merge_sort(arr,m+1,r);
    int i = l, j = m + 1, k = 0;
    while(i <= m && j <= r){
        if(arr[i] <= arr[j])	tmp[k++] = arr[i++];
        else	tmp[k++] = arr[j++];            
    }
	while(i <= m)	tmp[k++] = arr[i++];
    while(j <= r)	tmp[k++] = arr[j++];
    
    for(i = l, k = 0; i <= right; ++i,++k)	arr[i] = tmp[k];
        
}
```



版本二

```c++
int tmp[maxn];
void merge_sort(int *arr,int l,int r){
    if(l >= r)	return;
    int m = l + r >> 1;
    merge_sort(arr,l,m); merge_sort(arr,m+1,r);
    int i = l, j = m + 1, k = l;
    while(i <= m || j <= r){
        if(j > r || (i <= m && arr[i] < arr[j]))	tmp[k++] = arr[i++];
        else	{ tmp[k++] = arr[j++]; }
    }
    
    for(i = l; i <= r; ++i)	arr[i] = tmp[i];
    
}
```



经典问题：求逆序对

![image-20230306211523727](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230306211523727.png)

分析：只需要在归并排序中加一行代码即可：

```c++
class Solution {
public:
    int tmp[50010];
    int merge(vector<int>& arr,int l,int r){
        if(l >= r)  return 0;
        int m = (l + r) >> 1;
        int lcnt = merge(arr,l,m), rcnt = merge(arr,m+1,r);
        
        int i = l, j = m + 1, k = 0, cnt = 0;
        while(i <= m || j <= r){
            if(j > r || (i <= m && arr[i] <= arr[j]))   tmp[k++] = arr[i++];
            else{
                tmp[k++] = arr[j++];
                cnt += m - i + 1;
            }
        }
        for(i = l, k = 0; i <= r; ++i,++k)  arr[i] = tmp[k];
        return lcnt + rcnt + cnt;
    }

    int reversePairs(vector<int>& nums) {
        return merge(nums,0,nums.size()-1);
    }
};
```



