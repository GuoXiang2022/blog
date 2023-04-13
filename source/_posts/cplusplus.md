---
title: c++ primer
date: 2023-04-12 20:51:06
#type: c++
#categories: 
#    - c++
type:
  - 计算机语言
---

#	primer



##	一.前置

###	1.引用 `reference`

引用属于复合类型

1. **引用既别名，引用并不是对象，它只是为一个已经存在的对象所起的另外一个名字。对其进行的所有操作都是在与之绑定的对象上进行的**
2. **引用本身不是一个对象，所以不能定义引用的引用(不能嵌套)**
3. **引用的类型要和与之绑定的对象严格匹配，而且引用只能绑定在对象上（非常量引用的初始值必须是左值），不能与字面值或某个表达式的计算结果绑定在一起。但是有两个例外！**



###	2.const限定符（关键字）

**1.默认状态下，const对象仅在文件内有效*

如：

```c++
const int bufSize = 512;
```

​	编译器将在编译过程中把用到该变量的地方都替换成对应的值。也就是说，编译器会找到代码中所有用到`bufSize`的地方，然后用512替换。

​	未了执行上述替换，编译器必须要知道`bufSize`的初始值。如果程序有多个文件，则每个用了const对象的文件都必须要能访问到它的初始值才行。要做到这一点，就必须在每个用到const对象文件中都有对它的定义。为了支持这一用法，同时避免对同一变量的重复定义，默认情况下，const对象都设定为仅在文件内有效。既当多个文件中出现了同名的const变量时，其实等同于在不同文件中分别定义了独立的变量。

​	如过需要在文件之间共享，只在一个文件中定义它，能在其他多个文件中声明并使用它，则需要：

```c++
// 对于const变量不管是声明还是定义都添加extern关键字

// file1定义并初始化了一个常量，该常量能被其他文件访问
extern const int bufSize = fcn();

// file2
extern const int bufSize;	//与file1中定义的bufSize是同一个
```

file2文件中extern指明bufSize并非本文件所独有，它的定义在别处出现

**2.如果想在多个文件之间共享const对象，必须在变量的定义之前添加extern关键字**

**3.对const的引用中，初始化常量引用时允许用任意表达式作为初始值，只要该表达式的结果能转换成引用的类型即可。特别的，允许一个常量引用绑定字面值。**

```c++
int i = 42;
const int& r1 = i;		//正确
const int& r2 = 42;		//正确
const int& r3 = r1 * 2;	//正确	绑定右值
int& r4 = r1 * 2;		//错误
```

引用的第一个例外

```c++
double dval = 3.14;
const int& ri = dval;	//正确！
```

why？编译器把上述代码变成了如下形式：

```c++
const int tmp = dval;	// 由dval生成了一个整型常量
const int& ri = tmp;	// 让ri绑定到这个临时量
```

如果`ri`不是常量，说明可以改变`ri`所绑定的对象的值，而此时绑定的是一个临时量而不是dval。显然，你想通过`ri`改变对象`dval`的值而不是临时量的值。所以C++语言把这种行为归为非法。

**4.const引用可以引用一个不是const的对象**

```c++
// 常量引用仅对该引用可参与的操作左了限定，对引用的对象本身是不是常量不做限制
//既：王强有一个别名叫王某，王某不能做坏事，当时王强可以
int i = 42;
int& r1 = i;
const int& r2 = i;
r1 = 0;	//正确
r2 = 0;	//错误
```

**5.顶层const：指针或对象本身是const，底层const：指针所指的对象是const，const引用都是底层const，其中可以添加或删除顶层const，也可以添加底层const，但是绝对不能删除底层const。既在底层const中，非常量可以转换为常量，反之不行**

```c++
struct Node{
	....
	void fun() const {}	
};
Node obj;
obj.fun(); // 正确，实参添加底层const

const Node cobj;
cobj.fun();	// 错误，试图删除实参的底层const

Node* p1 = new Node;
p1.fun();	// 正确，添加了this实参的顶层const

void fun(int x);
const int rx; 	fun(rx)	// 正确，删除了实参rx的顶层const
```

**6.对顶层const,底层const的补充**

不能一味的通过不能删除底层const来判断

```c++
void fun(int& param){
    ...
}

const int x = 111;
fun(x);				//错误,限定符const将被丢弃
```





###	3.constexpr和常量表达式

***常量表达式（const expression）是指值不会发生改变且在编译阶段就能得到计算结果的表达式。***

```c++
// 一个对象或表达式是不是常量表达式由它的数据类型和初始值共同决定
const int maxn = 1000;		// 是
const int maxc = maxn + 10;	// 是
int n = 27;					// 由于数据类型非const故 不是
const int sz = get_size();	//不是 它的值直到运行时才能获取到
```

**1.constexpr变量**

在复杂的程序中，很难分辨一个初始值到底是不是常量表达式。

​	**C++11规定，允许将变量声明为`constexpr`类型以便由编译器来验证变量的值是否是一个常量表达式**。声明为constexpr的变量一定是一个常量，而且必须用常量表达式初始化。

```c++
constexpr int maxn = 20;		//正确，20是常量表达式
constexpr int manc = maxn + 10;	//正确，mf+1是常量表达式
constexpr int sz = size();		//只有当size()是一个constexpr函数时									才正确
//p214 将要介绍 c++11 constexpr函数
```

**2.字面值类型**

​	常量表达式的值需要在编译的时候就得到确定，因此对声明`constexpr`时用到的类型必须要有所限制。因为这些类型一般比较简单，值也显然易见，容易得到，就把他们称为`字面值类型 literal type`

​	**算数类型**，**引用**和**指针**都属于字面值类型，**自定义类，IO库，string类等不属于字面值类型**。**其中指针必须是nullptr,**或者是存储在否个固定地址的对象。

```c++
int *p = nullptr;
constexpr int *cp = p;	//正确
constexpr string cs = string("abc");	//错误
```

​	需要注意，**`constexpr`把它所定义的对象置为了顶层const**

stop pdf p86



###	4.constexpr函数

函数的返回类型以及所有形参的类型都得是字面值类型，而且函数体必须有且只有一条return语句：

```c++
constexpr int new_sz() { return 42; }
constexpr int foo = new_sz();			// 正确：constexpr使用常量表达式初始化
```

constexpr函数被隐式地指定为内联函数

constexpr函数体也可以包含其他语句，只要这些语句在运行时不执行任何操作就行。

例如，constexpr函数中可以有空语句，类型别名以及using声明。

**注意：constexpr函数不一定返回常量表达式**

```c++
#include <iostream>
#include <array>
using namespace std;

constexpr int foo(int i)
{
    return i + 5;
}

int main()
{
    int i = 10;
    std::array<int, foo(5)> arr; // OK
    
    foo(i); // Call is Ok
    
    // But...
    std::array<int, foo(i)> arr1; // Error foo(i) 返回的不是常量表达式
   
}
```











##	二.第七章  类

###	7.1定义抽象数据类型

1. **定义在类内部的函数隐式的inline函数**，**定义在类外部的成员函数默认是不内联的**

2. **所有成员都必须在类的内部声明，成员函数体可以定义在类内也可以定义在类外**

   ```c++
   class S{...};
   void S::fun(){...};		//使用作用域运算符即可
   ```

   

3. **除了static成员函数，其他成员函数都有一个隐式的this指针,且该this指针是指针常量(*const this,顶层const)**

   ```c++
   // 成员函数(非static)通过一个名为this来访问调用它的那个对象
   total.isbn();
   Sales_data::isbn(&total);	//编译器将调用重写成这种形式
   
   //在成员函数内部，我们可以直接使用该函数对象的成员，而无需通过成员访问运算符来做到这一点，因为this所指的正是这个对象。任何对类成员的直接访问都被看作this的隐式引用。也就是说，当isbn成员函数使用bookno时，它隐式地使用this指向的成员，就像我们写了this->bookno一样。
   string isbn() const {
       return this->bookno;	// 等同于 return bookno; 
   }
   ```

4. **常量成员函数，既const *const this**

5. 定义非成员函数和定义其他函数一样，通常把函数的声明和定义分离开来。如果函数在概念上属于类但是不定义在类中，则它一般应于类声明在同一个头文件内。在这种方式下，用户使用接口的任何部分都只需要引入一个文件即可。i

6. 构造函数不能被声明成const的。当我们创建类的一个const对象时候，直到构造函数完成初始化过程，对象才能真正取得其常量属性。所以，构造函数需要在const对象的构造过程中像其写值

7. 默认构造函数 （default constructor)

   ​	如果类没有定义任何构造函数，那么编译器会隐式的定义一个默认构造函数，称为`合成的默认构造函数`，将按照如下规则初始化类的数据成员

   1. 如果存在**类内初始值（c++11）**，用它来初始化成员。**（类内初始值必须以=或花括号表示）**

   2. 否则，**默认初始化**。

      ​	默认初始化：定义于函数体外的变量被初始化为0，定义在函数体内部的内置或复合类型变量将**不被初始化**，其值是未定义的。

      如果我们需要默认的的构造函数，可以

      ```c++
      //c++11
      My_class() = default; // 要求编译器生成构造函数
      ```

8. 初始值列表（初值列）和构造函数

   ```c++
   初值列 -> 默认构造规则 -> 构造函数函数体 
   ```



###	7.2 访问控制和封装

1. class和struct的区别

   **class和struct定义类唯一的区别就是默认的访问权限。**

   1. struct默认访问说明符：public， class默认是：private

2. **友元打破了类的封装性**，一般来说，最好在类定义开始或结束前的位置其中声明友元



###	7.3 类的其他特性

1. `mutable`关键字，一个`mutable`成员变量永远不会是const，即使它是const对象的成员。

   ```c++
   class S{
   public:
       mutable int a = 1;
       void fun() const { a = 6; }
   };
   const S obj;
   obj.fun();	// mutable修饰的变量不受const限定符的影响
   ```

2. const成员函数如果以引用的形式返回*this，那么它的返回类型是`const&`

   ```c++
   class S{
      	S& fun1() const { return *this; }			//错误
       const S& fun2() const { return *this; }		//正确
   }
   ```

   

3. 基于const进行函数的重载 （函数的参数或类型不同，即可重载）

   ```c++
   class S{
       S& fun() {return *this; }	//1
       const S& fun() const { return *this; } //2
   }
   S obj1;	const S obj2;
   obj1.fun(); obj2.fun();	//obj1调用1，obj2调用2。原因是重载函数的参							//数匹配优先级（最佳匹配）
   ```

4. 类的前向声明`forward declaration`

   ![image-20230221230425140](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230221230425140.png)

5. 友元再探

   1. 可以把其他类定义成友元（友元类）

      ```c++
      class S{    
          int a = 1,b = 2,c = 3;
          friend class T;
      };
      //友元类的成员函数可以访问类包括非公有成员在内的所有成员
      class T{
          S sobj;
      public:
          void fun() { cout << sobj.a << endl; }
      	friend class K; // K不能访问S的成员，友元不具有传递性！
      };
      T tobj;
      tobj.fun();		//正确
      ```

      

   2. 可以把其他类的成员函数定义为友元

      ```c++
      class T{
      public:		//必须是public
          void fun() {}
      };
      class S{
          friend void T::fun();	//必须要指明该成员函数来自哪一个类
      };
      ```

      

   3. 定义在类内部的友元是隐式内联的

   4. 如果一个类想把一组重载函数声明成它的友元，需要对这组函数中的每一个分别声明

   5. 友元声明和作用域

      ```c++
      // 哪怕是在类内部定义该友元函数，也必须要在类的外部提供相应的声明从而使该函数可见。
      class S{
          friend void fun(){}
          void s1() { fun(); }	//错误，找不到fun()的declaration
      };
      
      void fun();
      class S{
          friend void fun();
          void s1() { fun(); }	//正确
      }
      ```




###	7.4	类的作用域

1. **一个类就是一个作用域，在类的外部，成员的名字被隐藏起来了。一旦遇到类的名字，定义的剩余部分就在类的作用域之内了。剩余部分指：参数列表和函数体。**

   ```c++
   class T{};
   class S{
       using tt = T;
       tt fun();
   }
   S::tt S::fun(){
       return tt();	// 函数放回类型 和 函数名都要加上作用域运算符
       				// 说明它是哪个内的成员函数定义
   }
   ```

2. **类的名字查找有两个阶段**

   普遍的名字查找规则：

   1. 首先，在**名字所在的块中**寻找声明语句，只寻找该名字使用**之前**的
   2. 如果没找到，继续**查找外层作用域**
   3. 如果还没找到，报错

   对于定义在类内部的成员函数，分两步处理：

   1. 首先，编译所有成员的声明 **（应用普通名字查找规则）**
   2. 编译完全部成员声明后，再编译函数体

   ```c++
   typedef int MM;
   string KK = "abc";
   
   class S{
   public:
       MM fun() { return KK; }
       // 函数返回类型MM根据规则一，是类外部声明的int
       // 返回类型KK根据规则二，是类内部的KK
   private:
       MM KK;
   };
   ```

**3.一般来说，内层作用域可以重新定义外层作用域的名字，即便该名字已经在内层作用域中使用过。但是在类中，不能这样。**

**4.成员函数中使用的名字查找规则：**

1. 首先，在成员函数内查找该名字的声明。和前面一样，只有在函数使用该名字之前出现的声明才被考虑
2. 如果在成员函数内没有找到，则在类内继续查找，此时类的所有成员都可以被考虑。
3. 如果类内也没找到该名字的声明，在**类外或者是成员函数定义之前**的作用域内继续查找。

