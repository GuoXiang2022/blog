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

##	1. 二进制 -> 十进制

```c++
int solve(string s){
    int ans = 0;
    for(int i = 0; i < s.size(); ++i){
        ans *= 2;
        ans += s[i] - '0';
    }
    return ans;
}
```

```c++
int solve(string s){
    int ans = 0;
    for(char ch:s){
        ans = ans * 2 + ch - '0';
    }
    return ans;
}
```


##	2. 快速幂


**快速幂 时间复杂度位logn 优于暴力的n**

```c++
long long  binpow(int x,int n){
    long long res = 1;
    while(n){
        if(n & 0x1)	res *= x;
        x *= x;
        n >>= 1;
    }
    return res;
}
```

```c++
long long rbinpow(int x,int n){
    if(n == 0)	return 1;
    long long res = rbinpow(x,n>>1);
    if(n & 0x1)
        return res * res * x;
    else
        return res * res;
}
```

##	3. 循环(环状)数组的双向行走

```c++
// d = 1 (逆时针)，-1（顺时针)
// n = 数组长度
// 数组的坐标从 1 ~ n
p = (p + n + d - 1) % n + 1;

注意: p % n == (p + n) % n
```

##	4. 二分模板

```c++
//yxc模板
//[l,mid] and [mid + 1,r]
int binsearch(int *arr,int n,int k){
    int l = 0, r= n - 1;
    while(l < n){
        int mid = l + r >> 1;
        if(check(mid))
     		l = mid + 1;
        else
            r = mid;
    }    
}

//[l,mid - 1] and [mid,r]
int binsearch(int *arr,int n,int k){
    int l = 0, r = n - 1;
    while(l < n){
        int mid = l + r + 1 >> 1;
        if(check(mid))
            l = mid;
        else
            r = mid - 1;  
    }
}
//0x3f
//循环不变量
int binsearch(int *arr,int n,int k){
    int l = 0, r = n - 1;
    while(l <= r){
        int mid = l + r >> 1;
        if(arr[mid] < k)
            l = mid + 1;
        else
            r = mid - 1;
    }
    //循环不变量	: arr[l - 1]始终小于k , arr[r + 1]始终大于等于k
    //结束while循环时，r < l, r + 1 == l;根据循环不变量 返回 l 即可;(注意，无解时l == n)
    return l;
}
```





##	5.向上取整（整数）

c++中，默认向下取整，如果想要向上取整，可以：

```c++
int x = 5, k = 2;
int ans = x / k;   //ans = 2
int ans = (x + k - 1) / k;	//ans = 3
或者
int ans = (x - 1) / k + 1;	// ans = 3

//综上所述，可以解释 二分模板 中的 如果 l = mid, 需要 mid = l + r + 1 >> 1 避免死循环的原因
```



##	6.大整数计算

####	前置处理

1. 用数组存储大数的每一位。
2. 由于数组尾部添加方便，所以数组的头部保存大数的个位，尾部保存大数的最高位（即相反）
3. 用字符串读入输入的大数
4. 所有输入的大数都是非负的（负数也不难处理，因为全部都能转换为绝对值加减）

```c++
#include <bits/stdc++.h>
using namespace std;

void solve(){
    string s1,s2;
    cin >> s1 >> s2;
    vector<int> a,b;
    //倒置
    for(int i = s1.size() - 1; i >= 0; --i)	a.push_back(s1[i] - '0');
    for(int i = s2.size() - 1; i >= 0; --i)	b.push_back(s2[i] - '0');
    
    vector<int> c;
    // c = bigadd(a,b)
    // c = bigsub(a,b)
    
    //反过来输出正常结果
    for(int i = c.size() - 1; i >= 0; --i)	cout << c[i];
    
    return 0;
}

```



###	1.加法

```c++
vector<int> bigadd(vector<int>& a,vector<int>& b){
    //保证a.size() >= b.size()
  	if(a.size() < b.size())	return bigadd(b,a);
    
    vector<int>	res;
    int t = 0;
    for(int i = 0; i < a.size(); ++i){
        t += a[i];
        if(i < b.size())	t += b[i];
        res.push_back(t % 10);
        t /= 10;
    }
   	if(t)	res.push_back(1);
    return res;
}
```



###	2.减法

