---
title: effective-cplusplus
date: 2023-04-13 14:07:59
tags:
    - 计算机语言
---
> **Effective C++**



###	导读

####	术语

- **函数签名`signature`**

  ​	每个函数declaration揭示其签名式，也就是参数和返回类型。如：

  ```c++
  std::size_t numDigits(int);
  //function signature is std::size_t(int)
  ```

  

- **转换构造函数`converting constructor`**

  ​	被声明为explicit的构造函数通常比其non-explicit更受欢迎。因为它禁止编译器执行非预期的类型转换。除非我们有一个好理由允许构造函数被用于隐式类型转换`implicit type conversions`，否则我会把它声明为explicit的。

  

- **copy constructor 和 copy assginment**

  ​	很容易把copy构造和copy赋值给区分开来；如果一个新对象被定义，一定会有一个构造函数被调用，不可能调用赋值操作。如果没有新对象被定义，就不会有构造函数被调用，那么当然就是赋值操作被调用；

  ```c++
  class Widget{
  public:
      Widget();
      Widget(const Widget& rhs);
      Widget& operator=(const Widget& rhs); 
  };
  Widget w1;			//调用defaul构造函数
  Widget W2(w1);		//调用copy构造函数
  w1 = w2;			//调用copy assginmet操作符
  Widget w3 = w2;		//调用copy构造函数
  ```

- **未定义行为`undefined behavior`**

  如：

  ```c++
  int *p = 0;
  std::cout << *p;	//未定义行为
  ```

  避免未定义行为，未定义行为会让程序有时执行正常，有时造成崩坏，有时产生不了正确结果

  

- **接口 `interface`**

  C++没有这类语法概念



####	命名习惯

- **参数名称lhs和rhs**

  - lsh：left-hand side 左手端
  - rsh：right-hand side 右手端

  常常以它们作为二元运算符`binary operators`的参数,如：

  ```c++
  const A operator*(const A& lhs,const B& rhs);
  ```



- **变量的命名习惯**

  - ```c++
    A *pa;		//pa = "ptr to A"
    ```

  - ```c++
    B &rw = b;	//rw = "reference to B"
    ```

  - 讨论成员函数时，偶尔会以mf为名



####	关于线程

​	作为一个语言，C++对线程，事实上对任何并发事务都没有意念。

见P38



####	TR1和Boost

​	p38





###	1. 让自己习惯C++

> **Accustoming Yourself to C++**

​	

####	条款01：试C++为一个语言联邦

​	把C++视为一个由相关语言组成的联邦而非单一语言。在其某个次语言`sublanguage`中，各种守则与通例都倾向简单，直观易懂，并且容易记住。然而当你从一个次语言移到另一个次语言，守则可能改变。主要的次语言有四个：

- C
- Object-Oriented C++
- Template C++
- STL

C++并不是一个带有一组守则的一体语言；它是从四个次语言组成的联邦语言，每个次语言都有自己的规约。

> **请记住**

- ***C++高效编程守则是状况而变化，取决于你使用C++的哪那一部分***





####	条款02：尽量以const，enum，inline替换#define

​	这个条款可以改为宁可**以编译器替换预处理器**，因为#define不被视为语言的一部分。那正式它的问题所在。

- **#define 不好追踪错误**

  如：`#define MAX_VALUE 1.65`

  ​	记号名称`MAX_VALUE`也许从未被编译器看见；也许在编译器开始处理源码之前它就被预处理器移走了。于是记号名称可能没进入记号表`symbol table`内。于是当你使用此常量但获得一个编译错误信息时，可能会带来困惑，因为这个错误信息也许会提到1.65而不是`MAX_VALUE`。如果`MAX_VALUE`被定义在一个非你所写的头文件内，你肯定对1.65以及它来自何处毫无概念。于是你因为追踪它而浪费时间。原因：**你所使用的名称可能未进入记号表`symbol table`**

  ​	**解决的方法是以一个常量替换上述的宏**

  ​	`const double MAX_VALUE = 1.65`

  

- **当使用常量替换#define时，需要注意两种情况**

  - **定义常量指针`constant pointers`**

    ​	如要在头文件定义一个不变的字符串`char*-based`，你必须写两次const：

    ​	`const char * const authorName = "guo xiang;"`

    ​	此时，string对象通常要比其前辈char*-based更好：

    ​	`const std::string authorName("guo xiang");` 

  - **类`class`的专属常量**

    ​	如果需要将变量的作用域`scope`限制于class内，你必须让它成为class的一个成员`member`；而为了确保该常量至多只有一份实体，你必须让它成为一个static成员：

    ```c++
    class GamePlayer{
    private:
        static const int NumTurns = 5;		//常量声明式
        int scores[Numturns];
    }
    ```

    ​	你看到的NumTurns的声明式而非定义式。通常C++要求你对所使用的任何东西提供一个定义式；但是如果它是一个class专属常量又是static且为整数类型`integral type`(例如ints,chars,bools)，则需特殊处理：**只要不去它们的地址，你可以声明并使用它们而无须提供定义式。**

    ​	**如果你需要取某个class专属常量的地址，你就必须另外提供定义式如下：**

    `const int GamePlayer::NumTurns;`		//由于已经在声明时获得初值，因此定义时不可以再设初值

  

- **#define无法创建一个class专属常量，也不能提供任何封装性**

  ​	因为#define并不重视作用域`scope`。一旦宏被定义，它就在其后的编译过程中有效（除非在某处被`#undef`）。这意味#define也不能提供任何封装性

  

- **the enum hack**

  ​	如果你的编译器错误地不允许static整数型class常量完成in class初值的设定，可改用所谓的`the enum hack`补偿做法。其理论基础是：一个属于枚举类型的数值可以充当int被使用，于是有：

  ```c++
  class GamePlayer{
  private:
      enum { NumTurns = 5 };		//常量声明式
      int scores[Numturns];
  }
  ```

  enum hack有几个特点：

  - enum hack 的行为某方面说更像#define而不像const，有时候这就是你想要的；例如取得一个const的地址是合法的，但取一个enum的地址就是不合法的，而取一个#define的地址也不合法。如果不想让别人获得一个pointer或reference指向你的某个整数常量，enum可以实现这个约束
  - enum hack是`template metaprogramming`（模板元编程）的基础技术



- **尽量不要使用宏定义函数**

  宏定义有太多的缺点。我们可以使用`template inline`函数来取代；

  ​	内联的函数模板可以获得宏的效率以及一般函数的所有行为和类型安全性；它遵循作用域和访问规则，宏定义则无法做到