```c++
class S{
public:
    int a;
    int fun();
};
int b = 666;	//全局b在类S之前是不可见的。然而规则三包括了成员函数定义				  //之前的全局作用域
int S::fun(){
    return b;
}
```

###	7.5构造函数再探

1. 如果成员是const，应用，或者是某种未提供默认构造函数的类类型，我们必须通过构造函数初始化列表为这些成员提供初值

2. 成员初始化的顺序和它们在类定义中的出现顺序一致。

   ```c++
   class S{
       int i, j;
   public:
       S(int val):j(val),i(j) { }
       //错误！i按照出现顺序先初始化，此时j的值未定义。
   }
   ```

3. 如果一个构造函数的所有参数都提供默认值，则它实际上也定义了默认构造函数

4. **委托构造函数(C++11)**，一个构造函数使用它所属类的其他构造函数执行它自己的初始化过程，或者说它把它自己的一些或者全部职责委托给了其他构造函数

   ```c++
   class S{
   public:
       int a;
       string b;
       S(int a,string b):a(a),b(b) {}
       S():S(0,""){}
       S(string s):S(0,s){ a = 111; }
   };
   ```

5. 使用默认构造函数

   ```c++
   Sales_data obj();	//错误，声明了一个函数而非对象
   Sales_data obj2;	//正确，obj2是对象，且执行了默认构造函数
   ```

6. 隐式的类类型转换（converting constructor 转换构造函数）

   1. non-explicit one argument constructor

      能通过一个实参调用的构造函数定义了一条从构造函数的参数列表向类类型隐式转换的规则 

      ```c++
      struct S{
          explicit S(string s) {}
          S(){}
          S operator+(S) { return *this;}
      };
      void fun(S){}
      string str;
      fun(str);	//正确！
      S a,c;
      a = c + str; //正确！
      ```

   2. 只允许一步转换

      ```c++
      struct S{
          explicit S(string s) {}
          S(){}
          S operator+(S) { return *this;}
      };
      fun(S){}
      fun("abc");		//错误！只允许一步转换 const char* -> string -> S 发生了两步转换
      ```

7. **ecplicit关键字**

   抑制构造函数定义的隐式转换

   ecplicit构造函数只能用于直接初始化

8. 聚合类   详见p267

9. **字面值常量类,constexpr构造函数** p293



###	7.6 类的静态成员

1. 定义静态成员

   ```c++
   struct S{
       static int a;	
   }
   int S::a = 111;	//定义
   ```

2. 静态成员的类内初始化

   ```c++
   //当静态成员时字面值常量类型的constexpr（初始值必须时constexpr）
   struct S{
       static constexpr int a = 666;
   }
   //既使在类内初始化了，通常情况下也应该在类外定义一下该成员
   constexpr int S::a;
   ```

3. 静态成员的独特性

   ```c++
   struct S{
       int a;			
       S* p;			//正确
       S b;			//错误，S是不完全类型
       static S c;		//正确，static成员的独特性
       .....
   }
   ```




##	三.拷贝控制



###	1.拷贝，赋值与销毁

​	拷贝控制操作 `copy control`：

1. 拷贝构造函数		`copy constructor`
2. 拷贝赋值运算符    `copy-assignment operator`
3. 移动构造函数      `move constructor`
4. 移动赋值函数      `mova-assignment operator`
5. 析构函数              `destructor`

​	

#### 	**1.拷贝构造函数 copy-constructor**

1. 拷贝构造函数的第一参数**必须**是引用类型，且总是**const**的，由于在几种情况下都会被隐式的使用，所以**通常不应该是explicit的**。**且拷贝构造函数同样可以使用初值列**

2. 和构造函数一样，我们没有定义拷贝构造函数，编译器会为我们合成一个拷贝构造函数（除了有**=delete**操作的类）合成的拷贝构造将其参数的成员逐个的拷贝到正在创建的对象中，除了static成员。如果成员是类成员，那么会调用该类成员的拷贝构造函数（复读）

3. **拷贝初始化和直接初始化**

   ```c++
   struct S{
   	S(string str) { cout << "Constructor" << endl; }
   	S(const S& s) { cout << "Copy-Constructor" << endl;}
   };
   S a("abc");		//Constructor    		直接初始化
   S b(a);			//Copy-Constructor 		直接初始化
   S c = "abc";	//Costructor			拷贝初始化	
   				//"abc"通过构造函数生成一个临时量，再进行拷贝初始化。但是编译器帮我们优化为c("abc")
   				//类似NRV优化
   
   S d = c;		//Copy-Constructor		拷贝初始化
   
   //拷贝构造函数发生在初始化阶段，如：
   S a(b);
   S a = "abc";
   S a = b;	
   ```

   拷贝初始化通常由拷贝构造函数完成，拷贝构造函数不仅在我们使用=定义变量的时候发生，在

   1. **对象作为实参传递给一个非引用类型的形参**
   2. **从一个返回类型为非引用类型的函数返回一个对象**
   3. **用花括号列表初始化一个数组或一个聚合类**。**insert,push是拷贝初始化，emplace则是直接初始化**

4. **拷贝构造函数的参数不是引用，将无限递归构造下去。**

5. **编译器可以绕过拷贝构造函数**  **p468**

   在拷贝初始化的过程中，编译器可以跳过拷贝/移动构造函数，直接创建对象

   ```c++
   string str = "abc";
   //编译器直接将其改写为
   string str("abc");	//构造函数	跳过了拷贝构造函数
   ```

   **注意！虽然跳过，但是拷贝/移动构造函数必须是存在且可访问的！**



####	2.拷贝赋值运算符 copy-assignment operator

​	和上面的一样。如果类没有定义自己的拷贝赋值运算符，编译器会合成一个

1. 拷贝赋值运算符和操作符重载，**operator=必须重载为成员函数，且返回左值（引用）**

2. 合成的拷贝赋值运算符

   ```c++
   struct S{
   	int a;
   	string b;
   	S() {}
   };
   //合成的拷贝赋值运算符等价如下
   S& S::operator=(const S& agr){
       a = arg.a;
       b = arg.b;
       return *this;		//静态成员不能赋值
   }
   ```



####	3.析构函数

​	**析构函数完成和构造函数相反的工作：释放对象使用的资源，并销毁对象的非static数据成员**

1. 无返回值，不接受参数，不能被重载（无参数怎么被重载），对于一个类只会有唯一一个析构函数

2. **构造函数，先初始化，再执行函数体，初始化的顺序是在类中的出现顺序**

   **析构函数，先执行函数体，再销毁成员，销毁顺序还在类中出现顺序的逆序**

3. 内置类型的销毁过程是隐式的，和拷贝构造类似，如果有类类型成员销毁，则调用该类的析构函数。

4. 隐式销毁一个内置指针类型的成员不会delete它所指的对象，智能指针是类类型，具有析构函数，所以可以被隐式销毁。

5. 什么时候会调用析构函数

   1. 变量离开其作用域
   2. 容器被销毁时，其元素被销毁
   3. 动态分配的对象，对它的指针delete时被销毁
   4. 临时对象，当创建它的完整表达式结束时被销毁

####	4.三/五法则

1. **需要析构函数的类也需要拷贝和赋值操作**

   决定一个类是否要定义它自己版本的拷贝控制`copy control`,**一个基本原则时首先确定这个类是否需要一个析构函数**。通常，对析构函数的需求比对拷贝构造函数或拷贝赋值运算符的需求更加明显。**如果这个类需要一个析构函数，我们几乎可以肯定它也需要一个拷贝构造函数和拷贝赋值运算符**。

2. **需要拷贝操作的类也需要赋值操作，反之亦然**

   一个类需要拷贝构造函数，几乎可以肯定它也需要拷贝赋值运算符，如果一个类需要一个拷贝赋值运算符，几乎可以肯定它也需要一个拷贝构造函数。**注意，无论是需要拷贝构造函数还是需要拷贝赋值运算符都不必然意味着需要析构函数**

   

####	5.使用=default  c++11

1. 显然易见，**只能对有合成版本的成员函数使用=default**
2. 可以在类内=default，也可以在类外=default
3. 在类内=default将是隐式内联的，在类外则不是



####	6.阻止拷贝 =delete c++11

1. **必须在第一次声明**时使用=delete；和=default不同。这在逻辑上是吻合的

2. **可以对任何函数指定=delete**

3. **析构函数不能是=delete**，对于析构函数已删除的类型，不能定义该类型的变量或释放该类型动态分配对象的指针

4. 在c++11之前，类是通过将拷贝控制函数声明为private来阻止拷贝。详见p477

5. 合成的拷贝控制成员可能默认是删除的

   1. 如果类的某个成员的析构函数是删除的或不可访问的，则类的合成析构函数和合成拷贝构造函数和默认构造函数被定义为删除的

   2. 如果类的某个成员的拷贝构造函数是删除的或不可访问的，则类的合成拷贝构造函数被定义为删除的

   3. 如果类的某个成员的拷贝赋值运算符是删除的或不可访问的，或是**类有一个const的或引用成员**，则类的合成拷贝赋值运算符被定义为删除的

   4. 如果类的某个const成员的构造函数是删除的或不可访问的，则类的默认构造函数被定义为删除的

      本质上，这些规则的含义是：

      **如果一个类对应的数据成员不能默认构造，拷贝，赋值或销毁，则对应的成员函数将被默认定义为删除的；**

      ```c++
      struct T{
          T() = delete;
      };
      struct S{
        T t;  
      };
      S obj;	//错误，无法引用 "S" 的默认构造函数 -- 它是已删除的函数！
      ```

      

###	2.拷贝控制和资源管理

​	对于拷贝操作的定义，一般有两种选择：

1. 定义拷贝操作，使类的行为像值

2. 定义拷贝操作，使类的行为像指针

   当然也有行为既不像指针也不像值的类，如：io类型，unique_ptr;

####	1.定义行为像值的类

1. 如果类中含指针，就需要定义拷贝操作使指针进行深拷贝。
2. 定义拷贝赋值运算符，需要考虑自赋值`self-assignment`现象
3. 编写赋值运算符时，需要记住两点：
   1. 如果将对象赋予它自身，赋值运算符必须能正确工作
   2. 大多数赋值运算组合了析构函数和拷贝构造函数的工作

####	2.定义行为像指针的类

​	核心操作是引用计数（reference counting）,具体如下：

```c++
#include <bits/stdc++.h>

using namespace std;

// 行为像指针的类  p481

class HasPtr{

public:
    HasPtr(const string& s = string()):ps(new string(s)),i(0),use(new size_t(1)) {}
    HasPtr(const HasPtr& p):ps(p.ps),i(p.i),use(p.use) { ++(*use); }
    HasPtr& operator=(const HasPtr& rhs){
        ++(*rhs.use);
        if(--(*use) == 0){
            delete use;
            delete ps;
        }
        ps = rhs.ps;
        i = rhs.i;
        use = rhs.use;
        return *this;
    }
    ~HasPtr(){
        if(--*use == 0){
            delete ps;
            delete use;
        }
    }

    void read(){
        cout << "ps = " << *ps << endl;
        cout << "use = " << *use << endl;
    }

private:
    string* ps;
    int i;
    size_t* use;
};
int main(){
    string s1 = "abc", s2 = "efg";
    HasPtr a(s1), b(s2);
    HasPtr c(a), d(a);
    c.read(); d.read(); b.read();   
    system("pause");
}

```

####	3.交换操作

1. 编写自定义swap函数

2. 在赋值运算符中使用swap是自动安全的，能确实处理自赋值

   ```c++
   //copy and swap
   HasPtr& HasPtr::operator=(HasPtr rhs){
       swap(*shit,rhs);
       return *this;
   }
   ```

   

####	4.拷贝控制示例

p160





####	5.动态内存管理类

利用allocator类来进行动态内存的管理

```c++
#include <memory>
allocator<string> a;
a.allocate(n);					//返回首指针，n：要分配存储的对象数
a.deallocate(p,n);				//p必须是allocate返回的指针，n同样
a.constructor(p,args);			//c++20被移除
a.destroy(p);					//c++20被移除
```

利用allocator算法来拷贝和填充未初始化内存的算法

```c++
uninitialized_copy(b,e,b2);		//返回尾后迭代器
uninitialized_copy(b,n,b2);
uninitialized_fill(b,e,t);
uninitialized_fill_n(b,n,t);
```





###	6.对象移动

在某些情况下，对象拷贝后就立即被销毁了，在这种情况下，移动而非拷贝对象会大幅度提升性能。

在旧版本中，容器所保存的类必须是可拷贝的；但在新标准中，容器可以保存不能拷贝的类型，只要它们能够被移动即可。如(IO类和unique_prt类)



####	1.右值引用 `rvalue reference`

​	右值引用的性质是：只能绑定一个将要销毁的对象。因此，我们可能自由的把一个右值引用的资源移动到另一个对象中。我们用`&&`表示右值引用

1. **右值引用不能绑定到左值上，左值引用和右值引用都能绑定到右值上**

   ```c++
   int i = 111;
   int &&r = i;			//错误  右值引用不能绑定到左值上
   int &&rr2 = i * 11;		//正确  右值引用绑定到右值上
   const int &r3 = rr2;	//正确  常量左值引用可以绑定到右值上	
   ```

2. **左值持久，右值短暂**

   右值引用只能绑定到临时对象上，可知

   1. 所引用的对象将要被销毁
   2. 该对象没有其他的用户

   这两个特性意味着：使用右值引用的代码可以自由的接管所引用对象的资源

   

3. **注意，变量是左值**

   ```c++
   int &&rr1 = 42;
   int &&rr2 = rr1;	//错误，rr1是左值！
   ```

   