```c++
// is a >= b ?
bool cmpv(vector<int>& a,vector<int>& b){
    if(a.size() != b.size())	return a.size() > b.size();
    for(int i = a.size() - 1; i >= 0; --i)
        if(a[i] != b[i])	return a[i] > b[i];
    return true;    
}
//if(cmpv(a,b))	c = bigsub(a,b);
//else	{ c = bigsub(b,a); cout << '-';}
// a >= b	c = a - b	c >= 0
// a < b	c = -(b - a)	只需要在输出结果时加个符号即可
```

```c++
//通过cmpv()	我们可以保证 a >= b
vector<int> bigsub(vector<int>& a,vector<int>& b){
    vector<int> res;
    for(int i = 0, t = 0; i < a.size(); ++i){
        t = a[i] - t;
        if(i < b.size())	t -= b[i];	// x % n == (x + n) % n  处理了负数情况
        res.push_back((t + 10) % 10);
        t = t < 0 ? 1 : 0;
    }
    //去除前导零
    while(res.size() > 1 && res.back() == 0)	res.pop_back();
    return res;
}
```



###	3.乘法

```c++
vector<int> bigmul(vector<int>& a,int b){
    vector<int> res;
    for(int i = 0,t = 0; i < a.size() || t; ++i){
        if(i < a.size())	t += a[i] * b;
        res.push_back(t % 10);
        t /= 10;
    }
    return res;
}
```



###	4.除法

```c++
// r为余数
vector<int> bigdiv(vector<int>& a,int b,int& r){
    vector<int> res;
    r = 0;
    for(int i = a.size() - 1; i >= 0; --i){
        r = r * 10 + a[i];
        res.push_back(r / 10);
        r %= 10;
    }
    reverse(res.begin(),res.end());
    while(res.size() > 1 && res.back() == 0)	res.pop_back();
    return res;
}
```



##	7. 前缀和

1. 一维前缀和

   前缀和数组下标从1开始，s[0] = 0（减少特判）

   ```c++
   //预处理前缀和数组
   for(int i = 1; i <= n; ++i)
     	s[i] = arr[i] + s[i-1];
   ```

   

2. 二维前缀和

   容斥原理

   ![image-20230313232741116](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230313232741116.png)

   ```c++
   //预处理
   //s[i,j] = s[i-1][j] + s[i][j-1] + arr[i][j];
   for(int i = 1; i <= m; ++i)
       for(int j = 1; j <= n; ++j)
           s[i][j] = s[i-1][j] + s[i][j-1] + arr[i][j];
   
   //求子矩阵和
   // S = s[x2,y2] - s[x2,y1-1] - s[x1-1,y2] + s[x1-1][y1-1];
   ```

   


​		



##	8. 出栈顺序是否合法

​	已知入栈序列为`1，2，3，····n`，问是否能得到出栈序列`Target1，Target2,Target3····Targetn`（每个元素只进栈一次）

​	分析：令`A`表示下一个进栈元素，`TargetB`表示下一个期望元素

​				对于每一个`A`，有：

   											1.	`A` = `TargetB`，显然A进栈后立刻出栈，`A++`，`B++`；
   											2.	栈非空且`stk.top() == TargetB`,`stk.pop()`，`B++`;
   											3.	`A<=n`,说明还有输入，但期望的元素并不是它也不是栈顶元素，所以只能入栈（没有其他方案）;
   											4.	以上情况均不满足，说明所有输入已经全部入栈，栈中还有元素但并不是期望元素，一定无解

```c++
#include <bits/stdc++.h>
using namespace std;
const int maxn = 1010;
bool solve(){
    int target[maxn], n;
    cin >> n;
    for(int i = 1; i <= n; ++i)	cin >> target[i];
    
    stack<int> stk;
    int A = 1, B = 1;
    while(B <= n){
        if(A == target[B])	{++A,++B;}
        else if(!stk.empty() && stk.top() == target[B])	{stk.pop();++B;}
        else if(A <= n)	stk.push(A++);
        else	return false;
    }
	return true;    
}
```



##	9.数组模拟链表

可以先看看紫书的p144	uva11988 BeijuText