> ​	有了const，enum和inline，我们对预处理器（特别是#define）的需求降低了，但并非完全消除。#include仍是必须品，而#ifdef/#ifndef也继续扮演控制编译的重要角色
>
> [https://baijiahao.baidu.com/s?id=1729374634493915166&wfr=spider&for=pc](https://baijiahao.baidu.com/s?id=1729374634493915166&wfr=spider&for=pc)
>
> **请记住**



- ***对于单纯的常量，最好用const对象或enum替换#define***
- ***对于形如函数的宏，最好改用inline函数替换#define***



####	条款03: 尽可能使用const

​	

- **STL迭代器和const**

  迭代器的作用就像是T*指针,声明迭代器为const就像声明指针为const一样（即声明一个T * const指针），表示这个迭代器不能指向别的东西，当它所指的值可以改变。如果你希望迭代器所指向的东西不可被改动（即希望STL模拟一个const T*指针），你需要const_iterator;

  ```c++
  vector<int> arr(10);
  const vector<int>::iterator it = arr.begin();		//此时it是 T *const
  *it = 10;				//正确
  ++it;					//错误
  vector<int>::const_iterator cit = arr.begin();		//此时cit试试 const T*
  //auto cit = arr.cbegin();
  *cit = 10;				//错误		
  ++cit;					//正确
  ```





- **令函数返回一个常量值，往往可以降低因客户错误造成的意味，而又不至于放弃安全性和高效性**

  例如：

  ```c++
  const Rational operator* (const Rational& lhs,const Rational& rhs);
  Rational a, b, c;
  (a * b) = c;		//在a*b的结果下调用operator=
  if(a*b = c)			//不小心把==写成=	会造成错误的结果
  ```

  对于const参数，你应该在必要使用它们的时候使用它们；除非你有需要改变参数或本地`local`对象，否则请将它们声明为const。可以省下很多恼人的错误。

  

- **使用mutable释放掉non-static成员变量的bitwise constness约束**

  成员函数如果是const意味什么，这里有两个流行概念：

  - **bitwise constness**
  - **logical constness**

  编译器是bitwise constness,如果我们希望logical constness,怎么办？

  ​	利用C++的一个和const相关的摆动场：**mutable**,mutable释放掉non-static成员变量的bitwise constness约束

  

- **在const和non-const成员函数中避免重复**

  如果我们定义const成员函数和non-const成员函数，可能会出现很多的重复代码。

  如：我真正该做的是实现operator[]的机能一次并使用它两次，也就是说，我必须令其中一个调用另一个。这促使我们将常量性转除`casting away constness`(抛弃常量性)

  ​	将non-const成员函数调用其const兄弟是一个避免代码重复的安全做法：

  ```c++
  struct A{
      const char& operator[](size_t pos) const {}
      char& operator[](size_t pos){
          return const_cast<char&>
              (static_cast<const A>(*this)[pos]);		//两步转型
      }
  };	
  ```

  **注意，如果方向操作，令一个const版本调用non-const版本以避免重复，这是不应该做的，是错误的**

  ​	记住，const成员函数承诺绝不改变其对象的逻辑状态`logical state`，non-const成员函数没有这样的承诺。如果在const函数内调用non-const函数，就是冒着这种风险：你曾经承诺不改动的那个对象被改动了。这样是不安全的



> **请记住**

- ***将某些东西声明为const可帮助编译器侦测出错误用法。const可被施加于任何作用域内的对象，函数参数，函数返回类型，成员函数本体***
- ***编译器强制实施bitwise constness,但你编写程序时应该使用概念上的常量性***
- ***当const和non-const成员函数有着实质等价的实现时，令non-const版本调用const版本可避免代码重复***



####	条款04：确定对象被使用前已先被初始化



- **定义于函数体外的变量被初始化为0，定义在函数体内的内置或复合类型变量将不被初始化，其值未定义**

  ​	面对无任何成员的对象，最佳处理的办法就是：永远在使用对象之前先将它手动初始化

  

- **不要混淆赋值`assignment`和初始化`initialization`**

  对于类类型，初始化的责任落在构造函数身上`constructor`。规则很简单：确保每一个构造函数都将对象的每一个成员初始化

  - 赋值

    ```c++
    class A{
    public:
    	A(const string&,const string&);
    private:
        string name, address;
        int num;
    }
    A::A(const string& a,const string& b){
        name = a;
        address = b;
        num = 0;
    }
    //这是赋值！
    ```

    ​	这些成员都不是初始化，初始化的过程发生在进入构造函数本体之前，这些成员的default构造函数被自动调用，而且这里的num是内置类型，其初始化的值未定义。在这些成员初始化完成后，进入构造函数函数体进行赋值操作。

  - **初始化**

    ```c++
    A::A(const string& a,const string& b):name(a),address(b),num(0){}
    ```

    - 成员初值列`member initialization list`，直接拿a，b的作为初值对成员进行拷贝构造，比其上一种执行一次default构造再执行一次copy assignment，单执行一次copy构造显得更加高效。

    - 对于内置类型（如num）,其初始化和赋值的成本相同，但是为了一致性最好也通过初值列来初始化。

    - 同样的道理，甚至你想要default构造一个成员变量，你都可以使用成员初始列，只要指定nothing作为初始化实参即可，如：

      ```c++
      A::A():name(),address(),num(0) {}
      ```

      



- **总是使用成员初值列初始化成员，且在初值列中列出所有成员变量**

  ​	为了避免遗漏而出现未定义行为，应立下一个规则；总是在初值列中列出所有成员变量。并且当成员变量是引用或者const时，**必须**使用成员初值列。所以综上所述，总是使用成员初始列。

  

- **成员初始化次序和其声明次序一致**

  ​	成员初值列的次序最好和声明次序一致。

- **不同编译单元内定义non-local static对象**

  - static对象

    - non-local static 对象

      - 定义于global，namespace作用域内的对象
      - 在class内，file作用域内被声明为static的对象

    - local static对象

      ​		函数内的被声明static的对象

    - static对象的寿命从构造出来到程序结束，它们的析构函数会在main函数结束时被自动调用

  - 不同编译单元

    多个源码文件，产出的多个单一目标文件  （预处理，编译，汇编，链接）

  - 不同编译单元内定义的non-local static对象的初始化顺序未定义

    产生问题：某个编译单元内的某个non-local static对象的初始化动作使用了另一个编译单元内的某个non-local static对象，它所用到这个对象可能还没有被初始化。

  - 用reference-returning函数防止初始化次序问题

  **在不同编译单元，非局部变量的初始化依赖替换为函数调用结合local static对象。**

  

> **请记住**

- ***为内置型对象进行手动初始化，因为C++不保证初始化它们***
- ***构造函数最好使用成员初值列`member initialization list`,而不要在构造函数本地使用赋值操作`assignment`。初值列列出的成员变量，其初始化次序应该和它们在class中声明次序相同***
- ***为免除`跨编译单元之初始化次序`问题，请以local static 对象替换non-loacl static对象***





###	2.构造/析构/赋值运算

> **Constructors,Destructors,and Assignment Operators**



#### **条款05:了解C++默默编写并调用哪些函数**

- 在你没有声明拷贝控制函数时，编译器会自动合成
- 如果成员含有const或reference，合成的拷贝赋值运算符被定义为删除的。即类对应的数据成员不能默认构造，拷贝，赋值或销毁，则对应的成员函数将被默认定义为删除的。编译器拒绝合成。
- 如果base class的拷贝控制函数被定义为删除或是private的（**即不可访问的**），derived class对应的成员函数将被默认定义为删除，同样编译器拒绝合成，也无法合成。



> **请记住**

- ***编译器可以暗自为class创建default构造函数，copy构造函数，copy assignment操作符，以及析构函数***





####	条款06:若不想使用编译器自动生成的函数，就应该明确拒绝



- **当你不希望class支持某些拷贝控制函数，可以把它们声明为private且不定义它们，或是定义为删除的（=delete，C++11）**

  

- **如果是声明为private以阻止拷贝控制操作，并不绝对安全**

  因为member函数和firend函数还是可以调用private函数。但是由于没有定义，调用它们会获得一个链接错误`linkage error`

  

- **如果希望更加安全，将链接期的错误移至编译器，可以这么做**

  ```c++
  class Uncopyable{
  protected:
      Uncopyable() {}
      ~Uncopyable() {}
  private:
      Uncopyable(const Uncopyable&);				//阻止copying
      Uncopyable& operator=(const Uncopyable&)
  }
  
  class HomeForSale : private Uncopyable{
    .....  
  };
  ```

  base class 的copying函数是不可访问的，derived class不会合成copying函数，且derived是private继承，这使得derived的成员，友元以及用户都不可能调用到base的copying函数。且base class是空的，继承空基类会出现**空基类优化**的现象。并且我们还可以发现，我们对此base class不需要用到多态性质。

- 



> **请记住**

- ***为驳回编译器自动（暗自）提供的机能，可将相应的成员函数声明为private并且不予实现。使用像Uncopyable这样的base class也时一种做法***

- ***我的补充：C++11中，可以时用=delete来定义为删除的***



####	条款07:为多态基类声明virtual析构函数

- **动态分配的一个指向对象的指针，它的动态类型和静态类型会出现不一致的情况，在delete这个指针的时候，为了确保调用的析构函数是动态类型的，应该把基类的析构函数声明为virtual**

  

- **任何class只要带有virtual函数都几乎确定应该也有一个virtual析构函数**

  

- **如果class不含virtual函数，即不想把它用做一个base class，就不要令即析构函数为virtual**

  - 虚函数会导致该对象多出虚指针，所占的空间变多

  - 也不具有可移植性

    

- **class完全不带virtual，还是会被non-virtual析构函数引发错误**

  ```c++
  class MyString : public string{
      ...
  };
  string *ps = new MyString("hello");		//up-cast
  delete ps;		//未定义！
  //stl string没有virtual destructor!
  ```

  如果会出现动态类型和静态类型不一致的情况（即出现up-cast），且基类不提供virtual析构函数，那么就不要继承基类。

  

- **如果需要abstrak class,而手上没有pure virtual函数，可以令析构函数为纯虚函数，以此创造出抽象基类**

  注意：纯虚析构函数需要在类外定义，不然调用它的时候，连接器会报错



> **请记住**

- ***`polymorphic`（带多带性质的）base class应该声明一个virtual析构函数。如果class带有任何virtual函数，它就应该拥有一个virtual析构函数***
- ***class的设计目的如果不是作为基类使用，或不是为了具备多态性，就不该声明virtual析构函数*（占用内存空间）**
- 我的的补充：只要会出现升型（up-cast）的情况，就应该把基类的析构函数声明为virtual





####	条款08:别让异常逃离析构函



> **请记住**

- ***析构函数绝对不要吐出（抛出）异常。如果一个被析构函数调用的函数可能抛出异常，析构函数应该捕捉任何异常，然后吞下它们（不传播）或结束程序***
- ***如果客户需要对某个操作函数运行期间抛出的异常做出反应，那么class应该提供一个普通函数（而非在析构函数中）执行该操作***



####	条款09:绝不在构造和析构过程中调用virtual函数



> **请记住**

- ***在构造和析构期间不要调用virtual函数，因为这类调用从不下降至derived class（比起当前执行构造函数和析构函数的那层）***

​	


####	条款10:令operator=返回一个reference to *this



> **请记住**

- ***令赋值`assignment`操作符返回一个reference to *this***





####	条款11:在operator=中处理自我赋值



> **请记住**

- ***确保在对象自我赋值时operator=有良好的行为。其中技术包括比较`来源对象`和`目标对象`的地址，精心周到的语句顺序（先复制一份），以及copy-and-swap***
- ***确定任何函数如果操作一个以上的对象时，而其中多个对象是同一个对象，其行为仍然正确***





####	条款12:复制对象时勿忘其每一部分



> ***请记住***

- ***Copying函数应该确保复制`对象内的所有成员变量`及`所有base class`成分***
- ***不要尝试以某个copying函数实现另一个copying函数。应该将共同机能放进第三个函数中（通常在private，且名字为init），并由两个copying函数共同调用。***





##	3.资源管理

> ​	**所谓资源就是，一旦用了它，将来必须还给系统。如果不还，糟糕的事情就会发生。C++程序最常用的资源就是动态分配内存，如果你分配内存却不归还，会导致内存泄漏，但内存只是你必须管理的众多资源之一。其他常见的资源还包括`文件描述器`，`互斥锁`，`数据库连接`以及`网络sockets`。不论哪一种资源，重要的是，当你不再使用它，必须还给系统**



####		条款13.以对象管理资源



- 很多关键字以及异常能使得程序跳过delete语句，从而资源泄漏

  

- 把资源放进对象内，依赖C++的析构函数自动调用机制，确保资源被释放

  

- 以对象管理资源`RAII`的两个关键想法

  - 获得资源后立刻放进管理对象`manging object`

    此观念又称为**RAII`Resource Acquisition Is Initialization`**，**即资源取得时就初始化资源管理对象**。无论是初始化还是赋值动作，每一笔资源都在获得的同时立刻被放进管理对象中


  - 管理对象运用析构函数确保资源被释放

    利用管理对象的析构函数自动释放资源，如果资源释放动作可能导致抛出异常，条款8可以解决




- RCSP`reference-counting smart pointer`

  

- auto_ptr 和 tr1::shared_ptr都在析构函数内做delete而不是delete[]，意味着在动态分配而得的array身上使用auto_ptr或tr1::shared_ptr是不好的

- 

> **请记住**

- ***为防止资源泄漏，请使用RAII对象，它们在构造函数中获得资源并在析构函数中释放资源******
- ***两个常被使用的RAII classes分别是tr1：：shared_ptr和auto_ptr。前者通常是较佳选择，因为其copy行为比较直观。若选择auto_ptr,复制动作会使它指向null***
- ***我的补充：C++11提供了shared_ptr和unique_ptr以及弱引用weak_ptr***



####	条款14：在资源管理类中小心copying行为



- 当我们设计一个资源管理类时，需要首先考虑，当一个RAII对象被复制，会发生什么事？我们常用以下方式处理这个问题
  - 禁止复制		对应unique_ptr类
  - 对底层资源祭出引用计数法`reference count`    对应shared_ptr类
  - 复制底部资源
  - 转移底部资源的拥有权    即deep copying
  - 转移底部资源的拥有权    即reset或release



> **请记住**

- ***复制RAII对象必须一并复制它所管理的资源，所以资源的copying行为决定RAII对象的copying行为***
- ***普遍而常见的RAII class copying 行为是：抑制copying，施行引用计数法`reference counting`。不过其他行为也可能被实现***



####	条款15：在资源管理类中提供对原始资源的访问

大多数情况下，不需要你玷污双手直接处理原始资源`raw resources`。但是还是有很多场景需要访问原始资源，如：

```c++
void Connect(const string*){
    ....
}
shared_ptr<const string> sp(new const string("127.0.0.1"));
Connect(sp);		//错误！
```



> **请记住**

- ***API往往要求访问原始资源`raw resources`，所以每一个RAII class应该提供一个“取得其所管理的资源”的办法***
- ***对原始资源的访问可能经由显式转换或隐式转换。一般而言显式转换比较安全，但隐式转换对客户比较方便***



####	条款16：成对使用new和delete时要采取相同形式

- delete[]代表delete是个数组对象，delete没有[]代表delete是单个对象

- 如果new使用了[]，delete却没有使用[]，析构函数缺少调用，行为未定义
- 如果new没有使用[]，delete却使用[]，delete会读取若干内存并将它解释为"数据大小"，然后多次调用析构函数。浑然不知道它处理的那块内存并不是个数组，其结果行为未定义

![image-20230307212844536](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230307212844536.png)

- 尽量不要对数组做typedef动作，如：

  ```c++
  typedef string arrs[4];
  string* pa = new arrs;
  delete pa;				//错误，pa所指的是个数组对象，行为未定义
  delete[] pa;			//正确
  ```

  

> **请记住**

- ***如果你在new表达式中使用[]，必须在相应的delete表达式中也使用[]。如过你在new表达式中不使用[]，一定不要在相应的delete表达式中使用[]***





####	条款17：以独立语句将new对象置入智能指针

假如我们有个函数来揭示处理程序的优先级，另一个函数用来在某动态分配所得的Widget上进行某些带有优先级的处理：

```c++
int priority();
void processWidget(shared_ptr<Widget> pw,int priority);
```

由于谨记以对象管理资源，使用智能来管理资源

```c++
processWidget(shared_ptr<Widget>(new Widget),priority);		//shared_ptr的构造函数时explicitd的
															//必须直接初始化
```

上述调用却可能产生资源泄漏；

`shared_ptr<Widget>(new Widget)`由两部分组成：

- 执行new Widget表达式
- 调用shared_ptr构造函数

于是调用processWidget之前，编译器必须创建代码。做以下三件事；

- 调用priority
- 执行new Widget
- 调用shared_ptr构造函数

编译器以什么样的次序完成这些事情呢？弹性很大。

可以确定，new Widget一定发生在shared_ptr构造函数之前，但是priority的调用可以排在第一或第二或第三执行，如果排在第二，会出现这样的操作序列：

1. 执行new Widget
2. 调用priority
3. 调用shared_ptr构造函数

想一想，如过在调用priority时候导致异常，会发生什么？

**在此情况下，new Widget返回的指针将会遗失，因为它没有被置入shared_ptr内。**

是的，在对processWidget的调用过程中可能会发生资源泄漏，因为在**资源被创建**和资**源被转换为资源管理对象**这**两个时间点之间有可能发生干扰**



避免这类问题的办法很简单，使用分离语句：

```c++
shared_ptr<Widget> pw(new Widget);
processWidget(pw,priority());			//绝对不至于造成泄漏
```

编译器对跨越语句的各项操作没有重新排列的自由（只有在语句内它才拥有那个自由度）



> **请记住**

- **以独立语句将newed对象存储于（置入）智能指针内。如果不这样做，一旦异常被抛出，有可能导致难以察觉的资源泄漏。**





##	4.设计与声明

> **Designs and Declarations**





####	条款18：让接口容易被正确使用，不易被误用



- 如果客户企图使用某个接口而却没有获得他所预期的行为，这个代码不该通过编译；如果代码通过了编译，它的作为就该是客户所想要的

- 构建类型系统，导入简单的外覆类型`wrapper types`来区别不同而又相似的数据

  ```c++
  struct Day{						struct Month{...}
      explicit Day(int d)				
          :val(d) {}
      int val;
  };
  class Date{
  public:
      Date(const Month& m,const Day& d);
      ...
  }
  Date d(30,3)		//错误
  Date d(Day(30),Month(3));	//错误
  Date d(Month(3),Day(30));	//正确
  ```

- 类型正确性确定后，限制其值是通情达理的

  如1年只有12个月：

  ```c++
  class Month{
  public:
      static Month Jan() { return Month(1); }
      static Month Feb() { return Month(2); }
      ....
  private:
      explicit Month(int m);
  };
  ```

  注意：用函数替换对象，是合理的，见条款4

  

- 限制类型什么事情可以做，什么事情不能做

  常见的限制是加上const，如条款3

  

- 除非有好的理由，否则应该尽量令你的type的行为与内置type一致

  

- 任何接口如果要求客户必须要记得做某些事情，就是有着不正确使用的倾向，因为客户可能会忘记做那件事情

  如函数返回一个指针指向动态分配的对象，它要求客户最终必须要删除，那么，这至少开启了两个错误机会：没有删除，或删除超过一次

  许多时候，较佳的接口设计原则是先发制人，就令此函数返回一个智能指针

  

- **如果class设计者希望客户自己传递删除器给智能指针，而不是使用delete，这样又开启了通往错误的大门**

  **设计者应该先发制人，事先自动的绑定正确删除器**

  

- shared_ptr还又一个特别好的性质：它会自动使用它的每个指针专属的删除器，因而消除另一个潜在的客户错误：所谓的`cross-DLL problem`

  此问题发生于，对象在动态连接库`DLL`中被new创建，却在另一个DLL内被delete销毁。



> **请记住**

- ***好的接口很容易被正确使用，不容易被误用。你应该在你的所有接口中努力达成这些性质***
- ***促进正确使用的办法包括接口的一致性，以及与内置类型的行为兼容***
- ***阻止误用的办法包括建立新类型，限制类型上的操作，束缚对象值，以及消除客户的自由管理责任***
- ***shared_ptr支持定制型删除器。这可防范DLL问题，可被用来自动解除互斥锁（见条款14）等等***





####	条款19：设计class犹如设计type

与其他OOP语言一样，当你定义一个新class，也就定义了一个新的type。身为C++程序员，你的很多时间主要用来扩张你的类型系统（type system）。这意味你并不只是class设计者，还是type设计者。重载函数和操作符，控制内存的分配和归还，定义对象的初始化和终结.....全都在你手上。因此你应该带着和语言设计者当初设计语言内置类型时一样谨慎来研讨class的设计



设计优秀的class时一项艰巨的工作，如何设计高效的class？首先你必须了解你面对的问题。几乎每一个class都要求你面对以下提问，而你的回答往往导致你的设计规范：

- 新type的对象应该如何被创建和销毁？
- 对象的初始化和对象的赋值该有什么样的差别？
- 新type的对象如果被passed by value，意味着什么？
- 什么是新type的合法值？
- 你的新type需要配合某个继承图系吗？
- 你的新type需要什么样的转换？
- 什么样的操作符和函数对此新type而言是合理的？
- 什么样的标准函数应该驳回？
- 谁该取用新type的成员？
- 什么是新type的未声明接口？
- 你的新type有多么一般化？
- 你真的需要一个type吗？



> **请记住**

- **Class的设计就是type的设计。在定义一个新type之前，请确定你已经考虑过本条款覆盖的所有讨论主题。**



####	条款20：宁以pass-by-reference-to-const替换pass-by-value



- pass-by-value是昂贵的（费时的）操作

  调用拷贝构造和析构函数，极度费时

- 以by reference方式传递参数也可以避免`slicing`（对象切割）问题。





> **请记住**

- ***尽量以pass-by-reference-to-const替换pass-by-value。前者通常比较高效，并可避免切割问题(slicing problem)***
- ***以上规则并不是适用于内置类型，以及STL的迭代器和函数对象。对于它们而言，pass-by-value往往比较恰当***



####	条款21：必须返回对象时，别妄想返回其reference



> **请记住**

- ***绝不要返回pointer或reference指向一个local stack对象，或返回reference指向一个heap-allocated对象，或返回pointer或reference指向一个local static对象而有可能同时需要多个这样的对象。条款4已经为在单线程环境中合理返回reference指向一个local static对象提供了一份设计实例***







####	条款22：将成员变量声明为private



**从封装的角度来看，其实只有两种访问权限：private（提供封装）和其他（不提供封装）**

假如我们有一个public成员变量，而我们最终取消了它。多少代码可能会被破坏呢？

​	所有使用过它的客户码都会被破坏

假如我们有一个protected成员变量，而我们最终取消了它。多少代码被破坏？

​	所有使用它的derived classes都会被破坏

一旦你将一个成员变量声明为public或protected而客户开始使用它，就很难改变这个成员变量所涉及的一切；太多代码需要重写，重新测试，重新编写文档，重新编译。从封装的角度来看，其实只有两种访问权限：private（提供封装）和其他（不提供封装）



>**请记住**

- ***切记将成员变量声明为private。这可赋予客户访问数据的一致性，可细微划分访问控制，许诺约束条件获得保证，并提供class作者以充分的实现弹性***
- ***protected并不比public更具封装性***





####	条款23：宁以non-member，non-friend替换member函数



让我们从封装开始讨论，如果某些东西被封装，它就不再可见。愈多东西被封装，愈少人可以看到它。而愈少人看到它，我们就有愈大的弹性去变化它，因为我们的改变仅仅直接影响看到改变的那些人事物。因此，越多东西被封装，我们改变那些东西的能也就越大。这就是我们首先推崇封装的原因：它使我们能够改变事物而只影响有限客户



- 比较自然的做法是将non-member,non-friend函数和类在同一个namespace内

  ![image-20230308163603813](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230308163603813.png)

- 1



![image-20230308163618619](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230308163618619.png)







> **请记住**

- ***宁可拿non-member non-friend函数替换member函数。这样做可以增加封装性，包裹弹性和机能扩充性***





####	条款24：若所有参数都需类型转换，请为此采用non-member函数



> **请记住**

- ***如果你需要为某个函数的所有参数（包括被this指针所指的那个隐喻参数）进行类型转换，那么这个函数必须是个non-member***







####	条款25:考虑写出一个不抛异常的swap函数



swap原本只是STL的一部分，后来成为异常安全编程（条款29）的基础，以及用来处理自我赋值（条款11）的一个常见机制。



- STL缺省的swap函数效率不够

  当遇到**pimpl**`pointer to implementation`的手法的时候，如果使用缺省的swap函数，它将依次拷贝所有对象成员（其实只需要交换指针值）。如何做到更有效率？

  - 是普通类时

    由于我们不够改变std namespace 里面的任何东西，但是可以被允许为标准teamlates 制造特化版本，如：

    ```c++
    class Widget{
    public:
        ...
    	void swap(Widget& other){
            using std::swap;
            swap(pImpl,other.pImpl);
        }       
    	...
    }
    //由于指针pImpl是private的，不能直接在特化的swap里面取得
    namespace std{
        template<>
        void swap<Widget>(Widget& a,Widget& b){
            a.swap(b);
        }
    }
    Widget a, b;
    a.swap(b); 	// Widget::swap() -> std::swap()
    swap(a,b);	// 特化的std::swap()  ->  Widget::swap() -> std::swap()	
    ```

  - 如果是class template而非普通的class

    由于funciton template**不能被偏特化**，通常来说，我们可以为它添加一个**重载的版本**，但是由于std不能添加新的template，所以我们添加一个non-member swap让它来调用member swap:

    可以说函数模板的偏特化可以用重载来替代，故C++不允许对函数模板偏特化

    ```c++
    namespace WidgetStuff{
        ...
        template<typename T>
        class Widget {....};
        ...
       	
        //偏特化
        template<typename T>
        void swap(Widget<T>& a,Widget<T>& b){
            a.swap(b);
        }
    }
    ```

  - 通常应该把特化的std::swap和non-member swap一起写上

    ```c++
    template<typename T>
    void doSomething(T& obj1,T& obj2){
        ...
        swap(obj1,obj2);	//调用哪一个呢
        ...
    }
    ```

    

  

- 此刻，我们已经讨论过default swap，member swap，non-member swap（偏特化），std::swap(特化)，以及对swap的调用，现在做个总结

  如果swap缺省实现版本的效率不足，那几乎总是意味你的class或template class使用了某种pimpl手法，试着做以下事情：

  - 提供一个public swap成员函数，让它高效地置换你的类型的两个对象值，且这个函数绝不该抛出异常
  - 在你的class或template所在的命名空间内提供一个non-member swap，并令它调用上述swap成员函数
  - 如果你正编写一个class（不是class template），为你的class特化std::swap，并令它调用你的swap成员函数
  - 最后，如果你调用swap，请确定包含一个using声明式，以便std::swap在函数内可见，然后不加任何namespace 修饰符，直接调用swap



> **请记住**

- ***当std::swap对的你的类型效率不高时，提供一个swap成员函数（public），并确定这个函数不抛出异常***
- ***如果你提供一个member swap，也该提供一个non-member swap用来调用前者，对于class（而非template）,也请特化std::swap***
- ***调用swap时应针对std::swap使用using声明式，然后调用swap并且不带任何”命名空间资格修饰“***
- ***为用户定义类型进行std template全特化是好的，但千万不要尝试在std内加入某些对std而言全新的东西***



###	5.实现

![image-20230309205807664](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230309205807664.png)



####	条款26：尽可能延后变量定义式的出现时间

- 只要你定义了一个变量而其类型带有一个构造函数或析构函数，那么当程序到达这个变量定义式时，你便得承受构造成本；当离开其作用域时，你便得承受析构成本
- 因为有可能会有异常抛出，所以就会有对象在函数中并未被使用，就会付出构造和析构成本
- 你应该尽可能的延后变量定义，直到这份定义能够给它初值实参为止。因为这样，不仅能够避免构造和析构非必要对象，还可以避免无异议的default构造行为。

![image-20230309190803119](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230309190803119.png)



![image-20230309190815153](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230309190815153.png)



> **请记住**

- ***尽可能延后变量定义式的出现，这样做可增加程序的清晰程度***



####	条款27：尽量少做转型动作





> **请记住**

- ***如果可以，尽量避免转型，特别是在注重效率的代码中避免dynamic_cast。如果有个设计需要转型动作，试着发展无需转型的替代设计***
- ***如果转型是必要的，试着将它隐藏于某个函数背后。客户随后可以调用该函数，而不需将转型放进他们自己的代码内***
- ***宁可使用`C++ style`转型，不要使用旧式转型。前者很容易辨识出来，而且也比较有着分门别类的职责***







####	条款28：避免返回handles指向对象内部成分







> **请记住**

- ***避免返回handles（包括reference，指针，迭代器）指向对象内部。遵守这个条款可增加封装性，帮助const成员函数的行为像个const，并将发生“虚吊号码牌”（dangling handles）的可能性降至最低***







####	条款29：为“异常安全”而努力是值得的





异常安全函数`Exception-safe functions`提供以下三个保证之一：

- **基本承诺**
- **强烈保证**
- **不抛掷（nothrow）保证**





> **请记住**

- ***异常安全函数`Exception-safe funcitons`即使发生异常也不会泄漏资源或允许任何数据结构败坏，这样的函数区分为三种可能的保证：基本型，强烈型，不抛异常型***
- ***“强烈保证”往往能够以copy-and-swap实现出来，但“强烈保证”并非对所有函数都可实现或具备现实意义***
- ***函数提供的“异常安全保证”通常最高只等于其所调用之各个函数的“异常安全保证”中的最弱者***







####	条款30：透彻了解inlining的里里外外



- inline的本质是那函数本体替换，而不是调用；这将增大的你的目标吗`object code`

  在内存有限的机器上，过度热衷inlining会造成程序体积太大；inline造成的代码膨胀会导致额外的换页行为，降低指令高速缓存装置的击中率。

  换个角度来说，如果inline函数的本体很小，编译器针对函数本体所产出的码可能比针对“函数调用”所产出的码更小，则会提升效率

  

- inline只是对编译器的一个申请，不是强制命令，可以隐喻提出

  

- funciton template 不一定要是inline的，如果所有template的具现出来的函数都是inline，那么请为它声明为inline；如果你的template没有理由要求它所具现的每一个函数都是inline，那就应该避免将这个template声明为inline。因为inlining需要成本

  

- inline virtual函数，往往会内联失败。因为virtual函数的调用是运行时才确定的

  

- 将构造函数和析构函数声明为inline是没有意义的，因为编译器位置构造和析构函数中添加额外的操作（申请/释放内存，构造/析构对象等等），致使构造/析构函数并不像看上去那么精简。其次，在class内的函数默认是inline的，但编译器也只是有选择性的inline。将构造和析构函数声明为inline没有什么意义

> **请记住**

- ***将大多数inlining限制在小型，被频繁调用的函数上。这可使日后的调试过程和二进制升级更容易，也可使潜在的代码膨胀问题最小化，是程序的速度提升机会最大化***
- ***不要只因为funciton templates出现在头文件，就将它们声明为inline***







####	条款31：将文件间的编译依存关系降至最低





> **请记住**

- ***支持“编译依存性最小化”的一般构想是：相依于声明式，不要相依于定义式。基于此构想的两个手段是Handle class 和interface class***
- ***程序库头文件应该以“完全且仅有声明式”（full and declaration-only forms）的形式存在。这种做法不论是否涉及templates都适用***





##	6.继承与面向对象设计

> Inheritance and Object-Oriented Design





####	条款32：确定你的public继承塑模出is-a关系



> **请记住**

- ***public继承意味is-a。适用于base class身上的每一件事情一定也适用于derived class身上，因为每一个derived class对象也都是一个base class***







####	条款33：避免遮掩继承而来的名称





> **请记住**

- ***derived class内的名称会遮掩base class内的名称。在public继承下从来没有人希望如此。***
- ***为了让被遮掩的名称再见天日，可使用using声明（名称的全部函数）或转交函数`forwarding function`***







####	条款34：区分接口继承和实现继承



> **请记住**

- ***接口继承和实现继承不同。在public继承之下，derived class总是继承base class的接口***
- ***pure virtual函数只具体指定接口继承***
- ***普通的impure virtual函数具体指定接口继承及缺省实现继承***
- ***non-virtual函数具体指定接口继承以及强制性实现继承***









####	条款35：考虑virtual函数以外的其他选择



> **请记住**

- ***virtual函数的替代方案包括NVI手法及Strategy设计模式的各种形式。NVI手法自身是一个特殊形式的Template Method设计模式***
- ***将机能从成员函数移动到class外部函数，带来的一个缺点是，非成员函数无法访问class的non-public成员***
- ***tr1::funciton对象的行为就像是一般函数指针。这样的对象可接纳”与给定之目标签名式`target signature`兼容的所有可调用物***





####	条款36：绝不重新定义继承而来的non-virtual函数

> Never redefine an inherited non-virtual funciton

- 调用non-virtual function 一定是静态绑定`statically bound`

  成员的访问由静态类型决定，如果访问的成员不是虚函数，则发生静态绑定，否则，发生动态绑定

- 如果重新定义了继承而来的non-virtual函数，可能会出现精神分裂的情况：

  ```c++
  struct A{
      void fun() { cout << 'A' << endl; }
  };
  struct B : A{
      void fun() { cout << 'B' << endl; }
  };
  B bobj;
  A *pa = &b;
  B *pb = &b;
  pa->fun();		//调用的是A::fun()
  pb->fun();		//调用的是B::fun()
  ```

- 结合条款32和条款34，如果你要重新定义基类的non-virtual函数：

  - 根据条款32的public继承是is-a的关系，如果重新定义了，D就不是一个B，不符合is-a的关系，就不该以public继承
  - 如果D确实需要重新定义，那么该non-virtual函数就不能反映出`不变性凌驾特异性`的性质，则应该把此函数声明为virtual函数

- 结合条款7，也解释了为什么polymorphic base class不能是non-virtual。如果是non-vitrual，则无论derived class无论是重新定义还是不重新定义（不定义，编译器会生成缺省的析构），都会导致精神分裂的现象。



> **请记住**

- ***绝对不要重新定义继承而来的non-virtual函数***



####	条款37：绝不重新定义继承而来的缺省参数值

> Never redefine a function's inherited default paremeter value



- 如果重新定义继承而来的缺省参数值，会出现调用driverd class的虚函数却使用了base class的默认参数：

  ```c++
  struct B{
      virtual void fun(string str = "a") { cout << str << endl; } 
  };
  
  struct D1 : B{
      void fun(string str = "b") { cout << str << "is me" << endl; }
  };
  
  struct D2 : B{
      void fun(string str = "c") { cout << str << endl; }
  
  };
  D1 d1;
  D2 d2;
  B *pb = &d1;
  pb->fun();		//输出是:ais me!
  //调用D1的虚函数却使用了基类的默认参数
  ```

  

- **derived class覆写virtual函数时是不会继承缺省参数，而virtual函数的缺省参数值是静态绑定`statically bind`**

  ```c++
  struct A{
      virtual void fun(int a = 111) { cout << a << endl; }
  };
  
  struct B : A{
      void fun(int a) override { cout << a << endl; }		//覆写fun时，没有继承上base class的默															认参数
  };
  B b;
  b.fun();	//错误，缺少参数
  ```

  

  为了运行效率，如果参数值是动态绑定，编译器就必须有某种办法。这比目前实行的”在编译期决定“的机制更慢而且更复杂。为了速度，C++做了这样的取舍

- 如果希望virtual函数表现出你想要的行为，聪明的办法是考虑替代设计

  如条款35，可以使用NVI`non-virtual interface`手法：令base class内的一个public non-virtual函数调用private virtual函数，后者可以被derived class重新定义，如：

  ```c++
  struct A{
      void fun(string str = "abc") {  dofun(str); }
  private:
      virtual void dofun(string str)  { cout << "A " << str << endl; }
  };
  struct B : A{
  private:
      void dofun(string str) override { cout << "B " << str << endl; }
  };
  B b;
  A *pa = &b;
  pa->fun();	// B abc
  ```

  

> **请记住**

- ***绝对不要重新定义一个继承而来的缺省参数值，因为缺省参数值都是动态绑定，而virtual函数，你唯一应该覆写的东西，却是动态绑定***





####	条款38：通过复合塑模出has-a或根据某物实现出



- **复合`composition`意味着has-a（有一个）或is-implemented-in-terms-of（根据某物实现出）两种含义**

  - has-a：

    ```c++
    class Address {...};
    class PhoneNumber{...};
    class Person{
    private:
        string name;					//has-a
        Address address;				//同上
        PhoneNumber voiceNuber;			//同上
    .....
    }
    ```

  - is-implemented-in-terms-of（根据某物实现出）：

    ```c++
    template<typename T>
    class Set{
    private:
        std::list<T> rep;			//根据某物实现出
    .....
    }
    ```




> **请记住**

- ***复合（composition）的意义和public继承完全不同***
- ***在应用域（application domain）,复合意味has-a（有一个）。在实现域（implementation domain）,复合意味is-implemented-in-terms-of（根据某物实现出）***





####	条款39：明智而谨慎地使用private继承



- **使用private继承，意味着编译器不会自动将一个derived class对象转换为base class对象（up-cast），且继承而来的所有成员，在derived class中都会变成private属性。**

  可以通过using修饰，更改局部成员的private继承

  ```c++
  class A{
  public:
      int a;
  };
  
  class B : private A{
  public:
      using A::a;			//在public:下使用的using，就将a重新设为public的
      					//a必须可以访问才能使用using
  };
  
  ```

  

- **private继承意味`implemented-in-terms-of`根据某物实现出**

  如果你让class D以private形式继承class B，你的用意是**为了采用class B内已经具备的某些性质**，不是因为B对象和D对象存在有任何观念上的关系。**private继承纯粹只是一种实现技术**（private继承，**class的每样东西在你的class内都是private，因为它们都是实现细节而已**）。用条款34提出的术语，private继承意味**只有实现部分被继承**，**接口部分应略去**。**如果D以private形式继承B，意思是D对象根据B对象实现而得**，再没有其他含义了。



- private继承和复合composition有着相似的意义（根据某物实现出），如果取舍？

  答：**尽可能使用复合，必要时才使用private继承。何时才是必要？主要是当protected成员和/或virtual函数牵扯进来的时候，还有空间方面。**

  

- 利用复合composition + 继承 代替private继承

  ![image-20230311133312443](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230311133312443.png)

  此手法还阻止了覆写base class 的virtual函数 （即C++11 的final）

  ![image-20230311143241944](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230311143241944.png)

- private继承可以出现EBO（空基类优化）







> **请记住**

- ***private继承意味is-implemented-in-terms of（根据某物实现出）。它通常比复合（composition）的级别低。但是当derived class需要访问base class的protected成员，或需要重新定义继承而来的virtual函数时，这么设计是合理的***
- ***和复合（composition）不同，private继承可以造成empty base最优化。这对致力于“对象尺寸最小化”的程序库开发者而言，可能很重要***









####	条款40：明智而谨慎的使用多重继承



> **请记住**

- ***多重继承比单一继承复杂。它可能导致新的歧义性，以及对虚继承的需要***
- ***virtual继承会增加大小，速度，初始化（及赋值）复杂度等等成本。如果基类不带任何数据，那将是虚继承最具实用价值的情况***
- ***多重继承的确有正当用途。其中一个情节涉及“public继承某个Interface class”和“private继承某个协助实现的class”的两项组合***







##	7.模板和泛型编程

> Templates and Generic Programming



####	条款41:了解隐式接口和编译器多态



> **请记住**

- ***class和template都支持接口`interfaces`和多态`polymorphism`***
- ***对class而言接口时显式的`explicit`，以函数签名为中心。多态则是通过virtual函数发生于运行期***
- ***对template参数而言，接口时隐式的`implicit`，奠基于有效表达式。多态则是通过template具现化（实例化）和函数重载解析发生于编译器***





####	条款42:了解typename的双重意义



> **请记住**

- ***声明template参数时，前缀关键字class和typename可互换***
- ***请使用关键字typename表示嵌套从属类型名称；但不得在base class lists（基类列）或member initialization list（成员初值列）内以它作为base class 修饰符***





####	条款43:学习处理模板化基类内的名称



- **C++拒绝在templatized base class（模板化基类）内寻找继承而来的名字**

  当我们从Object Oriented C++ 跨进 Template C++，继承就不像以前那般畅通无阻了

  看下列例子：

  ```c++
  struct CompanyA{
      void fun() { cout << 1 << endl;}
  };
  
  template <typename Company>
  struct F{
      void find_fun() {
          Company c;
          c.fun();
      }
  };
  
  struct CompanyZ{
      //不提供fun
  };
  
  
  //为了支持CompanZ,提供全特化版本
  template <>
  struct F<CompanyZ> {
      void no_fun() {}
  };
  
  
  template <typename Company>
  struct D : F<Company>{
      void test(){
          fun();  	//错误!
      }
      //? 如果继承的是特化版本的 F<CompanZ>, 则将不提供fun()函数!
      //? C++的政策是宁愿较早诊断, 所以, 当 base class 从 template 中被具现化时， 它假设它对那些base class的内容毫不清楚
  };
  
  
  ```

  

- **三个办法，解决此问题**

  - 在调用base class函数之前加上`this->`

    ```c++
    template <typename Company>
    struct D : F<Company>{
        void test(){
            this->find_fun();  
        }
    };
    ```

    

  - 使用using声明式

    ```c++
    template <typename Company>
    struct D : F<Company>{
        using F<Company>::find_fun;
        void test(){
            find_fun();  
        }
    };
    ```

    using在**条款33**中，用作解决base class名字被derived class名字遮盖。

    此处遇到的问题是，编译器不进入base class作用域内查找，于是我们通过using 告诉它，请它这么做

    

  - 明确指出使用的函数位于base class内（使用域作用符）

    ```c++
    template <typename Company>
    struct D : F<Company>{
        void test(){
            F<Company>::find_fun();  
        }
    };
    ```

    这是最不好的一个解法，因为如果被调用的是virtual函数，上述的行为会**逃避虚函数机制**（关闭了virtual的绑定行为）

    

- 综上所述，每一个解法的事情都相同，就是对编译器**承诺**base class template的全任何特化版本都将支持其一般（泛化）版本所提供的接口。**如果这个承诺最终没有实践出来，往后的编译还是会报错**

  

- 从根本上来说，本条款探讨的是，面对涉及base class member 的**无效reference**，编译器的诊断时间可能发生在**早期**（当解析derived class template的定义式时），也可能发生在**晚期**（当那些template被特定的template实参具现化时）。**C++的政策时宁愿较早诊断**。这就是为什么当base class 从template中被具现化时，**它假设它对那些base class的内容毫无所悉的缘故**



> **请记住**

- ***可在derived class template 内通过 `this->` 指涉 base class template 内的成员名称，或籍由一个明白写出的base class 资格修饰符完成***



####	条款44:将与参数无关的代码抽离template

p247

> **请记住**

- **template生成的多个class和多个函数，所以任何template代码都不该与某个造成膨胀的template参数产生依赖关系**
- **因非类型模板参数（non-type template parameter）而造成的代码膨胀，往往可消除，做法是以函数参数或class成员变量替换template参数**
- **因类型参数（type parameter）而造成的代码膨胀，往往可降低，做法是让带有完全相同二进制表述的具现类型共享实现码**





####	条款45：运用成员函数模板接受所有兼容类型

> 如何让自定义类型，发生up-cast动作时的构造函数更有弹性呢

拿智能指针举例：

- **使用成员模板，写出泛化的构造函数**

  我们需要的构造函数数量没有止尽，因为一个template可被无限量具现化，以致生成无限量函数。因此，我们为SmartPtr写一个构造模板`member template`

  ```c++
  template <typename T>
  class SmartPtr{
  public:
      template <typename U>
      SmartPtr(const SmartPtr<U>& other);
  }
  ```

  蓄意略去explicit，因为up-cast的动作是隐式的

- **约束泛化**

  当存在某个隐式转换可将一个指向U的指针转为一个指向T的指针，才能通过编译

  ```c++
  template <typename T>
  class SmartPtr{
  public:
      template <typename U>
      SmartPtr(const SmartPtr<U>& other)
    		: heldPtr(other.get()) {...}
      T* get() const { return heldPtr; }
  private:
      T* heldPtr;
  }	
  ```

  

- 成员函数模板不局限于构造函数

  ![image-20230314222138597](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230314222138597.png)

- **成员模板不改变语言规则**

  如果你声明了构造模板，没有声明拷贝模板。编译器**还是会为你自动生成一个**。在class内声明泛化copy构造函数并不会阻止编译器生成它们自己的copy构造函数。

  如果你想控制copy构造的方方面面，你必须同时声明泛化copy构造函数和正常的copy构造函数。

  

  

  

> **请记住**

- ***请使用member function template （成员函数模板）生成 ”可接受所有兼容类型“的函数***
- ***如果你声明member template 用于”泛化copy构造“或”泛化assignment操作“，你还是需要声明正常的copy 构造函数和copy assignment操作符***







####	条款46:需要类型转换时请为模板定义非成员函数

假如有个类模板：

```c++
template <typename T>
class R{
public:
    R(const T& n) :val(n) {}
    const T get_val() const { return val; }
 	....
private:
    T val;
};
```

我们想要重载operator*

- **首先，根据条款24：唯有non-member函数才能在所有实参身上实施隐式类型转换，所以我们要把operator*定义为non-member funciton**

  ```c++
  template <typename T>
  class R{ ... };
  
  template<typename T>
  const R<T> operator*(const R<T>& lhs, const R<T>& rhs){
      return lhs.get_val * rhs.get_val;
  }
  
  R<int> a = 1;
  R<int> res = a * 2;		// 错误!无法通过编译!
  ```



- **template实参推导过程中从不将隐式类型转换函数纳入考虑**

  在这里，编译器不知道我们想要调用哪个函数，它知道它可以具现化某个oprator*函数，但是它必须知道T是什么。

  问题就在于，编译器无法通过2来推断T，你希望编译器使用R<int>的non-explicit构造函数将2转换为R<int>，进而将T推导为int。但它不会这么做。template实参推导过程中从不将隐式类型转换函数纳入考虑

  

- **使用friend**

  由于class template不依赖实参推导，所以编译器总是能够在class template 具现化时得知T。

  ```c++
  template <typename T>
  class R{
  public:
  ....
  friend const R operator*(const R&, const R&);		//声明	在类内简化模板类名的书写
  };
  
  //定义
  const R<T> operator*(const R<T>& lhs, const R<T>& rhs){
      return lhs.get_val * rhs.get_val;
  }
  
  R<int> a = 1;			// R<int> 被实例化！
  R<int> res = a * 2;		// 通过编译! 但是会发生链接错误
  ```

  由于**对象a的定义**，class R<int> 被具现化出来，friend函数oprator*也就被自动声明出来，且是一个函数而非函数模板，因此编译器可以调用它时使用隐式转换函数。

  

- **在类内部声明并定义它**

  我们希望class外部的operator* template提供定义式，但是行不通（可能是要推导推断？）

  所以我们需要在class 内部声明并定义它

  ```c++
  template <typename T>
  class R{
  ....
  friend const R operator*(const R& lhs, const R& rhs){
      return lhs.get_val() * rhs.get_val();
      }
  };
  
  R<int> a = 1;			
  R<int> res = a * 2;		// 成功!
  ```

  

- **值得注意的是，我们虽然使用了friend，却和friend的传统用途“访问class的non-public成分”毫不相干**

  - 为了让类型转换发生在所有实参上，我们需要一个non-member函数；

  - 为了这个函数被具现化，我们需要把它声明在class 内部

  **而在class内部声明non-member函数的唯一办法就是：令它成为一个friend**

  

- **定义于class内部的函数都是隐式inline**

  我们可以将inline声明所带来的冲击最小化，做法是令operator*不做任何事情，只调用定义于class外部的辅助函数，如：

  ```c++
  template <typename T> class R;								//声明类模板
  
  template <typename T>
  const R<T> doMultiply(const R<T>& lhs, const R<T>& rhs);	//声明辅助函数
  
  template <typename T>
  class R{
  public:
      R(const T& n) :val(n) {}
      const T get_val() const { return val; }
  private:
      T val;
  friend const R operator*(const R& lhs, const R& rhs){
          doMultiply(lhs, rhs);
      }
  };
  
  template <typename T>
  const R<T> doMultiply(const R<T>& lhs, const R<T>& rhs){
      return R<T>(lhs.get_val() * rhs.get_val());
  }
  ```

  



> **请记住**

- **当我们编写一个class template，而它所提供之“与此template相关的”函数支持“所有参数之隐式类型转换”时，请将那些函数定义为“class template”内部的friend函数**







####	条款47:请使用traits class表现类型信息



- **复习STL迭代器分类（categories）**

  对于5种迭代器分类，C++STL分别提供专属的卷标结构（tag struct）加以确认

  ```c++
  /**
     *  @defgroup iterator_tags Iterator Tags
     *  These are empty types, used to distinguish different iterators.  The
     *  distinction is not made by what they contain, but simply by what they
     *  are.  Different underlying algorithms can then be used based on the
     *  different operations supported by different iterator types.
    */
    //@{ 
    ///  Marking input iterators.
    struct input_iterator_tag { };
  
    ///  Marking output iterators.
    struct output_iterator_tag { };
  
    /// Forward iterators support a superset of input iterator operations.
    struct forward_iterator_tag : public input_iterator_tag { };
  
    /// Bidirectional iterators support a superset of forward iterator
    /// operations.
    struct bidirectional_iterator_tag : public forward_iterator_tag { };
  
    /// Random-access iterators support a superset of bidirectional
    /// iterator operations.
    struct random_access_iterator_tag : public bidirectional_iterator_tag { };
    //@}
  ```

  

- 我们有时候需要取得类型的某些信息

  

- **使用traits在编译期间取得某些类型信息**

  Traits并不是C++关键字或一个预先定义好的构件；它们是一种技术，也是一个C++程序员共同遵守的协议。这个技术的要求之一是，它能同时支持内置（built-in）类型和用户自定义（user-defined）类型。

  Traits必须能够施加于内置类型意味着类型内嵌套信息这种东西出局了，因为我们无法嵌套于内置类型内。因此类型的traits信息必须位于类型自身之外。标准技术是把它放进一个template以其一或多个特化版本。这样的template在标准库中有若干个，针对迭代器的被命名为

  iterator_traits

  ```c++
  template<typename _Iterator>
      struct iterator_traits
      {
        typedef typename _Iterator::iterator_category iterator_category;
        typedef typename _Iterator::value_type        value_type;
        typedef typename _Iterator::difference_type   difference_type;
        typedef typename _Iterator::pointer           pointer;
        typedef typename _Iterator::reference         reference;
      };
  #endif
  
    /// Partial specialization for pointer types.
    template<typename _Tp>
      struct iterator_traits<_Tp*>
      {
        typedef random_access_iterator_tag iterator_category;
        typedef _Tp                         value_type;
        typedef ptrdiff_t                   difference_type;
        typedef _Tp*                        pointer;
        typedef _Tp&                        reference;
      };
  
    /// Partial specialization for const pointer types.
    template<typename _Tp>
      struct iterator_traits<const _Tp*>
      {
        typedef random_access_iterator_tag iterator_category;
        typedef _Tp                         value_type;
        typedef ptrdiff_t                   difference_type;
        typedef const _Tp*                  pointer;
        typedef const _Tp&                  reference;
      };
  ```

  算法通过迭代器来处理容器，迭代器需要回答算法的提问，需要给算法提供信息。

  为了区分迭代器和指针，不直接像迭代器提问，而是通过iterator_traits提问。iterator_traits通过模板的特化来区别迭代器和指针。

  iterator_traits的工作就是转告，像是鹦鹉学舌一样，重复迭代器说的话，但是遇到指针，iterator_traits通过特化来特供特殊服务。

  即编译期的多态。

- 用户自定义类型的迭代器类型“必须嵌套一个typedef”，名为iterator_category，用来确认适当的卷标结构

![image-20230318153408317](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230318153408317.png)





> 请记住

- Traits class使得“类型相关信息”在编译期可用。它们以template和template特化完成实现
- 整合重载技术（overloading）后，traits class 有可能在编译期对类型执行if...else测试





####	条款48:认识template元编程





> **请记住**

- **Template metaprogramming （TMP，模板元编程）可将工作由运行期移往编译期，因而得以实现早期错误侦测和更高的执行效率**
- **TMP 可被用来生成“基于政策选择组合”的客户定制代码，也可用来避免生成对某些特殊类型并不适合的代码**





##	定制new和delete

> ​	不同于Java和.NET的垃圾回收能力，C++对内存管理的纯手工法看起来有点老气，但是通过对程序使用内存的行为特征，然后修改分配和归还工作，以求获得最佳效率
>
> ​	这样做的前提是，了解C++内存管理例程的行为。本章的两个主角是分配例程和归还例程（allocation and deallocation routines，也就是operator new 和 operator delete），配角是new-handler，这是当operator new无法满足客户的内存需求时所调用的函数
>
> ​	多线程环境下的内存管理，遭受单线程系统不曾有过的挑战
>
> ​	最后注意，STL容器所使用的heap内存是由容器所拥有的分配器对象（allocator objects）管理，不是被new和delete直接管理。



####	条款49：了解new-handler的行为







> **请记住**

- ***set_new_handler允许客户指定一个函数，在内存分配无法获得满足时被调用***
- ***nothrow new时一个彼为局限的工具，因为它只适用于内存分配；后继的构造函数调用还是可能抛出异常***





####	条款50：了解new和delete的合理替换时机

首先，怎么会有人想要替换编译器提供的operator new或operator delete呢？

以下是三个最常见的理由：

- **用来检测运用上的错误**

- **为了强化效能**

  定制版的operator new 和operator delete性能胜过缺省版本，有时快很多，而且需要的内存比较少，最高可省50%

- **为了收集使用上的统计数据**



还有：

- 为了弥补缺省分配器中非最佳齐位（对齐）
- 为了获得非传统行为
- 为了将相关对象成簇集中





> **请记住**

- ***有许多理由需要写个自定义的new和delete，包括改善效能，对heap运用错误进行调试，收集heap使用信息***





####	条款51：编写new和delete时需固守常规





> ***请记住***

- ***operator new应该内含一个无穷循环，并在其中尝试分配内存,如果它无法满足内存需求,就该调用new-handle。它也应该有能力处理0 bytes申请。class专属版本还应该处理"比正确大小更大的(错误)申请"***

- ***operator delete应该在收到null指针时不做任何事，class专属版本则还应该处理"比正确大小更大的(错误)申请"***







####	条款52:写了placement new 也要写placement delete



> **请记住**

- ***当你写一个placement operator new，请确定也写出了对应的placement operator delete。如果没有这样做,你的程序可能会发生隐蔽而时断时续的内存泄漏***
- ***当你声明placement new和placement delete，请确定不要无意识(非故意)地遮掩了它们的正常版本。**











##	9.杂项讨论



####	条款53：不要轻视编译器的警告

- 编译器作者对于将要发生的事情比你有更好的领悟

  ```c++
  struct B{
      virtual void fun() const;
  };
  struct D : B{
      virtual void fun();
  };
  ```



![image-20230311141228069](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230311141228069.png)



> **请记住**

- ***严肃对待编译器发出的警告信息。努力在你的编译器的最高（最严苛）警告级别下争取“无任何警告”的荣誉***
- ***不要过度依赖编译器的报警能力，因为不同的编译器对待事情的态度并不相同。一旦移植到另一个编译器上，你原本依赖的警告信息有可能消失***



- 







- 















```c++
#include <bits/stdc++.h>
using namespace std;

const int dx[] = {-1,0,1,0}, dy[] = {0,1,0,-1};
int target = 123804765, start;
int arr[9], t[9] = {1,2,3,8,0,4,7,6,5};

//估价函数
int f(){
	int res = 0;
	for(int i = 0; i < 9; ++i){
		int j;
		for(j = 0; j < 9; ++j)
			if(t[i] == arr[j])	break;
		res += abs(i/3 - j/3) + abs(i%3 - j%3);
	}
	//cout << res << endl;
	return res;
}

void astar(){
	unordered_map<int,int> d;
	priority_queue<pair<int,int>,vector<pair<int,int>>,greater<pair<int,int>>> heap;	// x = 距离  y = 状态
	heap.push({f(),start});

	while(!heap.empty()){
		auto p = heap.top();	heap.pop();
		int pre = p.second;
		if(pre == target)	{ cout << d[pre] << endl; return; }

		int n = pre, z;
		for(int i = 8; i >= 0; --i){
			arr[i] = n % 10;
			n /= 10;
			if(!arr[i])	z = i;
		}
		int zx = z / 3, zy = z % 3;
		for(int i = 0; i < 4; ++i){
			int nx = zx + dx[i], ny = zy + dy[i];
			if(nx >= 0 && ny >= 0 && nx < 3 && ny < 3){
				swap(arr[z],arr[nx*3+ny]);
				int cur = 0;
				for(int i = 0; i < 9; ++i)	cur = cur * 10 + arr[i];

				if(!d.count(cur) || d[cur] > d[pre] + 1){
					d[cur] = d[pre] + 1;
					heap.push({d[cur]+f(),cur});
				}
				swap(arr[z],arr[nx*3+ny]);

			}
		}
	}
}


int main(){
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	freopen(".out","w",stdout);
	
	cin >> start;
	for(int n = start,i = 8; i >= 0; --i){
		arr[i] = n % 10;
		n /= 10;
	}
	astar();
	
	fclose(stdout);
	return 0;
}
```