4. **标准库move函数**

   虽然不能把右值引用绑定到左值上，但我们可以显式的将一个左值转换为对应的右值引用类型。

   ```c++
   int &&rr3 = std::move(rr1);	//ok
   ```

   **mova调用告诉编译器：我们有一个左值，我希望像个右值一样处理它。**

   ​	**我们必须认识到，调用move就意味着承诺：除了对rr1赋值或销毁它外，我们将不再使用它。在调用move之后，我们不能对移后源对象的值做任何假设**



####	2.移动构造函数和移动赋值运算符

这两个成员类似对应的拷贝操作，但它们从给定对象**窃取**资源而不是拷贝资源



1. **移动操作，标准库容器和异常**

   ​	由于移动操作窃取资源，不分配资源。因此移动操作通常不会抛出异常。当编写出一个不会抛出异	常的一道操作时，我们应该将此事通知标准库。如果不通知，标准库会认为移动我们的类对象时可能会抛出异常，并为了处理这种异常而做出一些额外的工作。

   ​	一种通知标准库的方法是指明`noexcept`（c++11），注意，**需要在声明和定义中都指定noexcept**

   

2. **不抛出异常的移动构造函数和移动赋值运算符必须标记为noexcept**

   原因：vector为了保证自身完整性。如果vector不知道移动构造函数不会抛出异常，它会使用拷贝构造函数。

   

3. **移动赋值运算符也要检查自赋值问题。原因是右值可能是move调用的结果。**

   

4. **移后源对象必须可安全析构**

   **在移动操作后，移后源对象必须保持有效，可析构的状态，但是用户不能对其值做任何假设。**

   

5. 合成的移动操作

   1. **如果类定义了自己的拷贝构造，拷贝赋值或析构函数，编译器不会为它合成移动构造和移动赋值**

   2. **如果类没有定义任何自己版本的拷贝控制成员，且类的每一个非静态成员都可以移动（包括类类型成员），编译器才会为它合成移动构造和移动赋值。**

   3. **如果类定义了一个移动构造函数和/或一个移动赋值运算符，则该类的合成拷贝构造函数和拷贝赋值运算符会被定义为删除的**

      

6. **定义了一个移动构造或移动赋值的类必须也定义自己的拷贝操作，否则这些成员默认被定义为删除的**

   

7. **移动右值，拷贝左值，但如果没有移动构造函数，右值也被拷贝**

   

8. **更新三/五法则**

   所有五个拷贝控制成员应该看作一个整体：一般来说，如果一个类定义了任何一个拷贝操作，它就一个定义所有五个操作

   

9. **移动迭代器`move iterator`**

   移动迭代器解引用生成一个右值引用。

   我们通过stl的make_move_iterator函数将一个普通迭代器转换为一个移动迭代器。如：

   ```c++
   auto last = uninitialized_copy(make_move_iterator(begin()),make_move_iterator(end()),first);
   ```

   ![image-20230226151332316](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230226151332316.png)

   

   

   ####	3.右值引用和成员函数

   

   1. **区分移动和拷贝的重载函数通常有一个版本接受一个const T&，而另一个版本接受T&&**

      ```c++
      void push_back(const T&);
      void push_back(T&&);
      ```

      想想为什么不是`const T&&`

      

   2. 右值/左值引用对成员函数的影响

      ```c++
      string s1 = "abc", s2 = "efg";
      s1 + s2 = "tyu";	//不报错！
      ```

      为了先后兼任，新标准库仍然允许向右值赋值。

      我们希望在自己的类中阻止这种用法，我们希望强制左侧运算（既this所指的对象）对象是一个左值

   3. 引用限定符

      1. 类是const限定符，必须同时出现在函数的声明和定义中，且只能用于非static成员函数

      2. 对于&限定的函数，只能用于左值；对于&&限定，只能用于右值

      3. 可以同时用const和引用限定，引用限定必须在const限定符的后面

         ```c++
         S fun() & const;	//错误
         S fun() const &; 	//正确
         ```

   4. 重载和引用函数

      1. &指出this引用的必须是左值，&&指针this引用的必须是右值。可以使用move显式的把左值转换为右值。如下：

         ```c++
         struct R{
             void fun() & { cout << 111 << endl; }
             void fun() && { cout << 222 << endl; }
         };
         R x;
         x.fun();				//调用第一个
         R().fun();				//调用第二个
         std::move(x).fun();		//调用第一个
         
         ```

         

      2. **如果我们定义两个或两个以上具有同名和相同参数列表的成员函数，就必须对所有函数都加上引用限定符，或者都不加。**

         ```c++
         struct R{
             void fun() & { cout << 111 << endl; }
             void fun()  { cout << 222 << endl; }	//错误
         };
         ```

         





##	四.操作重载与类型转换

###	1.基本概念

1. 当一个重载运算符是成员函数时，this绑定到左侧运算对象。成员运算符函数（显式）参数数量比运算对象的数量少一个。

2. 不能重载的运算符：:: .* . ?:

3. 显式使用重载运算符

   ```c++
   data1 + data2;
   operator+(data1,data2);		//显示调用
   data1 += data2;
   data1.operator+=(data2);	//显示调用
   ```

4. 某些运算符不应该被重载，如通常情况下不应该重载逗号，取地址，逻辑与和逻辑或运算符

5. 重载运算符的使用应该与内置类型有一致的含义

6. 成员函数和非成员函数的选择

   1. **赋值，下标，调用，箭头运算符必须是成员函数**
   2. 复合赋值运算符一般来说是成员
   3. 改变对象状态或与给定类型密切相关的运算符一般是成员，如递增，递减和解引用。
   4. 具有对称性的运算符一般是非成员函数，如算术，相等性，关系和位运算符



###	2.输入和输出运算符

​	IO类的对象无法拷贝

1. 输入输出运算符必须是非成员函数
2. IO运算通常要读写类的数据成员，所以IO运算符一般声明为友元
3. 输入运算符必须处理输入可能失败的情况，而输出运算符不需要



###	3.算术和关系运算符

1. 如果类同时定义了算术运算符和相关的复合赋值运算符，则通常情况下应该使用复合赋值来实现算术运算符
2. 如果某个类在逻辑上有相等的含义，则该类应该定义operator==，如果类定义了operator==,那么也应该定义operator!=，且一个负责实际比较，另一个调用负责比较的运算符
3. 对于operator<或>,如果类中有==运算符，则<或>运算符的结果应该和==一致，如：如果<，那么也一定不!=。如果不一致，那还是不重载此关系运算符



###	4.赋值运算符

必须是成员函数

1. 除了拷贝赋值和移动赋值，标准库vector类还定义了第三种赋值运算符，该运算符接受一个初始化列表`initializer list` （C++11）,如：

   ```c++
   vector<string> v;
   v = {"a","an","the"};
   
   StrVec &operator=(std::initializer_list<std::string>);
   //在上面这种赋值符，不用考虑自赋值现象，因为initializer_list保证不是同一个对象
   ```

2. 返回值是否加引用，取决于内置运算符。如operator+=：

   ```c++
   int a = 1, b = 1, c;
   c += a += b;
   S& operator+=(const S& rhs);	//为了和内置运算符一致，返回引用
   ```



###	5.下标运算符

​	下标运算符必须是成员函数，且一般需要重载就要重载两个。

```c++
//effective c++
const S& operator[](size_t pos) const { return ...; }

S& operator[](size_t pos){
    return const_cast<S&>(static_cast<const S>(*this)[pos]);
}
```

1. 重载下标运算符一般需要重载非常量版和常量版



###	6.递增和递减运算符

1. 为了和内置版本保持一致，前置运算符应该返回递增或递减后对象的引用，后置则返回一个值

2. 为了区分前置后后置运算符，后置版本接受一个额外的(不被使用)int类型的形参

   ```c++
   S operator++(int){	//因为我们不会用到int形参，所以无需为其命名
       ....
   }	
   ```

   

3. 同样，后置运算符可以调用前置运算符完成自己的工作



###	7.成员访问运算符

1. 箭头运算符必须是类的成员。解引用运算符通常也是类的成员，尽管并非必须如此
2. **箭头运算符永远不能丢掉成员访问这个最基本的含义**
3. 重载的箭头运算符必须返回类的指针或者自定义了箭头运算符的某个类的对象

![image-20230227203827110](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230227203827110.png)







###	8.函数调用运算符

1. 函数调用运算符必须是成员函数，一个类可以定义多个不同版本的调用运算符，相互之间应该在参数数量或类型上有所区别

2. 如果类定义了调用运算符，则该类的对象称为函数对象`function object`(行为像函数)

3. 函数对象通常含有一些数据成员，即含有状态的函数对象类

4. 函数对象常常作为泛型算法的实参

   ```c++
   class PrintString{...};
   PrintString printer;	//使用默认值
   printer(s);				//调用函数调用打印s
   
   PrintString errors(cerr,'\n');	//使用其他状态
   errors(s);
   
   
   for_each(vs.begin(),vs.end(),PrintString(cerr,'\n'));		
   //for_each(first,last,执行策略)
   ```

   

####	1.lambda是函数对象

1. 编译器将lambda表达式翻译成一个未命名类的未命名对象（匿名对象）

   ```c++
   sort(words.begin(),words.end(),[](const string &a,const string &b){return a.size() < b.size();});
   //编译翻译如下
   class {
   public:
   	bool operator()(const string &s1,const string &s2) const {	//默认lambda不改变它捕获的变量，所以是const
           return s1.size() < s2.size();
       }    
   }
   ```

2. 表示lambda及相应捕获行为的类

   1. 如果通过引用捕获变量，编译器可以直接使用该引用而无须在lambda产生的类中将其存储为数据成员

   2. 如果通过值捕获变量，这种lambda产生的类必须为每个值捕获的遍历建立相应的数据成员，同时创建构造函数用来初始化数据成员，如：

      ```c++
      [sz](const string &a) { return a.size() >= sz; }
      //翻译为下
      class cmp{
          cmp(size_t n):sz(n) {}	//捕获的变量
          bool operator()(const string &s) const{
              return s.size() >= sz;     
          }
      }
      ```

   3. lambda是对函数对象在使用方式上的简化，当泛型算法需要一个简单的函数，并且这个函数不会在其他地方被使用，就可以用lambda来实现。相反，如果这个函数需要多次使用，且还需要保存某些状态，使用函数对象会更合适一些



####	2.标准库定义的函数对象

定义在头文件functional

![image-20230227212233689](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230227212233689.png)

1. 在算法中使用标准库函数对象

   ```c++
   sort(s.begin(),s.end(),greater<string>());   //逆序排序
   ```

2. 标准库中的函数对象对指针同样适用。我们比较两个无关指针将产生未定义行为，但是标准库函数对象不会。如果我们需要比较指针的内存地址来sort指针vector，可以使用标准库函数对象

   ```c++
   string a = "a", b = "b", c = "c";
   string* arr[3] = {&a,&b,&c};
   sort(arr,arr+3,less<string*>());		//正确！
   ```

3. 函数对象加函数适配器配合算法功能强大

   ```c++
   int a = count_if(arr,arr+5,bind(greater<int>(),_1,1024));
   auto b = find_if(srr,srr+3,bind(not_equal_to<string>(),_1,"pooh"));
   //transform 算法库内的函数
   transform(arr,arr+5,arr,bind(multiplies<int>(),_1,2));
   ```



####	3.可调用对象和function

​	c++可以调用的对象：函数，函数指针，lambda表达式，bind创建的对象以及重载了函数调用运算符的类

问题：两个不同类型的可调用对象却可能共享一种调用形式（call signature）,如：

​			`int(int,int)`

​			这会带来什么问题呢，如：





解决的方法：

1. function类型	（c++11）

​	如：

```c++
function<int(int,int)> f1 = add;
function<int(int,int)> f2 = div();
function<int(int,int)> f3 = [](int a,int b) { return a*b; };
cout << f1(4,2) << endl;  //6
cout << f2(4,2) << endl;  //2
cout << f3(4,2) << endl;  //8
```

则：

```c++
map<string,function<int(int,int)> binops;
map["+"] = add; map["/"] = div(); map["*"] = [](int a,int b) { return a*b; };
binops["+"](4,2);		//调用add(4,2);
binops["/"](4,2);
binops["*"](4,2);
```

详见 p513





###	9.重载，类型转换与运算符

>​	在构造函数章节中，我们看到由一个实参调用的非显式构造函数（non-explicit one argument constructor aka.convert constructor）。这种构造函数将实参类型转换为类类型。
>
>​	我们同样可以定义对于类类型的类型转换，通过定义类型转换运算符可以做到这一点。

1. 转换构造函数和类型转换运算符共同定义了类类型转换`class-type conversions`，这样的转换也被称为用户定义的类型转换`user defined conversions`



####	1.类型转换运算符

> ​	类型转换运算符`conversion operator`是类的一种特殊成员函数，它负责将一个类类型的值转换为其他类型。形式如下：
>
> ​			operator `type`() const;

1. **一个类型转换函数必须是成员函数，且不能声明返回类型，形参列表也必须为空，类型转换函数通常是const的，并且返回一个对于类型的值**

   

2. **避免过度使用类型转换函数，类型转换运算符可能产生意外结果、**

   ​	在早期版本的c++中，如果类定义了一个向bool的类型转换，则它常常遇到一个问题：因为bool是一种算术类型，所以类类型的对象转换成bool后就能被用在任何需要算术类型的上下文中。则会出现意外结果，如：

   ```c++
   int i = 10;
   cin << i;		//合法！cin将转换为bool类型，然后发生整型提升（为0或1）,再进行算术运				//算向左移10位!
   ```

   为了防止这种情况，引入了`explicit conversion operator`

   