```c++
#include <bits/stdc++.h>
using namespace std;
const int maxn = 100000 + 10;
int cur, last, next[maxn];
char s[maxn];

int main(){
    ios::sync_with_stdio(false);
    while(scanf("%s", s + 1) == 1){
        int n = strlen(s + 1);
        cur = last = 0;
       	next[0] = 0;
        for(int i = 1; i <= n; ++i){
            if(s[i] == '[')	cur = 0;
            else if(s[i] == ']')	cur = last;
            else{
                next[i] = next[cur];
                next[cur] = i;
                if(cur == last)	last = i;
                cur = i;
            }
            // next 存储字符串下标，既静态链表
            
        }
   		for(int i = next[0]; i != 0; i = next[i])
            cout << s[i];
        cout << endl;
    }
}

```



##	10.二叉树的构造

**对于二叉树的题型，先考虑用二叉树的性质。能不构建树就不构建树**

1. 根据(1，LL)  (1, )这样构造
2. 根据输入序列构造，如 按照前序输入序列 {5 7 -1 6 -1 -1 3 -1 -1} 其中-1代表空树



##	11.二叉树的遍历

1.根据中序和后序(前序)遍历确定一颗树

2.根据遍历结果构建二叉树

3.非递归遍历（借助栈）

后序非递归遍历比较难：

![image-20230219214907550](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230219214907550.png)

![image-20230219215327444](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230219215327444.png)

##	12.图

###	1.用DFS求连通块

常用模板：

```c++
const int maxn = 100 + 10;
int G[maxn][maxn], idx[maxn][maxn];		//idx用来对连通块编号
int r, c;
void dfs(int x,int y){
    if(!inside(x,y) || arr[x][y] ==  || idx[x][y] == 0)	return;		//如果当前坐标越界 或者 当前坐标内容不符合期望内容 或者 当前坐标已经访问过， 退出
    idx[x][y] = id;		//加上连通块编号	
    dfs(x+i, y+j);	//超不同方向递归进行
}
```



###	2.用BFS求最短路(单源不带权)

通用模板：

```c++
void bfs_min_distance(int u){
    //d[i] 表示从u节点到i节点的最短路径长度
    for(int i = 0; i < n; ++i)	d[i] = INT_MAX;
    vis[u] = true; d[u] = 0;
    EnQueue(Q,u);
    while(!isEmpty(Q)){
        DeQueue(Q,u);
        for() if(G[u][v] && vis[v] == false){	//v为u的下一访问节点
            vis[v] = true;	//也可以通过判断d[v]来判断是否访问过，从而省略vis
            d[v] = d[u] + 1;	//路径长度加一
            EnQueue(Q,v);	//入队
        }
    }
}
```

###	3.拓扑排序

DAG有向无环图的一种应用：拓扑排序

DFS版本：

```c++
// n == 节点个数  节点编号从[0,n)
bool dfs(int u){
    vis[u] = -1;	//当前节点u正在被访问，既递归调用的dfs(u)在栈帧中，未弹出
    for(int v = 0; v < n; ++v) if(G[u][v]){
        if(vis[v] < 0)	return false;	//有环！
        else if(vis[v] == 0 && !dfs(v))	return false;
    }
    vis[u] = 1; topo[--t] = u; 
    return true;
}
bool topo_sort(){
    t = n;	//由于dfs，要逆序保存答案
    memset(vis,0,sizeof(vis));
    for(int u = 0; u < n; ++u)	if(vis[u] == 0)
        if(!dfs(u))	return false;
    return true;
}
```

BFS版本：

```c++
//需要建立入度数组
bool bfs(){
    queue<int> q;	int t = 0;
    for(int u = 0; u < n; ++u)	if(indegree[u] == 0)
        q.push(u);
    while(!q.empty()){
        int u = q.front();	q.pop();
        topo[t++] = u;
        for(int v = 0; v < n; ++v) if(G[u][v] && --indegree[u] == 0)
            q.push(v);     
    }
    return n == t;	//如果保存的节点树不等于节点总数，说明一定有环
}
bool topo_sort(){
    return bfs();
}
```



###	4.欧拉回路

欧拉路径 = 半欧拉图

欧拉回路 = 欧拉图

<img src="C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230214152201939.png" alt="image-20230214152201939" style="zoom:67%;" />

##	13.离散化

离散化：把无限空间中的有限个体映射到有限的空间中，以此提高算法的时空效率

关键字：无限区间，有限值域

步骤：

- 排序
- 去重
- 二分取映射后的坐标