3. **显示类型转换运算符`explicit conversion operator `.C++11**

   1. 使用关键字`explicit`

      ```c++
      struct K{
          double val;
          K(int val):val(val) {}
          explicit operator int() const { return val; }
      };
      K obj = 3;
      auto x = si + 3;						//错误
      auto y = static_cast<int>(si) + 3;		//正确
      ```

      

   2. **使用explicit后仍会有个例外，当表达式用于条件时，编译器会把显式的类型转换自动应用于它**

      ```c++
      struct K{
          int val;
          K(int val):val(val) {}
          explicit operator bool() const { return val > 0; }
      };
      K obj = 3;
      if(obj) cout << "自动了！" << endl;
      ```

      

   3. **向bool的类型转换通常用在条件部分，因此operator bool 一般定义成explicit的**



####	2.避免有二义性的类型转换

> ​	如果类中包含一个或多个类型转换，必须确保在类类型和目标类型之间只存在唯一 一种转换方式，否则，我们编写的代码将很可能产生二义性。
>
> ​	两种情况:
>
> ​		第一种是两个类提供了相同的类型转换，如：A类定义了一个接受B类对象的转换构造函数，同时B类定义了一个转换目标是A类的类型转换运算符，则提供了相同的类型转换
>
> ​		第二种是类定义了多个转换规则，而这些转换涉及的类型本身可以通过其他类型转换联系在一起，最典型的列子是算符运算符。最好只定义最多一个和算术类型有关的转换规则



**不要为类定义相同的类型转换，也不要在类中定义两个及两个以上转换源或转换目标是算术类型的转换**

1. 实参匹配和相同的类型转换
2. 转换目标为内置类型的多重类型转换

**详见p519**



**重载函数遇到转换构造函数**

​	如：

```c++
struct C{
    C(int);
}
struct D{
    D(int);
}
void manip(const C&);
void manip(const D&);
manip(10);
```



1. 重载函数与转换构造函数

   >如果两个或多个类型转换都提供了同一种可行匹配，则这些类型匹配一样好

2. 重载函数与用户定义的类型转换

   > 如果两个或多个用户定义的类型都提供了可行匹配，则我们认为这些类型转换一样好，在这个过程中，我们不会考虑任何可能出现的标准类型转换的级别



![image-20230228192704964](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230228192704964.png)



####	3.函数匹配与重载运算符

> 重载了某些算术运算符，要注意：

1. 表达式中运算符的候选函数集既应该包含成员函数，也应该包含非成员函数
2. 如果我们对同一个类提供了转换目标是算术类型的类型转换，也提供了重载的运算符，则很可能会遇到重载运算符和内置运算符的二义性问题



![image-20230228194931641](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230228194931641.png)



##	五.面向对象程序设计

> ​	C++中的object-oriented programming 的核心思想是数据抽象，继承和动态绑定；使用数据抽象，我们可以将类的接口与实现分离；使用继承，可以定义相似的类型并对关系建模；使用动态绑定，可以在一定程度上忽略相似类型的区别

- 继承	inheritance
- 基类    base class
- 派生类   derived
- 虚函数   virtual function
- 类派生列表   class derivation list
- 覆盖  override  C++11
- 动态绑定  dynamic binding 
- 运行时绑定  run-time  binding



###	1.定义基类和派生类



####	1.定义基类

1. 基类通常都应该定义一个虚析构函数，即使该函数不执行任何实际操作也使如此
2. 任何除了构造函数之外的非静态函数都可以是虚函数，关键字virtual只能出现在类内部的声明语句之前不能用于类外部的函数定义，如果基类把一个函数声明为虚函数，则在其派生类中该函数隐式地也是虚函数
3. 受保护的protected



####	2.定义派生类

1. C++11允许derived class 显式地注明它使用某个成员函数覆盖了它继承的虚函数，做法是在形参列表后面，或是const后面，或是引用限定符后面添加一个关键字：override

   

2. 在派生类对象中含有相应的基类部分，这一事实是继承的关键所在，也是隐式的派生类到基类`derived to base`的类型转换的原因

3. **派生类不能直接初始化基类成员，必须用基类的构造函数来初始化基类部分**，既每个类控制自己的成员初始化过程，**且初始化的过程是由内而外；**首先初始化基类的部分，任何在按照声明顺序依次初始化派生类的成员。

4. 虽然derived class 对象不能直接初始化基类的成员，但是我们可以在派生类构造函数函数体中给基类成员赋值，但是最好不要这么做。

5. 静态成员独立于对象之外，不论派生出多少个派生类，对于每个静态成员来说都只存在唯一实例，如果静态成员是可访问的，那么我们即可通过基类也能通过派生类来使用它

   ```c++
   class A{
   public:
       static int si;
   };
   
   class B : public A {};
   
   B::si;		//ok
   A::si;
   ```

   

6. 声明不能包含派生列表，如果我们想将某个类用作基类，则该类必须已经定义而非声明。这项规定还隐含了一个类不能派生它本身的意思。

7. 一个类既可以是基类也可以是派生类，即多层继承关系，引出术语：直接基类`direct base`, 间接基类`indirect base`

8. 防止继承的发生，可以在类名后面追加关键字**final** c++11



####	3.类型转换与继承

> **定义基类**

1. 基类通常都应该定义一个虚析构函数，即使该函数不执行任何实际操作也使如此
2. 任何除了构造函数之外的非静态函数都可以是虚函数，关键字virtual只能出现在类内部的声明语句之前不能用于类外部的函数定义，如果基类把一个函数声明为虚函数，则在其派生类中该函数隐式地也是虚函数
3. 受保护的protected



> **定义派生类**

1. C++11允许derived class 显式地注明它使用某个成员函数覆盖了它继承的虚函数，做法是在形参列表后面，或是const后面，或是引用限定符后面添加一个关键字：override

2. 在派生类对象中含有相应的基类部分，这一事实是继承的关键所在，也是隐式的派生类到基类`derived to base`的类型转换的原因

3. **派生类不能直接初始化基类成员，必须用基类的构造函数来初始化基类部分**，既每个类控制自己的成员初始化过程，**且初始化的过程是由内而外；**首先初始化基类的部分，任何在按照声明顺序依次初始化派生类的成员。

4. 虽然derived class 对象不能直接初始化基类的成员，但是我们可以在派生类构造函数函数体中给基类成员赋值，但是最好不要这么做。

5. 静态成员独立于对象之外，不论派生出多少个派生类，对于每个静态成员来说都只存在唯一实例，如果静态成员是可访问的，那么我们即可通过基类也能通过派生类来使用它

   ```c++
   class A{
   public:
       static int si;
   };
   
   class B : public A {};
   
   B::si;		//ok
   A::si;		//ok
   ```

6. 声明不能包含派生列表，如果我们想将某个类用作基类，则该类必须已经定义而非声明。这项规定还隐含了一个类不能派生它本身的意思。

7. 一个类既可以是基类也可以是派生类，即多层继承关系，引出术语：直接基类`direct base`, 间接基类`indirect base`

8. 防止继承的发生，可以在类名后面追加关键字**final** c++11



> **类型转换与继承**



**1.静态类型和动态类型**

​		必须把一个变量或表达式的静态类型`static type`和该表达式表示对象的动态类型`dynamic type`区分开来。

- **静态类型：**
  - 在编译时是已知的
  - 是变量声明时或表达式生成的类型
- **动态类型：**
  - 运行时才可知
  - 是变量或表达式所表示的内存中的对象的类型
- 如果表达式既不是指针也不是引用，则它的static type 和 dynamic type永远一致，相反的，如果表达式是基类的指针或引用，则static type 和 dynamic type 可能不一致



**2.不存在基类向派生类的隐式类型转换**

1. 派生类可能含

2. 有基类中不存在的成员，如果可以转换，我们会使用基类中不存在的成员

3. 一种情况，即使一个基类指针或引用绑定在派生类对象上，也不能执行基类往派生的转换，如：

   ```c++
   //A是B的基类
   B b;
   A *pa = &b;
   B *pb = a;		//错误
   ```

   如果我们确定基类向派生类的转换是安全的，我可以使用static_cast来强制覆盖掉编译器的检查工作

   ```c++
   B *pb = static_cast<B*>(pa);	//正确
   ```

**3.在对象之间不存在类型转换**

​	派生类向基类的自动转换只对指针或引用有效，在普通类型中不存在这样的转换。虽然很多时候我们确实希望把派生类对象转换为它的基类类型，但是会出现不好的现象



**4.当我们使用一个派生类对象为一个基类对象初始化或赋值时，只有该派生类对象中的基类部分会被拷贝，移动或赋值，它的派生类部分将被忽略掉，如：**

```c++
B bobj;
A aobj(bobj);
aobj = bobj;
//被称为切断
```



![image-20230302193242380](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230302193242380.png)



###	2.虚函数



> ​	OOP的核心思想是多态性。我们把具有继承关系的多个类型称为多态类型，因为我们能使用这些类型的多种形
>
> 式而无须在意它们的差异。引用和指针的静态类型`static type`和动态类型`dynamic type`不同这一事实正是C++语言支持多态性的根本所在。



1. 当且仅当对通过指针或引用调用虚函数时，才会在运行时解析该调用，也只有在这种情况下对象的动态类型才有可能与静态类型不同

2. 在派生类中覆盖了某个虚函数，可以再一次使用virtral关键字指出该函数的性质。一个派生类的函数如覆盖了某个继承而来的虚函数，则它的形参类型必须与被它覆盖的基类函数完全一致

   

3. final和override

   - final：如果在不是virtual funciton后添加了final关键字，将会报错

   - override：如果覆写带有override的virtual function，将会报错

     

4. 如果虚函数使用默认实参，则基类和派生类中定义的默认实参最好一致

   

5. 回避虚函数的机制：我们希望对虚函数不要进行动态绑定，可以使用作用域运算符实现这一目的，如：

   ```c++
   struct A{
       virtual void fun() { cout << "111" << endl; }
   };
   
   struct B : A{
       void fun() override { A::fun(); cout << 222 << endl; }
   
   };
   
   B bobj;
   A *pa = &bobj;
   pa->fun();
   //输出
   //111
   //222
   ```

   ​	通常情况下，只有成员函数或友元中的代码才需要使用作用域运算符来回避虚函数的机制。即一个派生类的虚函数调用它覆盖的基类虚函数版本时。在此情况下，基类的版本通常完成继承层次中所有类型都要做的共同任务，而派生类中定义的版本需要执行一些与派生类本身相关的操作



###	3.抽象基类



> **纯虚函数** `pure virtual`

​	我们在函数体位置（分号之前）书写=0就可以将一个虚函数说明为纯虚函数，其中=0只能出现在类内部的虚函数声明语句处



> 含有纯虚函数的类是**抽象基类**`abstract base class`

​		含有（或者没有覆盖直接继承）纯虚函数的类是抽象基类`abstrack base class`

> **不能创建抽象基类的对象**



> **派生的构造函数只初始化它的直接基类**





###	4.访问控制和继承



> ​	**受保护的成员`protected`的一条重要性质：派生类的成员或友元只能通过派生类对象(this也是)来访问基类成员。派生类对于一个基类对象中的受保护成员没有任何访问特权**

​	如：

```c++
class A{
protected:
    int val = 111;
};

class B : public A{
public:
    void fun(A& a) { cout << a.val << endl; }	//错误
    friend void fun2(B&);						//ok
};
void fun2(B& b){
    cout << b.val << endl;
}
```





> **公有，私有和受保护继承**

​	**重点：派生访问说明符的目的是控制派生类的用户（包括派生类的派生类）对于基类成员的访问权限，而派生类的成员(及友元)能否访问其直接基类成员只与基类中的访问说明符有关。**



> **派生类向基类转换的可访问性**

​	如果基类的**公有成员**是可访问的，**则派生类向基类的类型转换也是可以访问的**；反之不行。

​	既：

1. 只有是公有继承，派生类的用户才能向基类转换

2. 无论是什么继承，派生类的成员函数和友元可以使用派生类向基类转换（派生访问说明符不对派生类的成员产生影响）

3. 如果是公有或受保护的继承，则派生类的派生类的成员和友元可以使用直接基类向间接基类的类型转换，如果是私有则不行。

   以上规则和前面的重点紧密相关





> **不能继承友元关系；每个类负责控制各自成员的访问权限**



> **使用`using`改变个别成员的可访问性**

如：

```c++
class A{
public:
    int a;
};

class B : protected A{
public:
    using A::a;			//在public:下使用的using，就将a重新设为public的
    					//a必须可以访问才能使用using
};

B b;
cout << b.a << endl;
```





> **默认的继承保护级别**

​	struct 和 class 定义的类只在默认成员访问说明符及默认派生访问说明符有差异，除此之外，再无不同之处

1. class：默认private成员，private继承
2. struct：默认public成员，public继承









###	5.继承中的类作用域

1. 派生类的作用域嵌套在基类之内

   

2. 在编译时进行名字查找

   ​	一个对象，引用或指针的静态类型`static type`决定了该对象的哪些成员是可见。即使静态类型和动态类型可能不一致，但我们能使用哪些成员仍然由静态成员决定

   ```c++
   class A{
   public:
       int a;
   };
   
   class B : public A{
   public:
       int b;
   };
   
   B b;
   A* pa = &b;
   cout << pa->b << endl;		//错误
   //编译时进行名字查找,可用的成员仍由静态类型决定！
   
   ```

3. 名字冲突与继承

   - 派生的成员将隐藏同名的基类成员

   - 可用通过作用域运算符来使用隐藏的成员

   - 除了覆盖继承而来的虚函数，派生类最好不要重用其他定义在基类中的名字

   - 一如往常，名字查找先于类型检查

     - 和p210所说的同样，定义在内层作用域的函数不会重载声明在外层作用域的函数。因此，定义派生类的函数不会重载其基类中的成员。
     - 如果派生类的成员与基类的某个成员，则派生类将在其作用域内隐藏该基类成员。即使形参不一致，仍然会被隐藏掉。

   - 现在我们理解了为什么派生类和基类中的虚函数必须有相同的形参列表了，如果不一样，我们无法通过基类的引用或指针调用派生类的虚函数了。（派生类没有覆盖基类虚函数）

     ```c++
     class A{
     public:
         virtual int fun() { return 1; }
     };
     
     class B : public A{
     public:
         int fun(int x) { return x; }	//并没有覆盖
     };
     
     B b;
     A *pa = &b;
     pa->fun(2);		//错误，太多参数
     //此fun仍然是基类的，也可以说是基类的函数隐藏了派生类的函数。
     ```

   - 覆盖重载的函数

     - 虚函数同样可以重载，派生类可以覆盖重载函数的零个或多个实例

     - 如果派生类希望所有重载版本对于它都是可见的，那么它就需要覆盖所有版本，或者一个也不覆盖

     - 如果仅需要覆盖重载中的某一个，全部覆盖每一个版本将过于繁琐。解决方案是使用using声明语句。

       ```c++
       class A{
       public:
           virtual int fun() { return 2; }
           virtual int fun(int x) { return x; }
           virtual int fun(int x,int y) { return x+y; }
       };
       
       class B : public A{
       public:
           //using A::fun;
           int fun(int x,int y) override { return x*y; }
           void check() { cout << fun() << endl;} //错误
           //fun()的参数太少,fun(int,int)隐藏了基类的另外两个fun的重载	 //函数
       };
           
       ```



###	6.构造函数和拷贝控制



####	1.虚析构函数

​		当我们delete一个动态分配的对象的指针将执行析构函数，如果指针指向继承体系的某个类型，则很有可能出现指针的静态类型和被删除对象的动态类型不相同的情况。

- 将基类中的析构函数定义为虚构函数保证执行正确的析构函数版本
- 如果基类的析构函数不是虚函数，则delete一个指向派生对象的基类指针将出现未定义的行为
- 在之前所讲的三/五法则中，说如果一个类需要析构函数，那么它也同样需要拷贝和赋值操作。基类的析构函数并不遵循上述准则。基类总是需要析构函数，而且它能将析构函数设定为虚函数
- 虚析构函数将阻止合成移动操作，影响基类和派生类



####	2.合成拷贝控制与继承

​		继承体系下的类的合成拷贝成员和普通类的差不多一致

p579



![image-20230302214440791](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230302214440791.png)

​		大多数基类会定义一个虚析构函数，因此在默认情况下，基类通常不包含有合成版本的移动操作，且它的派生类也没有

​		如果基类需要移动操作，则它应该需要显式的定义这些成员。一旦基类定义了自己的移动操作，那么它必须显式的定义拷贝操作（因为合成拷贝操作被删除）





####	3.派生类的拷贝控制成员

​		

- 派生类需要负责初始化基类的成员。派生类的析构函数只负责销毁派生类自己分配的资源。

- 当派生类定义了拷贝或移动操作时，该操作负责拷贝或移动包括基类部分成员在内的整个对象

- 在默认情况下，基类默认构造函数初始化派生类对象的基类部分，如果我们想自定义或拷贝或移动基类部分，必须在派生类的构造函数初值列`initialized list`显式使用基类的拷贝或移动构造函数

- **派生类的赋值运算符**

  ![image-20230302215454030](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230302215454030.png)

- **派生类的析构函数**![image-20230302215602691](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230302215602691.png)

- **在构造函数或析构函数调用某个虚函数，我们应该执行与构造函数或析构函数所述类型相对应的虚函数版本**

  ![image-20230302215807796](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230302215807796.png)

​	



####	4.继承的构造函数

> ​	类不能继承默认，拷贝和移动构造函数。





​	继承的构造函数的特点

![image-20230302220348687](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230302220348687.png)

















#	动态内存

> 我们的程序目前使用过的区域有静态内存，栈内存和堆内存
>
> - 静态内存：保存局部`local`static对象，类static成员（non-local static）以及定义在函数之外的变量，由编译器自动创建和销毁。
> - 栈内存：保存函数内的非static对象，由编译器自动创建和销毁
> - 堆内存：存储动态分配`dynamically allocate`的对象，不会自动销毁，由程序控制，必须显式销毁



###	1.动态内存和智能指针

> 在旧标准，我们使用new和delete进行动态管理
>
> new和delete需要注意：
>
> - **new 和 delete 要成对出现，如果new[]，则delete[]**
> - **delete 不是 new 出来的内存，行为未定义**
> - **delete 在栈区的内存，行为未定义**
> - **delete 两次同样的内存，行为未定义**
> - **delete后，指针变为空悬指针，解引用空悬指针是未定义的。需要把指针至空**
> - **野指针：指针没由初始化**
> - **没有delete new出来的内存，会造成内存泄漏**
>
> 可以看到，传统的方式非常容易出问题，极难排错。故引入新标准的指针指针



智能指针`smart pointer`，c++11提供两种：shared_ptr和unique_prt智能指针,还有一个伴随类：weak_ptr。



####	1.shared_ptr类



- 默认初始化的智能指针中保存一个空指针

- make_shared函数

  ```c++
  shared_ptr<int> p1 = make_shared<int>(111);
  auto p2 = make_shared<string>("abc");
  auto p3 = make_shared<int>();				//值初始化
  //args类似emplace，需要匹配构造函数  
  ```

  

- shared_ptr的拷贝和赋值

  每个shared_ptr都有一个关联的计数器，即引用计数`reference count`

  ```c++
  auto p1 = make_shared<string>("abc");
  auto p2 = p1;
  cout << p2.use_count() << endl;	//2
  cout << p1.use_count() << endl;	//2
  ```

  

- shared_ptr自动销毁所管理的对象,并自动释放相关联的内存

  

- 

  ​	1.当引用计数为0时，shared_ptr调用析构函数销毁对象，并释放内存

  ​	2.如果将shared_ptr存放于一个容器中，然后不再需要全部内存，而只使用其中一部分，要记得erase删除不需要的元素；如果不删除，引用计数一直不为0，就不会释放内存，虽然最后还是会释放，但这造成了内存的浪费

- 程序使用动态内存出于以下三种原因：

  - 程序不知道自己需要使用多少对象
  - 程序不知道所需对象的准确对象（多态）
  - 程序需要多个对象间共享数据

- 



####	2.直接管理内存

- 使用new动态分配和初始化对象

- **用new分配const对象是合法的**

  ```c++
  const int *pci = new const int(1024);
  const string *pcs = new const string;
  ```

- **内存耗尽**

  - 如果new分配失败，new抛出std::bad_alloc

  - 加上nothrow

    ```c++
    int *p = new (nothrow) int;	//placement new
    ```

    如果分配失败，new返回一个空指针。这种形式的new为定位new，定位new表达式允许我们向new传递额外的参数。

- **释放一个空指针是没有错误的**

- **const对象可以被销毁，即可以delete const动态对象**

  ```c++
  const int *pci = new const int(1024);
  delete pci;		// delete 做了转型动作  const_cast<this*>
  ```

- **delete之后重置指针值为nullptr，但这只是提供了有限的保护**

  当有多个指针指向同一对象时，只重置一个指针，其他指针仍然指向该对象

  ```c++
  int *p(new int(42));
  autp q = p;
  delete p;
  p = nullptr;			//q仍然是空悬指针
  ```

  







####	3.shared_ptr和new结合使用

> **如前面所述，如果我们不初始化一个智能指针，它就会被初始化为一个空指针。我们还可以用new返回的指针来初始化智能指针**



- 接受指针参数的智能指针构造函数时emlicit的，因此我们**不能**将一个内置指针**隐式转换**为一个智能指针，**必须使用直接初始化**。

  ```c++
  shared_ptr<int> p1 = new int(1024);		//错误，必须使用直接初始化形式
  shared_ptr<int> p2(new int(1024));		//正确
  
  shared_ptr<int> clone(int p){
      return new int(p);					//错误：隐式转换为shared_ptr<int>
  }
  shared_ptr<int> clone(int p){
      return shared_ptr<int>(new int(p));	//正确
  }
  ```

  p = shared_ptr, u = unique_ptr, q = 内置指针

  ![image-20230307101618479](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230307101618479.png)

- 不要混合使用普通指针和智能指针

  如：

  ```c++
  void process(shared_ptr<int> ptr){
      ...
  }
  
  int *x = new int(1024);
  process(x);						//错误，不能将x隐式转换为shared_ptr<int>
  process(shared_ptr<int>(x));    //合法，但内存被释放
  int i = *x;						//未定义，x是个空悬指针
  ```

  ​	**当将一个shared_ptr绑定到一个普通指针时，我们就把内存的管理责任交给了这个shared_ptr;一旦这么做了，我们就不应该再使用内置指针来访问shared_ptr所指向的内存了**

  ​	**使用一个内置指针来访问一个智能指针所负责的对象时很危险的，因为我们无法知道对象何时会被销毁**

- 不要使用get初始化另一个智能指针或为智能指针赋值

- ![image-20230307104827832](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230307104827832.png)

- reset函数

  ![image-20230307104854163](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230307104854163.png)

- 



####	4.智能指针和异常

- 使用自己的释放操作

- 智能指针陷阱

  - **不使用相同的内置指针值初始化或reset多个智能指针值；**		

    当智能指针自动释放时，原内置指针变为空悬指着。并且如果初始化的是share_ptr，会造成多次delete等问题（具体见modern 条款19）

  - **不delete get() 返回的指针**

    所有指向该对象的智能指针变为空悬，而且还会二次delete

  - **如果指针指针管理的资源不是new分配的内存，记住传递给它一个删除器**

p443



####	5.unique_ptr















****







#	模板和泛型编程





###	定义模板



####	1.函数模板 function template



- template<>  ，<>里面是模板参数列表 **`template parameter list`**, 这是由逗号分隔的一个或多个模板参数

  

- 在模板的定义中，模板参数列表不能为空

  

- 使用模板时，我们隐式或显式地指定模板实参`template argument`

  

- 调用函数模板时，编译器通常用函数实参来为我们推导模板实参

  

- 模板的参数列表：

  - 类型参数 `type parameter`

  - **非类型参数**`notype parameter`

    非类型参数被一个用户提供或编译器推到出的值所代替。这些值**必须是常量表达式**，从而允许编译器在编译时实例化模板

    ```c++
    template<unsigned N,unsigned M>
    bool compare(const char (&p1)[N], const char(&p2)[M]) {
        return strcmp(p1,p2);
    }
    compare("hi","mom");	//编译器deduction值，实例化
    ```

    或

    ```c++
    template<size_t N, size_t M>
    void print(const int *p){
        for(size_t i = N; i < M; ++i)
            cout << *(p + i) << ' ';
        cout << endl;
    }
    print<0,10>(arr);
    ```

- 函数模板可以是inline和constexpr

  ```c++
  template<typename T>
  inline T min(const T&,const T&);
  ```

- 模板应该尽量减少对实参类型的要求

1

- 模板的编译

  - 当编译器遇到一个模板定义时，它并不生产代码。只有当我们实例化一个模板的特定版本时，编译器才会生成代码。即当我们使用（而不是定义）模板时，编译器才生成代码

    

- 函数模板和类模板成员函数的定义通常放在头文件中

![image-20230313175040212](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230313175040212.png)

- 大多数的模板编译错误出现在实例化期间

  - 第一阶段：编译模板本身，编译器可以检查语法错误；如忘记分号，名字打错

  - 第二阶段：编译模板的调用时，编译器可以检查参数数目，类型匹配错误

  - 第三阶段：编译模板实例化，可能在链接时才报错，编译器才能检查关于类型的错误

    

- 保证传递给模板的实参支持模板要求的所有操作，以及这些操作在模板中能正确工作，时调用者的责任



####	2.类模板 class template



- 编译器不能为类模板推导模板参数类型，为了使用类模板。我们必须在类名后面的尖括号内显式的提供类型参数

- 显式模板实参`explicit template argument`

- 类模板的成员函数

  成员函数如下：

  ```c++
  template<typename T>
  ret-type A<T>::member-name(parm-list)
  ```

  

- 类模板的构造函数

  如：

  ```c++
  template<typename T>
  Ac<T>::Ac(initializer_list<T> il) : data(....) { }
  ```

  

- 类模板的成员函数的实例化

  默认情况下，一个类模板版的成员函数只有当程序用到它时才进行实例化

  

- **在类内代码简化模板类名的使用**

  ```c++
  template<typename T>
  struct A{
      A fun() { return A(); }
  };
  //不用写 A<T> fun() {}
  ```

  

- 在类模板外使用类模板名

  ```c++
  template<typename T>
  Ac<T> Ac<T>::operator++(int){
      ....
  }
  ```

  

- 类模板和友元   p615

  - 非模板友元：该友元可以访问所有模板实例

  - 友元自身是模板：

    - 将模板的每一个实例都声明为自己的友元

      ```c++
      template <typename T> class Pal;
      template <typename T>
      class C{
          friend class Pal<T>;	//C的每一个实例都将相同实例化的Pal声明为友元
          template <typename X> friend class Pa2;
          //Pal2的所有实例都是C的每个实例的友元，不需要前置声明
      }
      ```

      

    - 将模板特定的实例声明为自己的友元

      ```c++
      template <typename T> class Pal;
      class C{
          friend class Pal<C>;	//用类C实例化的Pal是C的一个友元
          template <typename T> friend class Pal2;
          //Pal2的所有实例都是C的友元，不需要前置声明
      }
      ```

  - 令模板自己的类型参数成为友元  C++11

    ```c++
    template <typename T> class Bar{
        friend T;
    }
    ```

    即使T是内置类型，这种友好关系也是允许的

    