```c++
vector<int> arr;
sort(arr.begin(),arr.end());							//排序
arr.erase(unique(arr.begin(), arr.end()), arr.end());	//去重	使用resize也可以

int find(vector<int>& arr,int x){
    return lower_bound(arr.begin(),arr.end(),x);		//取得映射后的坐标
}
```















##	14.回溯法











##	15.路径搜索

​	状态看成点，状态的转移看成边，转换为图的遍历问题

常用技巧：

- 对状态去重，加快搜索速度

- 双向bfs往往要快于单向

  





##	16.启发式搜索	A*算法









##	17.位运算



- 求n的第k位二进制数字

  ```c++
  n >> k & 1;
  ```

  

- 访问n的最后一位1

  由于 -n = ~n + 1

  如：n = 0001 0100

  ​	   -n = 1110 1100

  则 n&-n = 100  

  ```c++
  lowbit(n) = n & -n
  ```

  原码

  反码

  补码 = 反码+1

  计算机的负数由补码表示





##	18.差分

- 一维差分

  ```c++
  // [l , r] 中每个数加上c : ad[l] += c, ad[r+1] -= c
  // 初始化差分 等同于  在[i,i]上加c
  ```

  

- 二维差分

  ```c++
  // s[x1,y1] += c, s[x2+1,y1] -= c, s[x1,y2+1] -= c, s[x2+1,y2+1] += c;
  ```

  



##	19.双指针



参见模板：

```c++
for(int i = 0, j = 0; i < n; ++i){
    while(j < i && check(i,j))	j++;
    ....
}
```

常见问题：

- 对于一个序列，用两个指针维护一段区间
- 对于两个序列，维护某种次序。如归并排序中的合并。







##	哈希表



离散化被称为特殊化的哈希（离散化要求有序）



使用的典型情形：

把值域在[-1e9，1e9]，个数在10e5的数据映射到1e5的空间内



处理冲突的方法：

- 拉链法
- 开放定址法

```c++
const int N = 100003;

int val[N], nxt[N], h[N], idx;

bool find(int x){
    int k = (x%N+N) % N;
    for(int i = h[k]; i != -1; i = nxt[k])
        if(val[i] == x)	return true;
    return false;
}

void insert(int x){
    int k = (x%N+N) % N;
    val[idx] = x;
    nxt[idx] = h[k];
    h[k] = idx++;		//头插法插入
}

memset(h,-1,sizeof(h));	//初始化槽为空
```





##	字典树	Trie



字典树是针对字符串的哈希



```c++
const int N = 100010;
int child[N][26], cnt[N], idx;

void insert(string str){
    int u = 0;
    for(auto ch : str){
        int v = ch - 'a';        
        if(!child[u][v]) child[u][v] = ++idx;
        u = child[u][v];
    }
    cnt[u]++;
}

int find(string str){
    int u = 0;
    for(auto ch : str){
        int v = ch - 'a';
        if(!child[u][v]) return 0;
        u = v;
    }
    return cnt[u];			// cnt即起到表示字符串个数，也起到标记的作用
}
```





##	KMP



m 为主串长度，n 为模式串长度

暴力做法：

```c++
int i, j;
for(i = 0; i < m - n + 1; ++i){
    for(j = 0; j < m; ++j)
        if(s[i] != t[j])	break;
    if(j == n)	return true;
}
```

$$
时间复杂度： \mathcal{O(mn)}
$$



kmp:

```c++
int m = s.size(), n = t.size(), nxt[n];

// 求每个子串的最长公共前后缀
void get_next(){
    nxt[0] = 0;
    // j 为最长公共前后缀长度
    for(int i = 1, j = 0; i < n; ++i){
        while(j && t[i] != t[j])	j = nxt[j-1];
        if(t[j] == t[i]) ++j;
        nxt[i] = j;
    }    
}

// a b a b c a b a b
// 0 0 1 2 0 1 2 3 2 


bool kmp(){
    for(int i = 0, j = 0; i < m; ++i){
        while(j && t[j] != s[i])	j = nxt[j-1];
        if(t[j] == s[i])	++j;
        if(j == n)	return true;
    }
    return false;
}
```

$$
时间复杂度： \mathcal{O(m)}
$$





##	并查集