- 模板类型别名

  P616

  ```c++
  template<typename T> using ptt = pair<T,T>;
  ptt<string> authors;	//authors是pair<string,string>
  ```

  

- 类模板的static成员

  每一个类模板的实例都有自己的static成员实例；

  ```c++
  struct A{
      static int si;
  };
  ```

  定义static成员时，和类模板函数类似，我们将static数据成员也定义为模板

  ```c++
  template<typename T>
  int A<T>::si = 0
  ```

  和非模板类类似，我们可以通过类或者是对象直接访问成员，使用类直接访问必须使用特定的类实例

  ```c++
  A<int>::si;
  A::si;	//错误；使用哪一个模板实例的si?
  ```

  





####	3.模板参数



- 模板参数和作用域

  **模板参数会隐藏外层作用域中声明的相同名字**

  ```c++
  typedef double A;
  template <typename A, typename B> void fun(A a,B b){
      A tmp = a;	//tmp的类型是模板参数A的类型，不是double
  }
  ```

  **模板参数名不能重复**

  

- 模板声明

  声明中的参数名字不必与定义中相同

  

- 使用类的类型成员

  对于模板代码，**假定有个模板参数T，编译器不知道`T::mem`中的mem是个类型名字，还是static成员或成员函数**。直到实例化才知道。但是为了处理模板，编译器必须知道，如：

  ```c++
  T::size_type *p;
  ```

  **默认下，C++假定它是个成员；**

  **如果希望编译器知道它是个类型名字，必须显式的告诉它。通过关键字typename**

  

- 默认模板实参 `default template argument`

  

- 模板默认实参和类模板

  **实例化时，必须加<>**

  ```c++
  template <typename T = int>
  struct A{
      T val;
  };
  A<> a;			//空<>表示我们希望使用默认实参
  ```

  

####	4.成员模板  member template

成员模板不能是虚函数

- 普通（非模板）类的成员模板

  

- 模板类的成员模板

  通常，模板类的构造函数会被定义为类的成员模板，使得构造函数可以接受多种可行参数，以此增加弹性。	

​	

####	5.控制实例化



- 显式实例化，使用extern

  

- 实例化定义会实例化所有成员

  确保成员全部能实例化





####	6.效率于灵活性  p625



- shared_ptr，在运行时绑定删除器，使用用户重载删除器更加方便
- unique_ptr，在编译时绑定删除器，避免了间接调用删除器的运行时的开销

​	



##	模板实参推断

> 从函数实参来推断模板实参的过程被称为模板实参推断`template argument deduction`



####	1.类型转换与模板类型参数

对于函数模板，只有几种类型转换会自动适应。编译器通常不对实参进行类型转换，而是生成一个新的模板实例

- **与往常一样，顶层const无论是在形参还是在实参中，都可以被忽略**

- **const转换：可以将一个非const对象的引用或指针传递给一个const的引用或指针形参（删除底层const）**

- 数组或函数指针的转换：如果函数形参**不是引用**类型，则可以对数组或函数类型的实参应用正常的指针转换

  ```c++
  template <typename T>
  void fun1(T param);
  
  const char c_str[] = "abc";
  fun1(c_str);				// T被推导为const char*
  
  template <typename T>
  void fun2(T& param);
  
  fun2(c_str);				// T被推导为 const char [4]
  ```

  

**算术转换，派生类向基类的转换以及用户定义的转换都不能用于函数模板**

```c++
template <typename T> T fobj(T, T);
template <typename T> T fref(const T&, const T&);

string s1;
const string s2;

fobj(s1,s2);			//正确，忽视了顶层const

int a[10], b[10];	
	
fobj(a,b);				//正确，数组向指针的转换
fref(a,b);				//错误，模板参数是引用


```



![image-20230314174121662](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230314174121662.png)



- 如果函数参数类型不是模板参数，则对实参进行正常的类型转换






- 不同模板参数的实参类型可以一样：

  ```c++
  template <typename T1, typename T2> void fun(T1, T2);
  int *p1, *p2;
  fun(p1,p2);			//正确，T1和T2都被推导为int*
  ```

  



####	2.函数模板显式实参

> 在某些情况下，编译器无法推断出模板实参的类型。其他的一些情况下，我们希望允许用户控制模板实例化。当函数返回类型与参数列表中的任何类型都不相同时，这两种情况最常出现

- 指定显式模板实参

  ```c++
  template <typename T1, typename T2, typename T3>
  T1 sum(T2,T3);
  ```

  没有任何函数实参类型可以用来推断T1的类型，每次调用sum时调用者都必须为T1提供一个显式模板实参`explicit template argument`

  ```c++
  auto val = sum<long long>(i,lng);	
  ```

  显式模板实参按由左到右的顺序与对应的模板参数匹配：第一个模板参数与第一个模板参数匹配，第二个实参与第二个参数匹配，以此类推。只有右边参数的显式模板实参可以忽略，由函数参数推断出来。（类似函数的默认参数）

  ```c++
  template <typename T1, typename T2, typename T3>
  T3 sum(T2,T1);				//糟糕的设计
  
  auto val = sum<int,long,long long>sum(i,lng);		//T3在最后面，且不能被推导，故显式实参必须写													//到T3
  ```

  

- 正常的类型转换应用于显式指定的实参

  ```c++
  int a;
  double b;
  max<int>(a,b);		// b会被类型转换为int
  ```

  





####	3.尾置返回类型与类型转换

> **在有些情况下，要求显式指定模板实参会给用户增添额外负担**

```c++
template <typename It>
??? &fun(It beg, It end){
    return *beg;
}
```

使用尾置返回类型：



![image-20230315125608694](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230315125608694.png)

```c++
template <typename It>
auto fun(It beg, It end) -> decltype(*beg){
    return *beg;
}
```



- **进行类型转换的标准库模板类**

  由于decltype总是推导返回左值的表达式为引用类型，故有时候我们无法直接获得所需要的类型。例如：我们希望编写类似fun的函数，但是返回一个元素的值而非引用

  为了获取元素类型，我们可以使用标准库的类型转换（type transformation）模板。这些模板定义在头文件type_traits中。这些模板定义在头文件type_traits中。此头文件的类通常用于所谓模板元编程设计，已经超出范围。

  使用remove_reference

  ```c++
  template <typename It>
  auto fun(It beg, It end) -> typename remove_reference<decltype(*beg)>::type{
      return *beg;
  }
  ```

  

- 标准类型转换模板

  ![image-20230315131650174](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230315131650174.png)

每个模板都有一个名为type的public成员，表示一个类型。此类型与模板自己的模板类型参数有关。如果不能转换模板参数，则type成员就是模板参数本身。







#### 4.函数指针和实参推断

p633





####	5.模板实参推断和引用

> 编译器会应用正常的引用绑定规则：**const是底层的，不是顶层的**



- **从左值引用函数参数推断类型**

  如果一个函数模板的函数参数是一个普通（左值）引用时，绑定规则告诉我们，只能传递给它一个左值。实参可以是const，也可以不是。如果实参是const的，则T将被推断为const类型

  ```c++
  template <typename T> void fun(T&);
  fun(i);		//正确, T为int
  fun(ci);	//正确，T为const int
  fun(5);		//错误，传递给&参数的实参必须是左值
  ```

​		**注意：如果一个函数参数的类型是const T&，当函数参数本身是const时，T的类型推断的结果不会是一个const类型，const已经是函数参数的一部分**

​		![image-20230315150821915](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230315150821915.png)



- **从右值引用函数参数推断类型**

  ```cpp
  template <typename T> void fun(T&&);
  fun(42);	//T为int
  ```

  

- **引用折叠和右值引用参数**

  对于普通的函数不同，template在正常绑定规则之外定义了两个例外规则，这两个例外规则是move这种标准库设施正确工作的基础

  - **第一个例外影响右值引用参数的推断的进行**

    ```c++
    template <typename T> void fun(T&&);
    int rval = 1;
    fun(rval);	//正确！T被推断为int& !
    ```

    T被推断为int&，看起来好像意味着fun函数的参数是一个int&类型的右值引用。

    通常，我们不能直接定义一个引用的引用，但是，通过类型别名或通过模板类型参数间接定义是可以的

    

  - **第二个例外规则：如果我们间接创建一个引用的引用，则这些引用形成了`折叠`。**

    除了一个例外，引用会折叠成一个普通的左值引用类型。在C++11，折叠规则扩展到右值引用。只有在一种特殊情况下引用会折叠成右值引用：右值引用的右值引用:

    - **T& &，T& &&和T&& &都折叠成类型T&**
    - **类型T&& &&折叠成T&&**

  - 结合上面两个规则，导致了两个重要结果：

    - 如果函数参数是一个指向模板类型参数的右值引用，（如，T&&），则它可以被绑定到左值

    - 如果实参是一个左值，则推断出的模板实参类型将是一个左值引用，且函数参数将被实例化一个（普通）左值引用参数（T&，引用折叠）

      这两个规则暗示，我们可以将任意类型的实参传递给T&&类型的函数参数。对于这种类型，即可以传右值，也可以传左值

      ```c++
      template <typename T>
      T fun(T&&);
      
      fun(111);		//此时 T为int 等同于 fun<int>(int&&)
      
      int rv = 111;
      fun(rv);		//此时 T为int&, 函数的参数引用被折叠 等同于 fun<int&>(int &)
      ```

    可以说，对于函数模板参数是T&&，此时的引用可以称为**万能引用**

  

- 编写接受右值引用参数的模板函数的场景

  ![image-20230315143056519](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230315143056519.png)

  在实际中，右值引用通常用于两种情况：模板转发其实参，模板被重载



- 模板参数含有const

  - 参数显示为顶层const，不对T做const推断

    ```C++
    template <typename T>
    void fun(T);
    
    fun(i);			// fun<int>(int);
    fun(ci);		// fun<int>(int);
    ```

    ```c++
    template <typename T>
    void fun(const T);
    
    fun(i);			// fun<int>(int)
    fun(ci);		// fun<int>(int)
    ```

    

  - 所有讨论都是参数是底层const

    ```c++
    template <typename T>
    void fun(T&);
    
    fun(i);			// fun<int>(int&);
    fun(ci);		// fun<const int>(const int&);	
    ```

    

    T不会被重复推断为const

    ```c++
    template <typename T>
    void fun(const T&);
    
    fun(i);			// fun<int>(const int&)
    fun(ci);		// fun<int>(const int&)
    ```

    

    

####	6.理解std::move



在前面右值引用的学习中，我们发现有：

```c++
int& rvr = 111;
int&& lvr = std::move(rvr);
```



- std::move是如何定义的

  ```c++
  template <typename T>
  typename remove_reference<T>::type&& move(T&& t){
      return static_cast<typename remove_reference<T>::type&&>(t);
  }
  ```

  ![image-20230315152719082](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230315152719082.png)

​	现在你能明白std::move的工作原理了吗？ P637



- 从一个左值static_cast到一个右值引用是允许的

![image-20230315153606769](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230315153606769.png)





####	7.转发











![image-20230315154342675](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230315154342675.png)





##	重载和函数模板



- 函数模板对函数匹配规则的影响
  - 如果同样好的函数中只有一个是非模板函数，则选择此函数
  - 如果同样好的函数没有函数模板，而有多个函数模板，则选择更特化的那个
  - 否则，有歧义
- 当有多个重载模板对一个调用提供同样好的匹配时，应选择最特例化的版本
- 在定义任何函数前，记得声明所有重载的函数版本。这样就不必担心编译器没有遇到你希望调用的函数而具现化一个并非你所需要的版本



总结：

- 非函数模板优先
- 最特例化优先







##	模板的特化

> 有时候我们不需要太泛化，我们可以进行模板特例化 `template specialization`



**函数模板的特化**

- 函数重载与模板特化

  当定义函数模板的特化的版本，我们本质上接管了编译器的工作。即：

  ​	特例化的本质是局现化一个模板，而非重载它。因此特化不影响函数的匹配

  可以说，定义了一个非模板函数，函数匹配时会优先被选择

- 特化的函数模板丢失是很难查找的，所以模板和特例化版本应该声明在同一个头文件中。所有同名的模板的声明应该放在最前面，然后是这些特例化版本



**类模板的特化**

- 在自定义类的头文件中打开namespace std，特化hash函数，则可以使用装载自定义类对象的无序容器

  P653



**类模板的偏特化**



- 只能对类模板偏特化，不能对函数模板偏特化

  

- 基于范围上的偏特化

  type_traits里面的类模板全有偏特化版本，如：

  remove_reference

  ```c++
  template<typename _Tp>
      struct remove_reference
      { typedef _Tp   type; };
  
    template<typename _Tp>
      struct remove_reference<_Tp&>		// 对左值引用的特化版本
      { typedef _Tp   type; };
  
    template<typename _Tp>
      struct remove_reference<_Tp&&>		// 对右值引用的特化版本
      { typedef _Tp   type; };
  ```

  

- 基于数量上的偏







#	标准库特殊设施



##	tuple类型

> tuple是类似pair的模板，我们可以将tuple看作一个快速且随意的数据结构





####	1.定义和初始化tuple



- tuple的构造函数是explicit，必须使用直接初始化

  ```c++
  tuple<int,int,int> tt;		//三个成员都默认设置为0
  tuple<string,vector<double>,int,list<int>> someval("constants",{3.1,3.5},42,{0,1,2,3,4,5});		//直接初始化
  tuple<size_t,size_t,size_t> threeD = {1,2,3};	//错误，构造函数是explicit
  tuple<size_t,size_t,size_t> threeD{1,2,3};		//正确
  ```

  

- 类似make_pair函数，tuple有make_tuple

  ```c++
  auto item = make_tuple("abc",3,20.0);
  ```

  

- 使用get函数模板来访问tuple的成员

  由于tuple类型的成员数是没有限制的，因此tuple的成员都是未命名的，要访问一个tuple成员，就要使用一个名为get的标准库函数模板

  ```c++
  auto book = get<0>(item);		//返回的是引用
  ```

  

- 如果不知道一个tuple准确的类型细节信息，可以用两个辅助类模板来查询tuple成员的数量和类型

  ```c++
  typedef decltype(item) trans;
  size_t sz = tuple_size<trans>::value;		// sz = 3
  tuple_element<1,trans>::type cnt = get<1>(item);	//cnt是一个int
  ```

  

- 只有两个tuple具有相同数量的成员，且每对成员使用关系运算符都必须是合法的







####	2.使用tuple返回多个值







##	bitset类型





##	正则表达式



##	随机数





####	1.随机数引擎和分布



- 随机数引擎是函数对象类，它们定义了一个调用运算符，该运算符不接受参数并返回一个随机unsigned整数

  ​	

  ```c++
  default_random_engine e;			//生成随机无符号数
  for(int i = 0; i < 10; ++i)
  	cout << e() << ' ';
  ```

  

  

  ![image-20230319135450862](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230319135450862.png)

- 分布类型和随机数引擎

  为了得到一个指定范围内的数，我们使用一个分布类型的对象

  ```c++
  default_random_engine e;
  uniform_int_distribution<unsigned> u(0,9);		// unsigned int 可以缩写为 unsigned
  for(int i = 0; i < 10; ++i)
      cout << u(e) << ' ';
  ```

  uniform_int_distribution 此类型生成均匀分布的unsigned的值，且可以自定义最小最大值。

  分布类型也是函数对象类，分布类型定义了一个调用运算符，它接受一个随机数引擎作为参数。分布对象使用它的引擎参数生成随机数。

- 随机数发生器，是指分布对象和引擎对象的组合

  

- **一个给定的随机数发生器一直会生成相同的随机数序列。一个函数如果定义了局部的随机数发生器，应该将其（引擎和分布对象）定义为static的。否则，每次调用函数都会生成相同的序列。**

  

- **设置随机数发生器种子**

  ```c++
  default_random_engine e;
  uniform_int_distribution<unsigned> u(0,9);
  for(int i = 0; i < 10; ++i)
      cout << u(e) << ' ';
  cout << endl;
  default_random_engine e1;
  e1.seed(time(0));
  uniform_int_distribution<unsigned> u1(0,9);
  for(int i = 0; i < 10; ++i)
      cout << u1(e1) << ' ';
  ```

  





####	2.其他随机数分布



- 生成随机实数

  ```c++
  default_random_engine e;
  uniform_real_distribution<double> u(0,1);		//生成0到1的实数
  for(int i = 0; i < 10; ++i)
      cout << u(e) << endl;
  
  // 其中 uniform_real_distribution的默认模板参数是double 所以我们可以这么写
  uniform_real_distribution<> u(0,1);		// 由于只有一个模板参数，所以要写上空尖括号
  ```

  

- 生成非均匀分布的随机数

  新标准库的另一个优势是可以生成非均匀分布的随机数。定义了20中分布类型

  - 正态分布
  - bernoulli_distribution类

  p690







#	用于大型程序的工具



##	异常处理



####	1.try语句块和异常处理



在C++语言中，异常处理包括

- **throw表达式（throw expression）**，异常检测部分使用了throw表达式来表示它遇到了无法处理的问题。我们说throw引发了异常
- **try语句块（try block）**,异常处理部分使用try语句处理异常。try语句块以关键字try开始，并以一个或多个catch子句结束。try语句块中代码抛出的异常通常会被某个catch子句处理。因为catch子句处理异常，所以它们也被称为异常处理代码（exception handler）
- **一套异常类（exception）**，用于在throw表达式和相关的catch子句之间传递异常的具体信息





![image-20230319151443195](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230319151443195.png)



- 

- 函数在寻找处理代码的过程中退出

  如果没有找到任何匹配的catch子句，程序转到名为**`terminate`的标准库函数，导致程序非正常退出**

- **异常安全的函数**

  ![image-20230319152630394](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230319152630394.png)



####	2.抛出异常

当执行一个throw时，跟在throw后面的语句将不再被执行。相反，程序的控制权从throw转移到与之匹配的catch模块。该catch可能是同一个函数中的局部catch，也可能位于直接或间接发生异常函数的另一个函数中。	这意味着：

- 沿着调用链的函数可能会提早退出
- 一旦程序开始执行异常处理代码，则沿着调用链创建的对象将被销毁



- 栈展开

  ​	**如果一个异常没有被捕获，则它将终止当前的程序。调用terminate**    //abort()

  

- **栈展开过程中对象被自动销毁**

  在栈展开的过程中，位于调用链上的语句块可能会提前退出。如果在栈展开过程中退出了某个块，编译器将负责确保在这个块中创建的对象能被正确地销毁。如果是类类型，则该对象的析构函数将被自动调用

  ```c++
  struct A{
      A() { cout << "constructor" << endl; }
      ~A() { cout << "destructor" << endl;}
  };
  
  void test(){
      throw runtime_error("abc");
  }
  
  void fun(){
      try{
          A a;
          test();		// test函数中抛出异常,栈展开,调用链上的语句块提前退出,不会执行A b;且a自动被销毁
          A b;
      } catch(runtime_error err){
          cout << err.what() << " cuo wu" << endl;
      }
  }
  
  // 输出
  //constructor
  //destructor
  //abc cuo wu
  ```

  

- 析构函数和异常

  在栈展开的过程中，运行类类型的局部对象的析构函数。因为这些析构函数是自动执行的，所以它们不应该抛出异常。一旦在栈展开的过程中析构函数抛出了异常，并且析构函数自身没能捕获到该异常，则程序将被终止

  即Effective  条款08：

  - 别让异常逃离析构函数：析构函数绝对不要抛出异常。如果析构函数调用的函数可能抛出异常，析构函数应该捕获任何异常，然后处理异常或结束程序

  所有标准库类型都确保它们的析构函数不会引发异常

- 

- 异常对象

​	异常对象是一种特殊对象，编译器使用异常抛出表达式来对异常对象进行拷贝初始化。

​	异常对象位于编译器管理的空间，编译器确保无论哪种catch子句都能访问该空间。当异常处理完毕后，异常对象被销毁

​	当我们抛出一条表达式时，该表达式的静态编译时类型决定了异常对象的类型。如抛出的表达式类型来自某个继承体系：一条throw表达式解引用一个基类指针，而该指针实际指向的是派生类对象，则抛出的对象将被切掉一部分，只有基类部分被抛出





####	3.捕获异常



- **catch子句中的异常声明**
  - 如果catch无须访问抛出的表达式的话，则我们可以忽略捕获形参的名字
  - 通常情况下，如果catch接受的异常与某个继承体系有关，则最好将该catch的参数定义为引用类型（防止切割）



- **查找匹配的处理代码**

  - 越是专门的catch越应该置于整个catch列表的前端

  - 异常和catch异常声明的匹配规则受到更多限制，只允许非常量像常量的类型转换，从派生类向基类的类型转换，数组向指针的转换

  - 若多个catch语句的类型之间存在着继承关系，则我们应该把继承链最底端的类放在前面，而将继承链最顶端的类放在后面

    

- **重新抛出**

  有时候，一个单独的catch不能完整的处理某个异常。可以通过重新抛出（rethrowing）的操作将异常传递给另一个catch语句。这里的重新抛出仍然是一条throw语句，只不过不包含任何表达式

  注意一个细节：

  ```c++
  catch(my_error &eobj){
      eobj.status = errCodes::severeErr;	//修改异常对象
      throw;
  }catch(other_error eobj){
      eobj.status = errCodes::badErr;		//只修改了异常对象的副本
      throw;	//异常对象的status成员没有改变
  }
  ```

  

- **捕获所有异常的处理代码**

  ```c++
  void manip(){
      try{
          
      }
      catch(...){
          
          throw;
      }
  }
  ```

  ...表示该catch可以捕获所有异常（catch-all）

  catch(...)既能单独出现，也能与其他几个catch语句一起出现

  如果catch(...)与其他几个catch语句一起出现，则catch(...)必须在最后的位置。出现在捕获所有异常语句后面的catch语句将永远不会被匹配



####	4.函数try语句块与构造函数

通常情况下，**程序执行的任何时刻都可能发生异常**，特别是异常可能发生在处理构造函数初始值的过程中。

**想要处理构造函数初始化抛出的异常，我们必须将构造函数写成函数try语句块。**函数try语句块使得一组catch语句既能处理构造函数体，也能处理构造函数的初始化过程（析构函数同理）。如：

```c++
template <typename T>
Blob<T>::Blob(std::initializer_list<T> il) try : 
	data(std::make_shared<std::vector<T>>(il)){
        
    } catch(const std::bad_alloc &e) { handle_out_of_memory(e); }
```

注意：在初始化构造函数的参数时也可能发生异常，这样的异常不属于函数try语句块的一部分。函数try语句块只能处理构造函数开始执行后发生的异常。





####	5.noexcept异常说明

对于用户以及编译器来说，预先知道某个函数不会抛出异常显然大有好处。首先，知道函数不会抛出异常有助于简化调用改函数的代码；其次，如果编译器确认函数不会抛出异常，它就能执行某些特殊的优化操作。



- 在C++11新标准中，我们可以通过特供noexcept说明指定某个函数不会抛出异常。

  ```c++
  void recoup(int) noexcept;
  void alloc(int);
  ```

  该说明位于函数的尾置返回类型之前，const和引用限定符之后。

- **违反异常说明，程序会调用terminate以确保遵守不再运行时抛出异常的承诺**

  违法异常说明，编译器依然将顺利编译通过，不会报错；

  ```c++
  void f() noexcept{
      throw exception();	//违反异常说明
  }
  ```

  一旦违反异常说明，程序调用terminate终止运行。因此noexcept可以用在两种情况下：

  - 我们确认函数不会抛出异常
  - 我们根本不知道该如何处理异常

  ![image-20230323135715243](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230323135715243.png)

- 异常说明的实参

  - noexcept说明符接受一个可选的实参，该实参必须能转换为bool类型，如果实参是true，则函数不会抛出异常；如果实参是false，则函数可能抛出异常：

    ```c++
    void recoup(int) noexcept(true);
    void alloc(int) noexcept(false);
    ```

  - **noexcept运算符  C++11**

    noexcept operator 是一个一元运算符，用于表示给定的表达式是否会抛出异常。通常和noexcept说明符一起使用

    ```c++
    void f() noexcept(noexcept(g()));		// f和g的异常说明一致
    ```

    

- **异常说明与指针，虚函数和拷贝控制**

  - **如果一个虚函数承诺它不会抛出异常，则后续派生出来的虚函数也必须做出相同的承诺。**
  - **编译器合成拷贝控制函数时，同时也生成一个异常说明符。如果对所有成员和基类的所有操作都承诺了不会抛出异常。则合成的成员是noexcept(true)的。如果合成成员调用任意一个函数可能抛出异常，则合成的成员是noexcept(false)。**
  - **我们定义一个析构函数但是没有为它提供异常说明，则编译器会合成一个。合成的异常说明将与假设由编译器为类合成析构函数时所得的异常说明一致。**



####	6.异常类层次

![image-20230323141439364](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230323141439364.png)



- 类型exception仅仅定义了拷贝构造函数，拷贝赋值运算符，一个虚析构函数和一个名为what的虚函数。其中what函数返回一个const char*，该指针指向一个以null结尾的字符数组，并且保证不会抛出任何异常
- 类exception，bad_cast和bad_alloc定义了默认构造函数。类runtime_error和logic_error没有默认构造函数，但是有一个可以接受C风格字符串或者标准库string类型实参的构造函数。
- 实际的应用程序通常会自定义exception或是exception的标准库派生类的派生类来扩展其继承体系





##	命名空间



> 大型程序往往会使用多个独立开发的库，这些库又会定义大量的全局名字；如类，函数，模板等。多个库将名字放置全局命名空间中将引发`命名空间污染`

传统上，将定义全局的名字设置的很长来避免命名空间污染的问题。这样做不仅繁琐还不易阅读。

命名空间`namespace`为防止名字冲突提供了更加可控的机制。命名空间分割了全局命名空间，其中每个命名空间是一个作用域。



####	1.命名空间定义

- 命名空间的名字必须在定义它的作用域内唯一。命名空间既可以定义在全局作用域内，**也可以嵌套在其他命名空间内**，但是**不能定义**在**函数**或**类的内部**

- 命名空间作用域后面无须分号

  

- 每个命名空间都是一个作用域



- **命名空间可以是不连续**

  ```c++
  namespace nsp{
      ...
  }
  ```

  以上可以是定义了一个名为nsp的新命名空间，也可以是为已有的nsp命名空间添加一些新成员

- 不应该把#include放在命名空间内部，如果我们这么做了，隐含的意思是把头文件中所有的名字定义成该命名空间的成员。

- 定义命名空间成员

  