并查集是一种用于管理元素所属集合的数据结构，实现为一个森林，其中每颗树表示一个集合，树的节点表示对应集合总的元素	



下例是维护了子集元素个数和元素值的总和信息的并查集，包括移动和删除操作

```c++
struct dsu{
    vector<int> pa, size, sum;
    
    explicit dsu(size_t len) : pa(2*len), size(2*len), sum(2*lun){
        iota(pa.begin(), pa.begin()+len, len);
        iota(pa.begin()+len, pa.end(), len);
        iota(sum.begin()+len, sum.end(), 0);
        // [0,len),[len,2*len)。 其中[0,len)为虚节点。
    }
    
    void unite(size_t x, size_t y){
        int fx = find(x), fy = find(y);
        if(fx == fy)	return;
        if(size[fx] < size[fy]) swap(fx,fy);	// 启发式合并
        size[fx] += size[fy];
        pa[y] = fx;
        sum[fx] += sum[fy];
    }
    
    int find(size_t x){
       return pa[x] == x ? x : pa[x] = find[pa[x]];	// 路径压缩 
    }
    
    void erase(size_t x){
        --size[find(x)];
        pa[x] = x;
    }
    
    //将x加入到y中
    void move(size_t x){
        int fx = find(x), fy = find(y);
        if(fx == fy)	return;
        sum[fx] -= x, sum[fy] += x;
        --size[fx], ++size[fy];
        pa[x] = fy;
        
    }
}
```





##	快速选择算法

**快速选择算法基于快速排序，即不完全排序（不完全排序），期望时间复杂度：O*(*n)，证明过程可以参考「《算法导论》9.2：期望为线性的选择算法」。**



**STL algorithm库中有类似的函数`nth_element`**

```c++
class Solution {
public:
    int findKthLargest(vector<int>& arr, int k) {
        nth_element(arr.begin(), arr.begin() + k - 1, arr.end(),greater<int>());
        return arr[k-1];
    }
};

// nth_element:
// [first,nth)  [nth,last]		nth位置的元素是完全排序后应该出现的元素
```









**普通快速排序的两个模板：**

oi-wiki:

```c++
void quick_sort(vector<int>& arr,int left,int right){
    if(left >= right)	return;
    int l = left, r = right, pivot = arr[left];
    while(l < r){
        while(l < r && arr[r] >= pivot)	--r;
        arr[l] = arr[r];
        while(l < r && arr[l] <= pivot)	++l;
        arr[r] = arr[l];
    }
    arr[l] = pivot;
    quick_sort(arr,left,r-1);	quick_sort(arr,l+1,right);
}
```

acwing:

```c++
void quick_sort(vector<int>& arr,int left,int right){
    if(left >= right)	return;
    int l = left - 1, r = right + 1, pivot = arr[(left + right) >> 1];
    while(l < r){
        do r--;	while(arr[r] > pivot);
        do l++; while(arr[l] < pivot);
        if(l < r)	swap(arr[l],arr[r]);
    }
    // 此时 [left,r] <= pivot    [l,right] >= pivot		l 和 r 可能重合
    quick_sort(arr,left,r);    quick_sort(arr,r+1,right);
}
```



**快速选择算法：**

经典例题：返回数组最大（或最小）的第k个数。时间复杂度要求是O(n)

基于oi-wiki：

```c++
int quick_select(vector<int>& arr,int left,int right,int k){
    int l = left, r = right,  pivot = arr[left];
    while(l < r){
        while(l < r && arr[r] >= pivot)	--r;
        arr[l] = arr[r];
        while(l < r && arr[l] <= pivot) ++l;
        arr[r] = arr[l];
    }
    arr[l] = pivot;
    if(l < k)	quick_select(arr,l+1,right,k);
    if(l > k)	quick_select(arr,left,l-1,k);
    return arr[l];
}
```

基于acwing:

```c++
int quick_select(vector<int>& arr,int left,int right,int k){
    if(left >= right)	return arr[k];
    int l = left - 1, r = right + 1, pivot = arr[(left+right) >> 1];
    while(l < r){
        do r--; while(arr[r] > pivot) --r;
        do l++; while(arr[l] < pivot) ++l;
        if(l < r) swap(arr[l],arr[r]);
    }
    // [left,r] <= pivot, [l,right] >= pivot   l 和 r 可能会重合, 重合既代表位置确定
    return r >= k ? quick_select(arr,left,r,k) : quick_select(arr,r+1,right,k);
}
```