- 模板特例化

  **模板特例化必须定义在原始模板所属的命名空间中；**

  ```c++
  namespace std{
      template<> struct hash<Sales_data>;
  }
  template<> struct std::hash<Sales_data>{
     	size_t operator()(const Sales_data& s) const {
          return hash<string>()(s.bookNo)^hash<unsigned>()(s.units_sold)^hash<double>()(s.revenue); }
      }
  };
  ```

  

- 全局命名空间

  全局作用域中定义的名字（即在所有类，函数和命名空间之外定义的名字）也就是定义在全局命名空间（global namespace）中

  全局命名空间以隐式的方式声明，并且在所有程序中都存在。全局作用域中定义的名字被隐式地添加到全局命名空间中。且作用域运算符同样可以用于全局作用域的成员，如：

  ```c++
  ::member_name
  ```

  

- 嵌套的命名空间

- **内联命名空间 C++11**

  ```c++
  namespace ccc{
      inline namespace a{
          int val = 1;
      }
      namespace b{
          int val = 2;
      }
  }
  cout << ccc::val << endl;		// 输出1
  cout << ccc::b::val << endl;	// 输出2
  //内联使得命名空间中的名字可以被外层命名空间直接使用
  ```

  

- 未命名的命名空间

  未命名的命名空间中定义的名字的作用域与该命名空间所在的作用域相同。

  作用：

  可以嵌套在命名的命名空间内

  **取代文件中的静态声明（持久，隐藏）**

  



####	2.使用命名空间

像namespace_name::member_name这样使用命名空间的成员显然非常繁琐



- 命名空间的别名

  namespace alias

  ```c++
  namespace cplusplus_primer {....};
  namespace primer = cplusplus_primer;
  ```

  

- using声明

  一条using声明语句一次只引入命名空间的一个成员

  ```c++
  using std::cout;
  ```

  

- using指示

  ```c++
  using namespace std;
  // 是std的所有名字全部可见
  ```

  

- using指示与作用域

  using指示引入的名字的作用域远比using声明引入的名字的作用域复杂。

  **using指示具有将命名空间成员提升到包含命名空间本身和using指示的最近作用域的能力。**通常情况下，命名空间中会含有一些**不能出现在局部作用域的定义(如函数的定义，枚举定义)**，**因此，using指示一般被看作是出现在最近的外层作用域中**

  ```c++
  namespace n1{
      int k = 666;
  }
  
  int k = 111;
  
  void test(){
      using namespace n1;
      cout << k << endl;		//二义性，using指示将命名空间n1的所有成员提升到了全局作用域中
  }
  ```

  

​	

- 头文件和using声明或指示

  ![image-20230323210038472](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230323210038472.png)

- 





####	3.类，命名空间与作用域

- 命名空间内部名字的查找遵循常规的查找规则：由内向外依次查找每个外层作用域

  ```c++
  A::C1::f3
  // 说明:先查找函数f3的作用域，然后查找外层类C1的作用域,最后查找命名空间A的作用域
  ```

  

- 查找与std::move 和std::forward

  由于move和forward可以接受任意类型的参数，因此它们出现名字冲突要比其他的标准库函数频繁的多。

  所以为什么使用它们带限定语句的完整版本的原因





####	重载与命名空间



- 与实参相关的查找与重载

  

- 重载与using声明

  using声明语句声明的是一个名字，而非一个特定的函数

  ```c++
  using NS::print(int);	//错误
  using NS::print;		//正确
  ```

  当我们为函数书写using声明时，该函数的所有版本都被引入到当前作用域中

  如果using声明所在的作用域中已经有一个函数与新引入的函数同名且形参列表相同，会引发错误

- 重载与using指示

  using指示将命名空间的成员提升到外层作用域中，如果命名空间的某个函数与该命名空间所属作用域的函数同名，则命名空间的函数将被添加到重载集合中。

  与using声明不同，using指示引入一个与已有函数形参列表完全相同的函数并不会产生错误。此时，只要我们指明调用的是命名空间中的函数版本还是当前作用域的版本即可

  

- 跨越多个using指示的重载

  如果存在多个using指示，则来自每个命名空间的名字都会成为候选函数集的一部分：

  ```c++
  namespace AW{
      int print(int);
  }
  namespace Primer{
      double print(double);
  }
  using namespace AW;
  using namespace Primer;
  
  long double print(long double);
  
  int main(){
      print(1);		//调用AW::print
      print(3.1);		//调用Primer::print
      return 0;
  } 
  // AW::print 和 Primer::print 和 ::print 都属于mian函数的print函数的候选集中。
  ```

  







#	特殊工具与技术



##	控制内存分配

> 由于某些程序对内存分配有特殊的需求，所以我们无法将标准内存管理机制直接应用于这些程序。它们常常需要自定义内存分配的细节。为了实现这一目的，应用程序需要重载new运算符和delete运算符以控制内存分配的过程。



####	1.重载new和delete



- 当我们使用new和delete表达式时，其工作机制是：

  使用new：

  - new表达式调用一个名为operator new（或是operator new[]）的标准库函数。该函数分配一块足够大的内存空间（实质还是调用malloc）

  - 编译器运行相应的构造函数来构造这些对象，并为其传入初始值

  - 对象被分配了空间并构造完成，返回一个指向该对象的指针

    

  使用delete：

  - 对指针所指的对象或者是数组中的元素执行对应的析构函数

  - 编译器调用名为operator delete（或者operator delete[ ]）的标准库函数释放内存空间。（实质是调用free()）

    

- 我们可以重新定义operator new 和 operator delete函数

  编译器不会对这种重复的定义提出异议，相反，编译器将使用我们自定义的版本**替换**标准库定义的版本。

  一旦定义了全局operator new 和 operator delete后，我们就担负起了控制动态内存分配的职责。

  **这个两个函数必须是对的**（noexcept）

  

- operator new接口和operator delete接口

  ![image-20230326144508070](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230326144508070.png)

  - 和析构函数类似，**operator delete不允许抛出异常**。当我们重载这些运算符时，**必须使用noexcept异常说明符**。

  - 当我们自定义operator函数的时候，如果我们定义成类的成员时，它们是**隐式静态的**。

    因为**operator new用在对象构造之前而operator delete用在对象销毁之后**，所以这两个成员必须是静态的，而且它们不能操纵类的任何数据成员

  - 如果我们想要自定义operator new函数，**它的返回类型必须是void*，第一个形参必须是size_t且不能含有默认参数**。

  - 我们可以为自定义的operator new函数提供额外的形参。当使用这些函数时必须使用**new的定位形式**

  - operator new 和operator delete函数需要注意，和其他的operator函数不同，这两个函数并没有重载new表达式或delete表达式。new和delete表达式的行为是固定的！

  - 

- malloc函数和free函数

  一般来说，定义了自己的全局operator new/delete，应该会使到malloc和free函数。

  ```c++
  #include <cstdlib>
  
  void* operator new(size_t size){
      if(void* mem = malloc(size))		// 如果分配失败,malloc返回空指针
          return mem;
     	else
          throw bad_alloc();
  }
  
  void operator delete(void* mem) noexcept { free(mem); }	 //释放一个空指针无意义
  ```



####	2.定位new表达式











###	运行时类型识别 RTTI

**运行时类型识别（run-time type identification，RTTI）**的功能由两个运算符实现：

- typeid运算符，用户返回表达式的类型。
- dynamic_cast运算符，用于将基类的指针或引用安全地转换成派生类地指针或引用

这个运算符特别适用于以下情况：

**我们想使用基类对象的指针或引用执行某个派生类操作并且该函数不是虚函数**



####	1.dynamic_cast运算符

dynamic_cast运算符的使用形式如下：

```c++
dynamic_cast<type*>(e);
dynamic_cast<type&>(e);
dynamic_cast<type&&>(e);
```

其中，type必须是一个类类型，并且通常情况下该类型应该还有虚函数。（转换前类型必须是指向多态类型的指针或引用）

**如果是向上转型，那么转换成功，否则转换失败**

**可以使用static_cast来进行向下的转换，但是这是不安全的！**

如果转换失败；**转换目标是指针类型并且失败了，则结果为0。如果转换目标是引用类型并且失败了，则dynamic_cast运算符将抛出一个bad_cast异常**。



- **指针类型的dynamic_cast**

  ```c++
  if(Derived *dp = dynamic_cast<Derived*>(bp)){
      //使用dp指向derived对象
  }else{
      //使用bp指向base对象
  }
  ```

  **转换失败，dp为0。**

  这样写，是安全的，可以在**一个操作中同时完成类型转换和条件检查两项任务**。而且指针dp在if语句外部是不可访问的，一但转换失败，后续代码也不会接触到这个未绑定的指针，确保程序是安全的

  

- **引用类型的dynamic_cast**

  由于引用类型的dynamic_cast转换失败会抛出bad_cast异常，所以我们需要这么写：

  ```c++
  void f(const Base &b){
      try{
          const Derived &d = dynamic_cast<const Derived&>(b);
          //使用b应用的Derived对象
      } catch(bad_cast){
          //处理失败的情况
      }
  }
  ```

  



####	2.typeid运算符

为RTTI提供的第二个运算符是typeid运算符（typeid operator），它允许程序向表达式提问：你的对象是什么类型？

typeid表达式的形式是typeid(e)，其中e可以是任意表达式或类型的名字。typeid操作的结果是一个**常量对象的引用**，**该对象的类型是标准库类型type_info**或者type_info的公有派生类。type_info类定义在**typeinfo头文件**中。



typeid运算符会忽略顶层const，如果表达式是一个引用，**则typeid忽略其引用（类似模板参数推导）**。不过特别的是，当typeid作用于数组或函数时，并不会执行向指针的标准类型转换（退化）。也就是说，如果我们对数组a执行typeid(a)，**则所得的结果是数组类型而非指针类型**。**（即模板参数T&）**

- 使用typeid运算符

  通常情况下，我们使用typeid比较两条表达式的类型是否相同，或者比较一条表达式的类型是否与指定类型相同：

  ```c++
  Derived *dp = new Derived;
  Base *bp = dp;				// 两个指针都指向Derived对象
  
  if(typeid(*bp) == typeid(*dp)){
      // bp和dp指向同一类型的对象
  }
  if(typeid(*bp) == typeid(Dervied)){
      // bp实际指向Derived对象
  }
  
  ```

  注意，typeid应该作用域对象，因此我们使用*bp而非bp，如果使用bp，**返回的结果是该指针的静态类型**。

  如果对空指针使用type(*p)，将抛出一个名为bad_typeid的异常。



####	3.使用RTTI

在某些情况下RTTI非常有用，比如当我们想为具有基础关系的类实现相等运算符时。对于两个对象来说，如果它们的类型相同并且对应的数据成员取值相同，则我们说这两个对象相等。在类的继承体系中，每个派生类负责添加自己的数据成员，因此派生类的相等运算符必须把派生类的新成员考虑进来。

一种很容易想到的方案是定义一套虚函数，令其在继承体系的各个层次上分别执行相等性判断。

遗憾的是，上述方案很难奏效。虚函数的基类版本和派生类版本必须具有相同的形参类型。如果定义一个虚函数equal，则该函数的形参必须是基类的引用。此时，equal函数将只能使用基类的成员，而不能使用派生类独有的成员。





我们可以使用RTTI：

```c++
class Base{
    friend bool operator==(const Base&, const Base&);
public:
    // 接口成员
protected:
    virtual bool equal(const Base&) const;
    // Base的数据成员和其他用于实现的成员
};

class Derived : public Base{
public:
    // Deriver的其他接口成员
protected:
    bool equal(const Base&) const;
};

bool operator==(const Base &lhs, const Base &rhs){
    return typeid(lhs) == typeid(rhs) && lhs.equal(rhs);	// RIIT
}

bool Derived::equal(const Base &rhs) const {
    auto r = dynamic_cast<const Derived&>(rhs);		// 这个类型转换永远不会失败，想想为什么
    // 执行比较两个Derived对象的操作
}

bool Base::equal(const Base &rhs) const{
    // 执行比较两个Base对象的操作
}
```









####	4.type_info类

type_info类必须定义在typeinfo头文件中，并至少提供如下操作：

![image-20230329140944294](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230329140944294.png)

type_info类没有默认构造函数，而且它的拷贝和移动构造函数以及赋值运算符都被定义为删除的。因此，我们无法定义或拷贝type_info类型的对象，也不能为type_info类型的对象赋值。**创建type_info对象的唯一途径是使用typeid运算符**

type_info类的name成员函数返回一个C风格字符串，表示对象的类型名字。对于某种给定的类型来说，name的返回值因编译器而异。





###	枚举类型

枚举类型使我们可以将一组**整型常量**组织在一起。和类一样，**每个枚举类型定义了一种新的类型**。**枚举属于字面值常量类型**。

C++包含两种枚举：限定作用域和不限定作用域的。

C++11新标准引入了限定作用域的枚举类型。定义限域的枚举类型的一般形式是：首先是关键字**enum class（或是enum struct）**，随后是枚举类型名字以及用花括号括起来的以逗号分隔的**枚举成员（enumerator）**列表，最后是一个分号：

```c++
enum class open_modes {input, output, append};
```



**枚举成员**

枚举成员是const，因此在初始化枚举成员时提供的初始值必须是常量表达式



**和类一样，枚举也定义新的类型**

**一个不限定作用域的枚举类型的对象或枚举成员自动地转换为整型**

```c++
int i = color::red;	// 正确:不限定作用域的枚举类型的枚举成员隐式地转换为int
```



**指定enum的大小**



**枚举类型的前置声明**



**形参匹配和枚举类型**