以上的两种方案都不够好，当数组本身是有序的时候，时间复杂度会退化为O(n^2)。



**优化：**

- **三数取中**
- **随机化取pivot（主要）**
- **中位数的中位数**



**leetcode：**

```c++
class Solution {
public:
    int quick_select(vector<int>& arr,int left,int right,int index){
        int pos = partition(arr,left,right);
        if(pos == index)    return arr[pos];
        else    return pos < index ? quick_select(arr,pos+1,right,index) : 							quick_select(arr,left,pos-1,index);
    }

    int partition(vector<int>& arr,int left,int right){
        int pivot_index = left + rand() % (right - left + 1);
        swap(arr[right],arr[pivot_index]);
        int i = left - 1;
        for(int j = left; j < right; ++j){
            if(arr[j] <= arr[right])    swap(arr[++i],arr[j]);
        }
        swap(arr[i+1],arr[right]);
        return i+1;                     // [left,i] <= pivot  [i+1] == pivot  											 [i+2,right] > pivot
    }

    

    int findKthLargest(vector<int>& arr, int k) {
        ios::sync_with_stdio(false);
        cin.tie(0);
        srand(time(0));
        return quick_select(arr,0,arr.size()- 1, arr.size() - k);
    }
};
```





**对普通快速排序的朴素优化：**

**三路快速排序：**

me:

```c++
void quick_3way(vector<int>& arr, int left, int right){
    if(left >= right)    return;
    int pivot = arr[rand() % (right - left + 1) + left];
    int i = left, l = left, r = right;
    while(i <= r){						// 必须是 i <= r
        if(arr[i] < pivot)  swap(arr[l++],arr[i++]);
        else if(arr[i] > pivot) swap(arr[i],arr[r--]);
        else    i++;  
    }
    // l 是第一个等于pivot的元素
    // r 是最后一个等于pivot的元素
    quick_3way1(arr,left,l-1);
    quick_3way1(arr,r+1,right);  
}
```

oi-wiki：

```c++
void quick_3way(int *arr, int len){
    if(len <= 1)    return;
    int pivot = arr[rand() % len];
    // i：当前操作的元素
    // j：第一个等于 pivot 的元素
    // k：第一个大于 pivot 的元素
    // 完成一趟三路快排，将序列分为：
    // 小于 pivot 的元素｜ 等于 pivot 的元素 ｜ 大于 pivot 的元素
    int i = 0, j = 0, k = len;
    while(i < k){
        if(arr[i] < pivot)  swap(arr[i++],arr[j++]);
        else if(arr[i] > pivot) swap(arr[i],arr[--k]);
        else    ++i;
    }
    quick_3way(arr,j);
    quick_3way(arr+k,len-k);
}
```

对oi-wiki的vector版本：

```c++
void quick_3way(vector<int>& arr, int left, int right){
    if(left >= right)    return;
    int pivot = arr[rand() % (right - left + 1) + left];
    int i = left, j = left, k = right + 1;
    while(i < k){
        if(arr[i] < pivot)  swap(arr[i++],arr[j++]);
        else if(arr[i] > pivot) swap(arr[i],arr[--k]);
        else    i++;
    }
    quick_3way(arr,left,j-1);
    quick_3way(arr,k,right);  
}  
```



**基于三路快速排序的快速选择算法：**

```c++
class Solution {
public:
    int q3(vector<int>& arr, int left, int right, int k){
        // if(left >= right)   return arr[left];	不加这一条也能过
        int pivot = arr[left + rand() % (right - left + 1)];
        int i = left, l = left, r = right;
        while(i <= r){
            if(arr[i] < pivot)  swap(arr[i++],arr[l++]);
            else if(arr[i] > pivot) swap(arr[i],arr[r--]);
            else    i++;
        }
        //  [left,l-1] < pivot   [l,r] == pivot   [r+1,right] > pivot
        if(l > k)   return q3(arr,left,l-1,k);
        else if(k > r)  return q3(arr,r+1,right,k);
        return pivot;
    }
    int findKthLargest(vector<int>& nums, int k) {
        srand(time(0));
        return q3(nums,0,nums.size()-1,nums.size()-k);
    }
};
```

