---
title: modern-effective-cplusplus
date: 2023-04-13 14:11:44
tags:
    - 计算机语言
---


# Effective Modern C++



##	简介



术语和惯例

- **C++14是C++11的超集**

  C++11支持lambda表达式(对C++11和C++14正确),C++14提供了普遍的函数返回类型推导(只对C++14正确)

  

- 对于判断一个表达式是否是左值的一个有用的启发就是,看看是否能取得它的地址

  ```c++
  class Widget{
  public:
      Widget(Widget&& rhs);		//rhs是一个左值
      ...
  };
  ```

  

- 实参(argument)与形参(parameter)

  实参被用来初始化函数的形参

  ```c++
  void fun(Widget w);
  Widget wid;
  
  fun(wid);
  fun(std::move(wid));
  ```

  形参w是左值，实参却可能是左值或右值。如果希望被传给函数的实参以原实参的右值性或左值性再传给第二个函数，参考完美转发Item 30

  

- 设计优良的函数时异常安全的

  

- 函数对象

  支持operator()成员函数的类型的对象

  

- 闭包

  通过lambda表达式创建的函数对象称为闭包

  

- 函数签名(signature)

- 未定义行为(undefined behavior)









##	1.类型推导

> Deducting Types



####	Item 1:理解模板类型推导

​	C++11最吸引人的特性之一`auto`是建立在模板类型推导的基础上的。但是，当模板类型推导规则应用于`auto`环境时，有时不如应用于template时那么直观。由于这个原因，真正理解`auto`基于的模板类型推导的方方面面非常重要。



```c++
template<typename T>
void f(ParamType param);
```

调用它类似这样：

```c++
f(expr);
```

在编译期间，编译器使用`expr`进行两个类型推导：一个是针对T的，另一个是针对`ParamType`的。这两个类型通常是不同的，因为`ParamType`

包含一些修饰，比如const和reference修饰符。举个例子：

```c++
template<typename T>
void f(const T& param);         //ParamType是const T&
```

然后这么调用

```c++
int x = 0;
f(x);				
```

T被推导为`int`，`ParamType`却被推导const int&

我们可能很自然的期望`T`和传递进函数的实参是相同的类型，也就是，T为`expr`的类型。但是事实总非如此；T的类型推导不仅取决于`expr`的类型，也取决于`ParamType`的类型。这里有三种情况：

- **`ParamType`是一个指针或引用，但不是通用引用（关于通用引用请参见[Item24](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item24.html)。在这里你只需要知道它存在，而且不同于左值引用和右值引用）**
- **`ParamType`是一个通用引用**
- **`ParamType`既不是指针也不是引用**





**情景一：ParamType是一个指针或引用，但不是通用引用**



- 如果`expr`的类型是一个引用，忽略引用部分

- 然后`expr`的类型与`ParamType`进行模式匹配来决定`T`

```c++
template<typename T>
void f(T& param);               //param是一个引用

int x=27;                       //x是int
const int cx=x;                 //cx是const int
const int& rx=x;                //rx是指向作为const int的x的引用

f(x);                           //T是int，param的类型是int&
f(cx);                          //T是const int，param的类型是const int&
f(rx);                          //T是const int，param的类型是const int&
```

​	在第二个和第三个调用中，注意因为`cx`和`rx`被指定为`const`值，所以`T`被推导为`const int`，从而产生了`const int&`的形参类型。这对于调用者来说很重要。当他们传递一个`const`对象给一个引用类型的形参时，他们期望对象保持不可改变性，也就是说，形参是reference-to-`const`的。这也是为什么将一个`const`对象传递给以`T&`类型为形参的模板安全的：对象的常量性`const`ness会被保留为`T`的一部分。

​	在第三个例子中，注意即使`rx`的类型是一个引用，`T`也会被推导为一个非引用 ，这是因为`rx`的引用性（reference-ness）在类型推导中会被忽略。

​	如果实参是右值引用，同样，T也会忽略实参的引用性。非通用引用不会区分左值实参和右值实参



对于指针，同理：

```c++
template<typename T>
void f(T* param);               //param现在是指针

int x = 27;                     //同之前一样
const int *px = &x;             //px是指向作为const int的x的指针

f(&x);                          //T是int，param的类型是int*
f(px);                          //T是const int，param的类型是const int*
```









**情景二：ParamType是一个通用引用**

- 如果`expr`是左值，`T`和`ParamType`都会被推导为左值引用。**这非常不寻常**，第一，**这是模板类型推导中唯一一种`T`被推导为引用的情况**。第二，虽然`ParamType`被声明为右值引用类型，但是最后推导的结果是左值引用。
- 如果`expr`是右值，就使用正常的（也就是**情景一**）推导规则

```c++
template<typename T>
void f(T&& param);              //param现在是一个通用引用类型
        
int x=27;                       //如之前一样
const int cx=x;                 //如之前一样
const int & rx=cx;              //如之前一样

f(x);                           //x是左值，所以T是int&，(template的例外规则)	
                                //param类型也是int&	   (发生引用折叠，T& && 折叠为 T&)

f(cx);                          //cx是左值，所以T是const int&，
                                //param类型也是const int&

f(rx);                          //rx是左值，所以T是const int&，
                                //param类型也是const int&

f(27);                          //27是右值，所以T是int，
                                //param类型就是int&&
```

[Item24](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item24.html)详细解释了为什么这些例子是像这样发生的。这里关键在于通用引用的类型推导规则是不同于普通的左值或者右值引用的。尤其是，当通用引用被使用时，类型推导**会区分**左值实参和右值实参，但是对非通用引用时不会区分。





**情景三：ParamType既不是指针也不是引用**

当`ParamType`既不是指针也不是引用时，我们通过传值（pass-by-value）的方式处理：

```c++
template<typename T>
void f(T param);                //以传值的方式处理param
```

这意味着无论传递什么`param`都会成为它的一份拷贝——一个完整的新对象。事实上`param`成为一个新对象这一行为会影响`T`如何从`expr`中推导出结果。

- 和之前一样，如果`expr`的类型是一个引用，忽略这个引用部分

- 如果忽略`expr`的引用性（reference-ness）之后，`expr`是一个`const`，那就再忽略`const`。如果它是`volatile`，也忽略`volatile`（`volatile`对象不常见，它通常用于驱动程序的开发中。关于`volatile`的细节请参见[Item40](https://cntransgroup.github.io/EffectiveModernCppChinese/7.TheConcurrencyAPI/item40.html)）

```c++
int x=27;                       //如之前一样
const int cx=x;                 //如之前一样
const int & rx=cx;              //如之前一样

f(x);                           //T和param的类型都是int
f(cx);                          //T和param的类型都是int
f(rx);                          //T和param的类型都是int
```



**认识到只有在传值给形参时才会忽略`const`（和`volatile`）这一点很重要**，正如我们看到的，对于reference-to-`const`和pointer-to-`const`形参来说，`expr`的常量性`const`ness在推导时会被保留。但是考虑这样的情况，`expr`是一个`const`指针，指向`const`对象，`expr`通过传值传递给`param`：

```c++
template<typename T>
void f(T param);                //仍然以传值的方式处理param

const char* const ptr =         //ptr是一个常量指针，指向常量对象 
    "Fun with pointers";

f(ptr);                         //传递const char * const类型的实参

```

根据类型推导的**第三条**规则，`ptr`自身的常量性`const`ness将会被省略，所以`param`是`const char*`，也就是一个可变指针指向`const`字符串。在类型推导中，这个指针指向的数据的常量性`const`ness将会被保留，但是当拷贝`ptr`来创造一个新指针`param`时，`ptr`自身的常量性`const`ness将会被忽略。



**数组实参**

上面的内容几乎覆盖了模板类型推导的大部分内容，但这里还有一些小细节值得注意：

```c++
const char name[] = "J. P. Briggs";     //name的类型是const char[13]

const char * ptrToName = name;          //数组退化为指针
```

将数组传值给一个模板，会发生什么：

```c++
template<typename T>
void f(T param);                        //传值形参的模板

f(name);                                //T和param会推导成什么类型?

f(name);                        		//name是一个数组，但是T被推导为const char*
```

但是现在难题来了，虽然函数不能声明形参为真正的数组，但是**可以**接受指向数组的**引用**！所以我们修改`f`为传引用：

```c++
template<typename T>
void f(T& param);                       //传引用形参的模板

f(name);								// T被推导为const char[13]
										// ParamType为const char (&)[13]
```



有趣的是，可声明指向数组的引用的能力，使得我们可以创建一个模板函数来推导出数组的大小：

```c++
//在编译期间返回一个数组大小的常量值
//数组形参没有名字，因为我们只关心数组的大小
template<typename T, std::size_t N>                     
constexpr std::size_t arraySize(T (&)[N]) noexcept      //注意:该函数是constexpr和noexcept
{                                                       
    return N;                                           
}                                                       
```

在[Item15](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item15.html)提到将一个函数声明为`constexpr`使得结果在**编译期间可用**。这使得我们可以用一个花括号声明一个数组，然后第二个数组可以使用第一个数组的大小作为它的大小，就像这样：

```c++
int keyVals[] = { 1, 3, 7, 9, 11, 22, 35 };             //keyVals有七个元素

int mappedVals[arraySize(keyVals)];                     //mappedVals也有七个
```



关于constexpr，我的补充

常量表达式（const expression）是指值不会改变并且在编译过程中就能得到计算结果的表达式。**一个对象是不是常量表达式由它的数据类型和初始值共同决定**

```c++
const int maxn = 20;				// maxn是常量表达式
const int limit = maxn + 10;		// limit是常量表达式
int rval = 22;						// rval不是常量表达式
const int sz = get_size();			// sz不是常量表达式
```

具体见primer.md



至于`arraySize`被声明为`noexcept`，会使得编译器生成更好的代码，具体的细节请参见[Item14](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item14.html)。



**函数实参**

在C++中不只是数组会退化为指针，函数类型也会退化为一个函数指针，我们对于数组类型推导的全部讨论都可以应用到函数类型推导和退化为函数指针上来。结果是：

```c++
void someFunc(int, double);         //someFunc是一个函数，
                                    //类型是void(int, double)

template<typename T>
void f1(T param);                   //传值给f1

template<typename T>
void f2(T & param);                 //传引用给f2

f1(someFunc);                       //param被推导为指向函数的指针，
                                    //类型是void(*)(int, double)
f2(someFunc);                       //param被推导为指向函数的引用，
                                    //类型是void(&)(int, double)
```

​	这里你需要知道：**`auto`依赖于模板类型推导**。正如我在开始谈论的，在大多数情况下它们的行为很直接。在通用引用中对于左值的特殊处理使得本来很直接的行为变得有些污点，然而，数组和函数退化为指针把这团水搅得更浑浊。有时你只需要编译器告诉你推导出的类型是什么。这种情况下，翻到[item4](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item4.html),它会告诉你如何让编译器这么做。



**我的总结：**

1. **对于T的推导是否有常量性，可以说，如果推导出来的T使得ParamType是底层const，那么T是const的，相反，如果推导出来的T使得ParamType是顶层const，那么T不会具有const（即顶层const）**
2. **除了通用引用，实参的引用一律被忽略掉**



> **请记住**

- ***在模板类型推导时，有引用的实参会被视为无引用，它们的引用会被忽略（类型一）***
- ***对于通用引用的推导，左值实参会被特殊对待（类型二）***
- ***对于传值类型推导，const或volatile实参会被认为是non-const的或non-volatile的（类型三）***
- ***在模板类型推导时，数组名或者函数名实参会退化为指针，除非它们被用于初始化引用***





####	item 2:理解auto类型推导

掌握了Item1的模板类型推导，那么你几乎已经知道了auto类型推导的大部分内容。



当一个变量使用`auto`进行声明时，`auto`扮演了模板中`T`的角色，变量的类型说明符扮演了`ParamType`的角色。

如：

```c++
template<typename T>            //概念化的模板用来推导x的类型
void func_for_x(T param);

func_for_x(27);                 //概念化调用：
                                //param的推导类型是x的类型

template<typename T>            //概念化的模板用来推导cx的类型
void func_for_cx(const T param);

func_for_cx(x);                 //概念化调用：
                                //param的推导类型是cx的类型

template<typename T>            //概念化的模板用来推导rx的类型
void func_for_rx(const T & param);

func_for_rx(x);                 //概念化调用：
                                //param的推导类型是rx的类型

```

[Item1](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item1.html)基于`ParamType`——在函数模板中`param`的类型说明符——的不同特征，把模板类型推导分成三个部分来讨论。在使用`auto`作为类型说明符的变量声明中，类型说明符代替了`ParamType`，因此Item1描述的三个情景稍作修改就能适用于auto：

- 情景一：类型说明符是一个指针或引用但不是通用引用
- 情景二：类型说明符一个通用引用
- 情景三：类型说明符既不是指针也不是引用

如：

```c++
auto x = 27;                    //情景三（x既不是指针也不是引用）
const auto cx = x;              //情景三（cx也一样）
const auto & rx=cx;             //情景一（rx是非通用引用）
```

情景二像你期待的一样运作：

```c++
auto&& uref1 = x;               //x是int左值，
                                //所以uref1类型为int&
auto&& uref2 = cx;              //cx是const int左值，
                                //所以uref2类型为const int&
auto&& uref3 = 27;              //27是int右值，
                                //所以uref3类型为int&&
```

[Item1](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item1.html)讨论并总结了对于non-reference类型说明符，数组和函数名如何退化为指针。那些内容也同样适用于`auto`类型推导：

```c++
const char name[] =             //name的类型是const char[13]
 "R. N. Briggs";

auto arr1 = name;               //arr1的类型是const char*
auto& arr2 = name;              //arr2的类型是const char (&)[13]

void someFunc(int, double);     //someFunc是一个函数，
                                //类型为void(int, double)

auto func1 = someFunc;          //func1的类型是void (*)(int, double)
auto& func2 = someFunc;         //func2的类型是void (&)(int, double)

```



讨论完相同点接下来就是不同点，前面我们已经说到`auto`类型推导和模板类型推导有一个例外使得它们的工作方式不同，接下来我们要讨论的就是那个例外。 我们从一个简单的例子开始，如果你想声明一个带有初始值27的`int`，C++98提供两种语法选择：

```c++
int x1 = 27;
int x2(27);
```

C++11由于增加了用于支持**统一初始化（uniform initialization）**的语法：

```c++
int x3 = { 27 };
int x4{ 27 };
```



如果使用auto声明一个存储一个元素，一个存储一个元素的std::initializer_list<int>类型的变量

```c++
auto x1 = 27;
auto x2(27);						//类型是int
auto x3 = { 27 };					//类型是std::initializer_list<int>
auto x4 { 27 };
```

这就造成了`auto`类型推导不同于模板类型推导的特殊情况。当用`auto`声明的变量使用花括号进行初始化，`auto`类型推导推出的类型则为`std::initializer_list`。如果这样的一个类型不能被成功推导（比如花括号里面包含的是不同类型的变量），编译器会拒绝这样的代码：

```c++
auto x5 = { 1, 2, 3.0 };        //错误！无法推导std::initializer_list<T>中的T
```





对于花括号的处理是`auto`类型推导和模板类型推导唯一不同的地方。当使用`auto`声明的变量使用花括号的语法进行初始化的时候，会推导出`std::initializer_list<T>`的实例化，但是对于模板类型推导这样就行不通：

```c++
auto x = { 11, 23, 9 };         //x的类型是std::initializer_list<int>

template<typename T>            //带有与x的声明等价的
void f(T param);                //形参声明的模板

f({ 11, 23, 9 });               //错误！不能推导出T

```



然而如果在模板中指定`T`是`std::initializer_list<T>`而留下未知`T`,模板类型推导就能正常工作：

```c++
template<typename T>
void f(std::initializer_list<T> initList);

f({ 11, 23, 9 });               //T被推导为int，initList的类型为
                                //std::initializer_list<int>
```



因此`auto`类型推导和模板类型推导的真正区别在于，**`auto`类型推导假定花括号表示`std::initializer_list`而模板类型推导不会这样**（确切的说是不知道怎么办）。



你可能想知道为什么`auto`类型推导和模板类型推导对于花括号有不同的处理方式。我也想知道。哎，我至今没找到一个令人信服的解释。但是规则就是规则，这意味着你必须记住如果你使用`auto`声明一个变量，并用花括号进行初始化，`auto`类型推导总会得出`std::initializer_list`的结果。如果你使用**uniform initialization（花括号的方式进行初始化）**用得很爽你就得记住这个例外以免犯错，在C++11编程中一个典型的错误就是偶然使用了`std::initializer_list<T>`类型的变量，这个陷阱也导致了很多C++程序员抛弃花括号初始化，只有不得不使用的时候再做考虑。（在[Item7](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item7.html)讨论了必须使用时该怎么做）



对于C++11故事已经说完了。但是对于C++14故事还在继续，**C++14允许`auto`用于函数返回值并会被推导**（参见[Item3](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item3.html)），而且**C++14的*lambda*函数也允许在形参声明中使用`auto`**。但是在这些情况下`auto`实际上使用**模板类型推导**的那一套规则在工作，而不是`auto`类型推导，所以说下面这样的代码不会通过编译：

```c++
auto createInitList()
{
    return { 1, 2, 3 };         //错误！不能推导{ 1, 2, 3 }的类型
}
```

我的补充：

除非使用尾置返回类型：

```c++
auto createInitList() -> initializer_list<int>
{
    return { 1, 2, 3 };         //正确！
}
```





同样在C++14的lambda函数中这样使用auto也不能通过编译**（auto作为lambda函数的形参）**：

```c++
std::vector<int> v;
…
auto resetV = 
    [&v](const auto& newValue){ v = newValue; };        //C++14
…
resetV({ 1, 2, 3 });            //错误！不能推导{ 1, 2, 3 }的类型
```







> **请记住**

- ***auto类型推导通常和模板类型推导相同，但是auto类型推导假定花括号初始化代表`std::initializer_list`，而模板类型推导不这样做***
- ***在C++14中auto运行出现在函数返回值或者`lambda`函数形参中，但是他的工作机制是模板类型推导那一套方案，而不是auto类型推导***
- ***我的补充：可以通过尾置返回类型来辅助auto推导返回类型。***





####	item 3:理解decltype

`decltype`是一个奇怪的东西。给它一个名字或者表达式`decltype`就会告诉你这个名字或者表达式的类型。通常，它会精确的告诉你你想要的结果。但有时候它得出的结果也会让你挠头半天，最后只能求助网上问答或参考资料寻求启示。



相比模板类型推导和`auto`类型推导（参见[Item1](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item1.html)和[Item2](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item2.html)），`decltype`只是简单的返回名字或者表达式的类型：

```c++
const int i = 0;                //decltype(i)是const int

bool f(const Widget& w);        //decltype(w)是const Widget&
                                //decltype(f)是bool(const Widget&)

struct Point{
    int x,y;                    //decltype(Point::x)是int
};                              //decltype(Point::y)是int

Widget w;                       //decltype(w)是Widget

if (f(w))…                      //decltype(f(w))是bool

template<typename T>            //std::vector的简化版本
class vector{
public:
    …
    T& operator[](std::size_t index);
    …
};

vector<int> v;                  //decltype(v)是vector<int>
…
if (v[0] == 0)…                 //decltype(v[0])是int&
```



在C++11中，**`decltype`最主要的用途就是用于声明函数模板**，而这个函数返回类型依赖于形参类型。



举个例子，假定我们写一个函数，一个形参为容器，一个形参为索引值，这个函数支持使用方括号的方式（也就是使用“`[]`”）访问容器中指定索引值的数据，然后在返回索引操作的结果前执行认证用户操作。函数的返回类型应该和索引操作返回的类型相同。



对一个`T`类型的容器使用`operator[]` 通常会返回一个`T&`对象，比如`std::deque`就是这样。但是`std::vector`有一个例外，对于`std::vector<bool>`，`operator[]`不会返回`bool&`，它会返回一个全新的对象。关于这个问题的详细讨论请参见[Item6](https://cntransgroup.github.io/EffectiveModernCppChinese/2.Auto/item6.html)，这里重要的是我们可以看到对一个容器进行`operator[]`操作返回的类型取决于容器本身。

使用`decltype`使得我们很容易去实现它，这是我们写的第一个版本，使用`decltype`计算返回类型，这个模板需要改良，我们把这个推迟到后面：

```c++
template<typename Container, typename Index>    //可以工作，
auto authAndAccess(Container& c, Index i)       //但是需要改良
    ->decltype(c[i])
{
    authenticateUser();
    return c[i];
}
```

函数名称前面的`auto`不会做任何的类型推导工作。相反的，他只是暗示使用了C++11的**尾置返回类型**语法，即在函数形参列表后面使用一个”`->`“符号指出函数的返回类型，尾置返回类型的好处是我们可以在函数返回类型中使用函数形参相关的信息。在`authAndAccess`函数中，我们使用`c`和`i`指定返回类型。如果我们按照传统语法把函数返回类型放在函数名称之前，`c`和`i`就未被声明所以不能使用。

在这种声明中，`authAndAccess`函数返回`operator[]`应用到容器中返回的对象的类型，这也正是我们期望的结果。

C++11允许自动推导单一语句的*lambda*表达式的返回类型， **C++14扩展到允许自动推导所有的*lambda*表达式和函数**，甚至它们内含多条语句。对于`authAndAccess`来说这意味着在C++14标准下我们可以忽略尾置返回类型，只留下一个`auto`。使用这种声明形式，auto标示这里会发生类型推导。更准确的说，编译器将会从函数实现中推导出函数的返回类型。

```c++
template<typename Container, typename Index>    //C++14版本，
auto authAndAccess(Container& c, Index i)       //不那么正确
{
    authenticateUser();
    return c[i];                                //从c[i]中推导返回类型
}
```

[Item2](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item2.html)解释了**函数返回类型中使用`auto`，编译器实际上是使用的模板类型推导的那套规则**。如果那样的话这里就会有一些问题。正如我们之前讨论的，`operator[]`对于大多数`T`类型的容器会返回一个`T&`，但是[Item1](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item1.html)解释了在模板类型推导期间，**表达式的引用性（reference-ness）会被忽略**。基于这样的规则，考虑它会对下面用户的代码有哪些影响：

```
std::deque<int> d;
…
authAndAccess(d, 5) = 10;               //认证用户，返回d[5]，
                                        //然后把10赋值给它
                                        //无法通过编译器！
```

在这里`d[5]`本该返回一个`int&`，**但是模板类型推导会剥去引用的部分**，因此产生了`int`返回类型。函数返回的那个`int`是一个右值，上面的代码尝试把10赋值给右值`int`，C++11禁止这样做，所以代码无法编译。



要想让`authAndAccess`像我们期待的那样工作，我们需要**使用`decltype`类型推导来推导它的返回值**，即指定`authAndAccess`应该返回一个和`c[i]`表达式类型一样的类型。C++期望在某些情况下当类型被暗示时需要使用`decltype`类型推导的规则，**C++14通过使用`decltype(auto)`说明符使得这成为可能**。我们第一次看见`decltype(auto)`可能觉得非常的矛盾（到底是`decltype`还是`auto`？），实际上我们可以这样解释它的意义：**`auto`说明符表示这个类型将会被推导，`decltype`说明`decltype`的规则将会被用到这个推导过程中。**因此我们可以这样写`authAndAccess`：

```c++
template<typename Container, typename Index>    //C++14版本，
decltype(auto)                                  //可以工作，
authAndAccess(Container& c, Index i)            //但是还需要
{                                               //改良
    authenticateUser();
    return c[i];
}
```

现在`authAndAccess`将会真正的返回`c[i]`的类型。现在事情解决了，一般情况下`c[i]`返回`T&`，`authAndAccess`也会返回`T&`，特殊情况下`c[i]`返回一个对象，`authAndAccess`也会返回一个对象。



`decltype(auto)`的使用不仅仅局限于函数返回类型，当你想对初始化表达式使用`decltype`推导的规则，你也可以使用：

```c++
Widget w;

const Widget& cw = w;

auto myWidget1 = cw;                    //auto类型推导
                                        //myWidget1的类型为Widget
decltype(auto) myWidget2 = cw;          //decltype类型推导
                                        //myWidget2的类型是const Widget&
```



但是这里有**两个问题**困惑着你。一个是我之前提到的`authAndAccess`的改良至今都没有描述。让我们现在加上它:

再看看C++14版本的`authAndAccess`声明：

```c++
template<typename Container, typename Index>
decltype(auto) authAndAccess(Container& c, Index i);
```

容器通过传引用的方式传递**非常量左值引用（lvalue-reference-to-non-const）**，因为返回一个引用允许用户可以修改容器。但是这意味着在**不能给这个函数传递右值容器**，**右值不能被绑定到左值引用上（除非这个左值引用是一个const（lvalue-references-to-const）**，但是这里明显不是）。



公认的向`authAndAccess`传递一个右值是一个[edge case](https://en.wikipedia.org/wiki/Edge_case)（译注：在极限操作情况下会发生的事情，类似于会发生但是概率较小的事情）。一个右值容器，是一个临时对象，通常会在`authAndAccess`调用结束被销毁，这意味着`authAndAccess`返回的引用将会成为一个**悬置的（dangle）引用**。但是使用向`authAndAccess`传递一个临时变量也并不是没有意义，有时候用户可能只是想简单的获得临时容器中的一个元素的拷贝，比如这样：

```c++
std::deque<std::string> makeStringDeque();      //工厂函数

//从makeStringDeque中获得第五个元素的拷贝并返回
auto s = authAndAccess(makeStringDeque(), 5);

```



要想支持这样使用`authAndAccess`我们就得修改一下当前的声明使得它支持左值和右值。重载是一个不错的选择（一个函数重载声明为左值引用，另一个声明为右值引用），但是我们就不得不维护两个重载函数。另一个方法是使`authAndAccess`的引用可以绑定左值和右值，[Item24](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item24.html)解释了那正是**通用引用**能做的，所以我们这里可以使用通用引用进行声明：

```c++
template<typename Containter, typename Index>   //现在c是通用引用
decltype(auto) authAndAccess(Container&& c, Index i);			// 既可绑定左值，也能绑定右值
```



**然而，我们还需要更新一下模板的实现，让它能听从[Item25](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item25.html)的告诫应用`std::forward`实现通用引用：** **没看懂这段**

```c++
template<typename Container, typename Index>    //最终的C++14版本
decltype(auto)
authAndAccess(Container&& c, Index i)
{
    authenticateUser();
    return std::forward<Container>(c)[i];		//why?
}
```



这样就能对我们的期望交上一份满意的答卷，但是这要求**编译器支持C++14**。如果你没有这样的编译器，你还需要使用C++11版本的模板，它看起来和C++14版本的极为相似，除了你不得不指定函数返回类型之外：

```c++
template<typename Container, typename Index>    //最终的C++11版本
auto
authAndAccess(Container&& c, Index i)
->decltype(std::forward<Container>(c)[i])
{
    authenticateUser();
    return std::forward<Container>(c)[i];
}

```



**另一个问题**是，`decltype`通常会产生你期望的结果，但并不总是这样。在**极少数情况下**它产生的结果可能让你很惊讶。老实说如果你不是一个大型库的实现者你不太可能会遇到这些异常情况:

将`decltype`应用于变量名会产生该变量名的声明类型。虽然变量名都是左值表达式，但这不会影响`decltype`的行为。（译者注：这里是说对于单纯的变量名，`decltype`只会返回变量的声明类型）然而，对于比单纯的变量名更复杂的**左值表达式**，**`decltype`可以确保报告的类型始终是左值引用**。也就是说，**如果一个不是单纯变量名的左值表达式的类型是`T`，那么`decltype`会把这个表达式的类型报告为`T&`**。这几乎没有什么太大影响，因为大多数左值表达式的类型天生具备一个左值引用修饰符。例如，返回左值的函数总是返回左值引用。

```c++
int x = 0;
decltype(x) y1;					// y1的类型是int		
decltype((x)) y2 = x;			// y2的类型是int&
```





在C++11中这稍微有点奇怪，但是由于C++14允许了`decltype(auto)`的使用，这意味着你在函数返回语句中细微的改变就可以影响类型的推导：

```c++
decltype(auto) f1()
{
    int x = 0;
    …
    return x;                            //decltype(x）是int，所以f1返回int
}

decltype(auto) f2()
{
    int x = 0;
    return (x);                          //decltype((x))是int&，所以f2返回int&
}

```

注意不仅`f2`的返回类型不同于`f1`，而且它还引用了一个局部变量！这样的代码将会把你送上**未定义行为**的特快列车，一辆你绝对不想上第二次的车。

当使用`decltype(auto)`的时候一定要加倍的小心，在表达式中看起来无足轻重的细节将会影响到`decltype(auto)`的推导结果。为了确认类型推导是否产出了你想要的结果，请参见[Item4](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item4.html)描述的那些技术。



同时你也不应该忽略`decltype`这块大蛋糕。没错，`decltype`（单独使用或者与`auto`一起用）可能会偶尔产生一些令人惊讶的结果，但那毕竟是少数情况。通常，`decltype`都会产生你想要的结果，尤其是当你对一个变量使用`decltype`时，因为在这种情况下，`decltype`只是做一件本分之事：它产出变量的声明类型。

> **请记住**

- ***`decltype`总是不加修改的产生变量或表达式的类型***
- ***对于`T`类型的不是单纯变量名的左值表达式，decltype总是产出`T`的引用即`T&`***
- ***C++14支持`decltype(auto)`，就像`auto`一样，推导出类型，但是它使用`decltype`的规则进行推导***



####	item 4:学会查看类型推导结果

选择使用工具查看类型推导，取决于软件开发过程中你想在哪个阶段显示类型推导信息。**我们探究三种方案：在你编辑代码的时候获得类型推导的结果，在编译期间获得结果，在运行时获得结果。**



- **IDE编辑器**

  在IDE中的代码编辑器通常可以显示程序代码中变量，函数，参数的类型，你只需要简单的把鼠标移到它们的上面

  

- **编译器诊断**

  另一个获得推导结果的方法是使用编译器出错时提供的错误消息。这些错误消息无形的提到了造成我们编译错误的类型是什么。

  ```c++
  template<typename T>                //只对TD进行声明
  class TD;                           //TD == "Type Displayer"
  
  TD<decltype(x)> xType;              //引出包含x和y
  TD<decltype(y)> yType;              //的类型的错误消息
  ```

  编译器可能产生这样的错误信息：

  ```bash
  error: aggregate 'TD<int> xType' has incomplete type and 
          cannot be defined
  error: aggregate 'TD<const int *> yType' has incomplete type and
          cannot be defined
  ```

  我使用***variableName*****Type**的结构来命名变量，因为这样它们产生的错误消息可以有助于我们查找。

  

- **运行时输出**

  使用`printf`的方法使类型信息只有在运行时才会显示出来（尽管我不是非常建议你使用`printf`），但是它提供了一种格式化输出的方法。现在唯一的问题是只需对于你关心的变量使用一种优雅的文本表示。“这有什么难的，“你这样想，”这正是`typeid`和`std::type_info::name`的价值所在”。为了实现我们想要查看`x`和`y`的类型的需求，你可能会这样写：

  ```c++
  std::cout << typeid(x).name() << '\n';  //显示x和y的类型
  std::cout << typeid(y).name() << '\n';
  ```

  **这种方法对一个对象如`x`或`y`调用`typeid`产生一个`std::type_info`的对象，然后`std::type_info`里面的成员函数`name()`来产生一个C风格的字符串（即一个`const char*`）表示变量的名字。**

  调用`std::type_info::name`不保证返回任何有意义的东西，但是库的实现者尝试尽量使它们返回的结果有用。实现者们对于“有用”有不同的理解。举个例子，G**NU和Clang环境下`x`的类型会显示为”`i`“，`y`会显示为”`PKi`“**，这样的输出你必须要问问编译器实现者们才能知道他们的意义：”`i`“表示”`int`“，”`PK`“表示”pointer to const“（指向常量的指针）。（这些编译器都提供一个工具`c++filt`，解释这些“混乱的”类型）Microsoft的编译器输出得更直白一些：对于`x`输出”`int`“对于`y`输出”`int const *`“

  **对于复杂的类型，这种方法不一定正确：**

  ```c++
  template<typename T>
  void f(const T& param)
  {
      using std::cout;
      cout << "T =     " << typeid(T).name() << '\n';             //显示T
  
      cout << "param = " << typeid(param).name() << '\n';         //显示
      …                                                           //param
  }                                                               //的类型
  
  ```

  Microsoft的编译器的结果是：

  ```bash
  T =     class Widget const *
  param = class Widget const *
  ```

  遗憾的是，事实就是这样，**`std::type_info::name`的结果并不总是可信的**，就像上面一样，三个编译器对`param`的报告都是错误的。因为它们本质上可以不正确，**因为`std::type_info::name`规范批准像传值形参一样来对待这些类型。**正如[Item1](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item1.html)提到的，**如果传递的是一个引用，那么引用部分（reference-ness）将被忽略**，**如果忽略后还具有`const`或者`volatile`，那么常量性`const`ness或者易变性`volatile`ness也会被忽略。**那就是为什么`param`的类型`const Widget * const &`会输出为`const Widget *`，首先引用被忽略，然后这个指针自身的常量性`const`ness被忽略，剩下的就是指针指向一个常量对象。

  

  同样遗憾的是，IDE编辑器显示的类型信息也不总是可靠的，或者说不总是有用的。还是一样的例子，一个IDE编辑器可能会把`T`的类型显示		为（我没有胡编乱造）：

  ```bash
  const
  std::_Simple_types<std::_Wrap_alloc<std::_Vec_base_types<Widget,
  std::allocator<Widget>>::_Alloc>::value_type>::value_type *
  
  const std::_Simple_types<...>::value_type *const &
  
  ```

- **使用Boost TypeIndex库**

  Boost TypeIndex库（通常写作**Boost.TypeIndex**）是更好的选择。这个库不是标准C++的一部分，也不是IDE或者`TD`这样的模板。Boost库是跨平台，开源，有良好的开源协议的库，这意味着使用Boost和STL一样具有高度可移植性。

  这里是如何使用Boost.TypeIndex得到`f`的类型的代码

  ```c++
  #include <boost/type_index.hpp>
  
  template<typename T>
  void f(const T& param)
  {
      using std::cout;
      using boost::typeindex::type_id_with_cvr;
  
      //显示T
      cout << "T =     "
           << type_id_with_cvr<T>().pretty_name()
           << '\n';
      
      //显示param类型
      cout << "param = "
           << type_id_with_cvr<decltype(param)>().pretty_name()
           << '\n';
  }
  ```

  `boost::typeindex::type_id_with_cvr`获取一个类型实参（我们想获得相应信息的那个类型），它不消除实参的`const`，`volatile`和引用修饰符（**因此模板名中有“`with_cvr`”**）。**结果是一个`boost::typeindex::type_index`对象，它的`pretty_name`成员函数输出一个`std::string`**，包含我们能看懂的类型表示。 基于这个`f`的实现版本，再次考虑那个使用`typeid`时获取`param`类型信息出错的调用：

  ```c++
  std::vetor<Widget> createVec();         //工厂函数
  const auto vw = createVec();            //使用工厂函数返回值初始化vw
  if (!vw.empty()){
      f(&vw[0]);                          //调用f
      …
  }
  //在GNU和Clang的编译器环境下，使用Boost.TypeIndex版本的f最后会产生下面的（准确的）输出：
  T =     Widget const *
  param = Widget const * const&
  
  ```



这样近乎一致的结果是很不错的，**但是请记住IDE，编译器错误诊断或者像Boost.TypeIndex这样的库只是用来帮助你理解编译器推导的类型是什么**。它们是起辅助性作用的，但是作为本章结束语我想说它们根本不能替代你对[Item1](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item1.html)-[3](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item3.html)提到的类型推导的理解。



> **请记住**

- ***类型推断可以从IDE看出，从编译器报错看出，从Boost TypeIndex库的使用看出***
- ***这些工具可能既不准确也无帮助，所以理解C++类型推导规则才是最重要的***





##	2.auto

> 从概念上来说，`auto`要多简单有多简单，但是它比看起来更微妙一些。使用它可以存储类型，当然，它也会犯一些错误，而且而且比之手动声明一些复杂类型也会存在一些性能问题。此外，从程序员的角度来说，如果按照符合规定的流程走，那`auto`类型推导的一些结果是错误的。当这些情况发生时，对我们来说引导`auto`产生正确的结果是很重要的，因为严格按照说明书上面的类型写声明虽然可行但是最好避免。
>
> 本章简单的覆盖了`auto`的里里外外。





####	Item 5:优先考虑auto而非显式类型声明



先简单的看一个例子：

```c++
template<typename It>           //对从b到e的所有元素使用
void dwim(It b, It e)           //dwim（“do what I mean”）算法
{
    while (b != e) {
        typename std::iterator_traits<It>::value_type
        currValue = *b;
        …
    }
}
```

在Effective C++中，`typename std::iterator_traits<It>::value_type`是想表达迭代器指向的元素的值类型。

该类型是一个闭包，闭包的类型只有编译器知道，因此我们写不出来。

到了C++11，多亏了`auto`

`auto`变量从初始化表达式中推导出类型，所以我们必须初始化

```c++
int x1;                         //潜在的未初始化的变量
    
auto x2;                        //错误！必须要初始化

auto x3 = 0;                    //没问题，x已经定义了
```

而且即使使用解引用迭代器初始化局部变量也不会对你的高速驾驶有任何影响

```c++
template<typename It>           //如之前一样
void dwim(It b,It e)
{
    while (b != e) {
        auto currValue = *b;
        …
    }
}
```

因为使用[Item2](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item2.html)所述的`auto`类型推导技术，它甚至能表示一些只有编译器才知道的类型：

```c++
auto derefUPLess = 
    [](const std::unique_ptr<Widget> &p1,       //用于std::unique_ptr
       const std::unique_ptr<Widget> &p2)       //指向的Widget类型的
    { return *p1 < *p2; };                      //比较函数
```

很酷对吧，如果使用C++14，将会变得更酷，因为*lambda*表达式中的形参也可以使用`auto`：

```c++
auto derefLess =                                //C++14版本
    [](const auto& p1,                          //被任何像指针一样的东西
       const auto& p2)                          //指向的值的比较函数
    { return *p1 < *p2; };
```

尽管这很酷，但是你可能会想我们完全不需要使用`auto`声明局部变量来保存一个闭包，因为我们可以使用**`std::function`对象**。没错，我们的确可以那么做，但是事情可能不是完全如你想的那样。当然现在你可能会问，`std::function`对象到底是什么。让我来给你解释一下。

**`std::function`是一个C++11标准模板库中的一个模板，它泛化了函数指针的概念**。与函数指针只能指向函数不同，`std::function`可以指向任何可调用对象，也就是那些像函数一样能进行调用的东西。当你声明函数指针时你必须指定函数类型（即函数签名），同样当你创建`std::function`对象时你也需要**提供函数签名**，由于它是一个模板所以你需要在它的模板参数里面提供。举个例子，假设你想声明一个`std::function`对象`func`使它指向一个可调用对象，比如一个具有这样函数签名的函数，

```c++
bool(const std::unique_ptr<Widget> &,           //C++11
     const std::unique_ptr<Widget> &)           //std::unique_ptr<Widget>
                                                //比较函数的签名
```

你就得这么写：

```c++
std::function<bool(const std::unique_ptr<Widget> &,
                   const std::unique_ptr<Widget> &)> func;
```

因为*lambda*表达式能产生一个可调用对象，所以我们现在可以把闭包存放到`std::function`对象中。这意味着我们可以不使用`auto`写出C++11版的`derefUPLess`：

```c++
std::function<bool(const std::unique_ptr<Widget> &,
                   const std::unique_ptr<Widget> &)>
derefUPLess = [](const std::unique_ptr<Widget> &p1,
                 const std::unique_ptr<Widget> &p2)
                { return *p1 < *p2; };
```

语法冗长不说，还需要重复写很多形参类型，使用`std::function`还不如使用`auto`。**用`auto`声明的变量保存一个和闭包一样类型的（新）闭包，因此使用了与闭包相同大小存储空间**。实例化`std::function`并声明一个对象这个对象将会有**固定的大小**。**这个大小可能不足以存储一个闭包**，**这个时候`std::function`的构造函数将会在堆上面分配内存来存储，这就造成了使用`std::function`比`auto`声明变量会消耗更多的内存**。**并且通过具体实现我们得知通过`std::function`调用一个闭包几乎无疑比`auto`声明的对象调用要慢**。换句话说，**`std::function`方法比`auto`方法要更耗空间且更慢，还可能有*out-of-memory*异常**。并且正如上面的例子，比起写`std::function`实例化的类型来，使用`auto`要方便得多。**在这场存储闭包的比赛中，`auto`无疑取得了胜利**（也可以使用`std::bind`来生成一个闭包，但在[Item34](https://cntransgroup.github.io/EffectiveModernCppChinese/6.LambdaExpressions/item34.html)我会尽我最大努力说服你使用*lambda*表达式代替`std::bind`)

使用`auto`除了可以避免未初始化的无效变量，省略冗长的声明类型，直接保存闭包外，它还有一个好处是可以避免一个问题，我称之为与**类型快捷方式（type shortcuts）**有关的问题。你将看到这样的代码——甚至你会这么写：

```c++
std::vector<int> v;
…
unsigned sz = v.size();
```

`v.size()`的标准返回类型是`std::vector<int>::size_type`，但是只有少数开发者意识到这点。`std::vector<int>::size_type`实际上被指定为无符号整型，所以很多人都认为用`unsigned`就足够了，写下了上述的代码。这会造成一些有趣的结果。举个例子，在**Windows 32-bit**上`std::vector<int>::size_type`和`unsigned`是一样的大小，但是在**Windows 64-bit**上`std::vector<int>::size_type`是64位，`unsigned`是32位。这意味着这段代码在Windows 32-bit上正常工作，但是当把应用程序移植到Windows 64-bit上时就可能会出现一些问题。谁愿意花时间处理这些细枝末节的问题呢？

所以使用`auto`可以确保你不需要浪费时间：

```c++
auto sz =v.size();                      //sz的类型是std::vector<int>::size_type
```

你还是不相信使用`auto`是多么明智的选择？考虑下面的代码：

```c++
std::unordered_map<std::string, int> m;
…

for(const std::pair<std::string, int>& p : m)
{
    …                                   //用p做一些事
}
```

看起来好像很合情合理的表达，但是这里有一个问题，你看到了吗？

要想看到错误你就得知道**`std::unordered_map`的*key*是`const`的**，所以*hash table*（`std::unordered_map`本质上的东西）中的`std::pair`的类型不是`std::pair<std::string, int>`，**而是`std::pair<const std::string, int>`**。但那不是在循环中的变量`p`声明的类型。编译器会努力的找到一种方法把`std::pair<const std::string, int>`（即*hash table*中的东西）转换为`std::pair<std::string, int>`（`p`的声明类型）。它会成功的，因为它会通过**拷贝`m`中的对象创建一个临时对象(因为是常量引用，所以可以创建临时对象并绑定)**，这个临时对象的类型是`p`想绑定到的对象的类型，即`m`中元素的类型，然后把`p`的引用绑定到这个临时对象上。**在每个循环迭代结束时，临时对象将会销毁**，如果你写了这样的一个循环，你可能会对它的一些行为感到非常惊讶，因为你确信你只是让成为`p`指向`m`中各个元素的引用而已。

使用`auto`可以避免这些很难被意识到的类型不匹配的错误：

```c++
for(const auto& p : m)
{
    …                                   //如之前一样
}

```

**这样无疑更具效率，且更容易书写**。而且，这个代码有一个非常吸引人的特性，如果你获取`p`的地址，你确实会得到一个指向`m`中元素的指针。在没有`auto`的版本中`p`会指向一个临时变量，这个临时变量在每次迭代完成时会被销毁。

前面这两个例子——应当写`std::vector<int>::size_type`时写了`unsigned`，应当写`std::pair<const std::string, int>`时写了`std::pair<std::string, int>`——**说明了显式的指定类型可能会导致你不想看到的类型转换**。如果你使用`auto`声明目标变量你就不必担心这个问题。

基于这些原因我建议你**优先考虑`auto`而非显式类型声明**。然而`auto`也不是完美的。每个`auto`变量都从初始化表达式中推导类型，有一些表达式的类型和我们期望的大相径庭。关于在哪些情况下会发生这些问题，以及你可以怎么解决这些问题我们在[Item2](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item2.html)和[6](https://cntransgroup.github.io/EffectiveModernCppChinese/2.Auto/item6.html)讨论，所以这里我不再赘述。我想把注意力放到你可能关心的另一点：使用auto代替传统类型声明对源码可读性的影响。

首先，深呼吸，放松，`auto`是**可选项**，不是**命令**，在某些情况下如果你的**专业判断告诉你使用显式类型声明比`auto`要更清晰更易维护，那你就不必再坚持使用`auto`**。但是要牢记，C++没有在其他众所周知的语言所拥有的**类型推导（*type inference*）**上开辟新土地。其他静态类型的过程式语言（如C#、D、Sacla、Visual Basic）或多或少都有等价的特性，更不必提那些静态类型的函数式语言了（如ML、Haskell、OCaml、F#等）。在某种程度上，这是因为动态类型语言，如Perl、Python、Ruby等的成功；在这些语言中，几乎没有显式的类型声明。软件开发社区对于类型推导有丰富的经验，他们展示了在维护大型工业强度的代码上使用这种技术没有任何争议。

一些开发者也担心使用`auto`就不能瞥一眼源代码便知道对象的类型，然而，IDE扛起了部分担子（也考虑到了[Item4](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item4.html)中提到的IDE类型显示问题），在很多情况下，少量显示一个对象的类型对于知道对象的确切类型是有帮助的，这通常已经足够了。举个例子，要想知道一个对象是容器还是计数器还是智能指针，不需要知道它的确切类型。一个**适当的变量名**称就能告诉我们大量的抽象类型信息。

事实是**显式地写出类型可能会引入一些难以察觉的错误，导致正确性或者效率问题，或者两者兼而有之**。除此之外，**auto 类型会随着初始化它的表达式自动改变，这意味着使用 auto，代码重构可以变得更简单**。例如，如果一个函数被声明为返回 int，但是你稍后决定返 回 long 可能更好一些，如果你把这个函数的返回值存储在一个 auto 变量中，在下次编译的 时候，调用代码将会自动的更新。如果返回值存储在一个显式声明为 int 的变量中，你需要 找到所有调用这个函数的地方然后改写他们。



> **请记住**

- ***`auto`变量必须初始化，通常它可以避免一些移植性和效率性的问题，也使得重构更方便，还能让你少打几个字***
- ***正如[Item2](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item2.html)和[6](https://cntransgroup.github.io/EffectiveModernCppChinese/2.Auto/item6.html)讨论的，`auto`类型的变量可能会踩到一些陷阱。***



####	item 6:auto推导若非已愿，使用显式类型初始化惯用法

​	条款 5 解释了，使用 auto 声明变量，比直接显式声明类型具备一系列的技术优势，**但有时候 auto 的类型推导会和你想的南辕北辙**。举个例子，假如我有一个函数，参数为`Widget`，返回一个`std::vector<bool>`，这里的`bool`表示`Widget`是否提供一个独有的特性:

```c++
std::vector<bool> features(const Widget& w);
```

更进一步假设第5个*bit*表示`Widget`是否具有高优先级，我们可以写这样的代码：

```c++
Widget w;
…
bool highPriority = features(w)[5];     //w高优先级吗？
…
processWidget(w, highPriority);         //根据它的优先级处理w
```

这个代码没有任何问题。它会正常工作，但是如果我们使用`auto`代替`highPriority`的显式指定类型做一些看起来很无害的改变：

```c++
auto highPriority = features(w)[5];     //w高优先级吗？
```

情况变了。所有代码仍然可编译，但是行为不再可预测：

```c++
processWidget(w,highPriority);          //未定义行为！
```

就像注释说的，这个`processWidget`是一个未定义行为。为什么呢？答案有可能让你很惊讶，使用`auto`后`highPriority`不再是`bool`类型。虽然从概念上来说`std::vector<bool>`意味着存放`bool`，但是`std::vector<bool>`的`operator[]`不会返回容器中元素的引用（这就是`std::vector::operator[]`可返回**除了`bool`以外**的任何类型），取而代之它返回一个**`std::vector<bool>::reference`的对象（一个嵌套于`std::vector<bool>`中的类）**。



**`std::vector<bool>::reference`之所以存在是因为`std::vector<bool>`做了特化，bool值做了封包处理，每个`bool`占一个*bit*。**



这就给给`std::vector`的`operator[]`带来了问题，因为`std::vector<T>`的`operator[]`应当返回一个`T&`，但是**C++禁止对`bit`s的引用**。无法返回一个`bool&`，`std::vector<bool>`的`operator[]`返回一个**行为类似于**`bool&`的对象。要想成功扮演这个角色，`bool&`适用的上下文`std::vector<bool>::reference`也必须一样能适用。在`std::vector<bool>::reference`的特性中，使这个原则可行的特性是一个可以向`bool`的隐式转化。（不是`bool&`，是**`bool`**。要想完整的解释`std::vector<bool>::reference`能模拟`bool&`的行为所使用的一堆技术可能扯得太远了，所以这里简单地提一下）

有了这些信息，我们再来看看原始代码的一部分：

```c++
bool highPriority = features(w)[5];     //显式的声明highPriority的类型
```

这里，`features`返回一个`std::vector<bool>`对象后再调用`operator[]`，`operator[]`将会返回一个`std::vector<bool>::reference`对象，然后再通过隐式转换赋值给`bool`变量`highPriority`。`highPriority`因此表示的是`features`返回的`std::vector<bool>`中的第五个*bit*，这也正如我们所期待的那样。

然后再对照一下当使用`auto`时发生了什么：

```c++
auto highPriority = features(w)[5];     //推导highPriority的类型
```

同样的，`features`返回一个`std::vector<bool>`对象，再调用`operator[]`，`operator[]`将会返回一个`std::vector<bool>::reference`对象，但是现在这里有一点变化了，`auto`推导`highPriority`的类型为`std::vector<bool>::reference`，但是`highPriority`对象没有第五*bit*的值。

这个**值取决于`std::vector<bool>::reference`的具体实现**。一种实现是，（`std::vector<bool>::reference`）对象包含一个指向机器字（*word*）的指针，然后加上方括号中的偏移实现被引用*bit*这样的行为。然后再来考虑`highPriority`初始化表达的意思，注意这里假设`std::vector<bool>::reference`就是刚提到的实现方式。

调用`features`将返回一个`std::vector<bool>`临时对象，这个对象没有名字，为了方便我们的讨论，我这里叫他`temp`。`operator[]`在`temp`上调用，它返回的`std::vector<bool>::reference`包含一个指向存着这些*bit*s的一个数据结构中的一个*word*的指针（`temp`管理这些*bit*s），还有相应于第5个*bit*的偏移。`highPriority`是这个`std::vector<bool>::reference`的拷贝，所以`highPriority`也包含一个指针，指向`temp`中的这个*word*，加上相应于第5个*bit*的偏移。在这个语句结束的时候`temp`将会被销毁，因为它是一个临时变量。**因此`highPriority`包含一个悬置的（*dangling*）指针**，如果用于`processWidget`调用中将会造成未定义行为：

```c++
processWidget(w, highPriority);         //未定义行为！
                                        //highPriority包含一个悬置指针！
```

`std::vector<bool>::reference`是一个**代理类（*proxy class*）**的例子：所谓代理类就是以模仿和增强一些类型的行为为目的而存在的类。很多情况下都会使用代理类，`std::vector<bool>::reference`展示了对`std::vector<bool>`使用`operator[]`来实现引用*bit*这样的行为。另外，C++标准模板库中的智能指针（见[第4章](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item18.html)）也是用代理类实现了对原始指针的资源管理行为。代理类的功能已被大家广泛接受。事实上，“Proxy”设计模式是软件设计这座万神庙中一直都存在的高级会员。

一些代理类被设计于用以对客户可见。比如`std::shared_ptr`和`std::unique_ptr`。其他的代理类则或多或少不可见，比如**`std::vector<bool>::reference`就是不可见代理类的一个例子，还有它在`std::bitset`的胞弟`std::bitset::reference`**。

在后者的阵营（注：指不可见代理类）里一些C++库也是用了表达式模板（*expression templates*）的黑科技。这些库通常被用于提高数值运算的效率。给出一个矩阵类`Matrix`和矩阵对象`m1`，`m2`，`m3`，`m4`，举个例子，这个表达式:

```c++
Matrix sum = m1 + m2 + m3 + m4;
```

可以使计算更加高效，只需要使让`operator+`返回一个代理类代理结果而不是返回结果本身。也就是说，对两个`Matrix`对象使用`operator+`将会返回如`Sum<Matrix, Matrix>`这样的代理类作为结果而不是直接返回一个`Matrix`对象。在`std::vector<bool>::reference`和`bool`中存在一个隐式转换，同样对于`Matrix`来说也可以存在一个隐式转换允许`Matrix`的代理类转换为`Matrix`，这让表达式等号“`=`”右边能产生代理对象来初始化`sum`。（这个对象应当编码整个初始化表达式，即类似于`Sum<Sum<Sum<Matrix, Matrix>, Matrix>, Matrix>`的东西。这显然应该对客户屏蔽）



**作为一个通则，不可见的代理类通常不适用于`auto`**。这样类型的对象的生命期通常不会设计为能活过一条语句，所以创建那样的对象你基本上就走向了违反程序库设计基本假设的道路。`std::vector<bool>::reference`就是这种情况，我们看到违反这个基本假设将导致未定义行为。

因此你应该避开这种形式的代码：

```c++
auto someVar = expression of "invisible" proxy class type;
```

但是你怎么能意识到你正在使用代理类？应用他们的软件不可能宣告它们的存在。它们被设计为**不可见**，至少概念上说是这样！每当你发现它们，你真的应该舍弃[Item5](https://cntransgroup.github.io/EffectiveModernCppChinese/2.Auto/item5.html)演示的`auto`所具有的诸多好处吗？

当缺少文档的时候，可以去看看头文件。很少会出现源代码全都用代理对象，它们通常用于一些函数的返回类型，所以通常能从函数签名中看出它们的存在。这里有一份`std::vector<bool>::operator[]`的说明书：

```c++
namespace std{                                  //来自于C++标准库
    template<class Allocator>
    class vector<bool, Allocator>{
    public:
        …
        class reference { … };

        reference operator[](size_type n);
        …
    };
}
```

假设你知道对`std::vector<T>`使用`operator[]`通常会返回一个`T&`，在这里`operator[]`不寻常的返回类型提示你它使用了代理类。多关注你使用的接口可以暴露代理类的存在。

实际上， 很多开发者都是在跟踪一些令人困惑的复杂问题或在单元测试出错进行调试时才看到代理类的使用。不管你怎么发现它们的，一旦看到`auto`推导了代理类的类型而不是被代理的类型，解决方案并不需要抛弃`auto`。**`auto`本身没什么问题，问题是`auto`不会推导出你想要的类型**。解决方案是强制使用一个不同的类型推导形式，这种方法我通常称之为**显式类型初始器惯用法（*the explicitly typed initialized idiom*)**。

显式类型初始器惯用法使用`auto`声明一个变量，**然后对表达式强制类型转换（*cast*）得出你期望的推导结果**。举个例子，我们该怎么将这个惯用法施加到`highPriority`上？

```c++
auto highPriority = static_cast<bool>(features(w)[5]);
```

对于`Matrix`来说，显式类型初始器惯用法是这样的：

```c++
auto sum = static_cast<Matrix>(m1 + m2 + m3 + m4);
```

应用这个惯用法不限制初始化表达式产生一个代理类。它也可以用于强调你声明了一个变量类型，它的类型不同于初始化表达式的类型。举个例子，假设你有这样一个表达式计算公差值：

```c++
double calcEpsilon();                           //返回公差值
```

`calcEpsilon`清楚的表明它返回一个`double`，但是假设你知道对于这个程序来说使用`float`的精度已经足够了，而且你很关心`double`和`float`的大小。你可以声明一个`float`变量储存`calEpsilon`的计算结果。

```c++
float ep = calcEpsilon();                       //double到float隐式转换
```

但是这几乎没有表明“我确实要减少函数返回值的精度”。使用显式类型初始器惯用法我们可以这样：

```c++
auto ep = static_cast<float>(calcEpsilon());
```



> **请记住：**

- ***不可见的代理类可能会使`auto`从表达式中推导出“错误的”类型***
- ***显式类型初始器惯用法强制`auto`推导出你想要的结果***



##	3.移步现代C++

> Moving to Modern C++





####	itme 7:区别使用()和{}创建对象



```c++
int z = { 0 };	// 等同于 int z { 0 };

Widget w1;		// 默认构造函数
Widget w2 = w1; // 拷贝构造函数
w1 = w2;		// 拷贝赋值运算符
```



C++11使用统一初始化（uniform initalization）来整合这些混乱的初始化语法。它基于花括号。

```c++
vector<int> v{ 1, 3, 5 };
```

统一初始化也能被用于非静态数据成员指定默认初始值（类内初始值）：

```c++
class Widget{
    ...
private:
    int x {0};		// 正确
    int y = 0;		// 正确
    int z(0);		// 错误
}
```

另一个方面，不可拷贝的对象也可以使用花括号初始化或者圆括号初始化：

```c++
unique_ptr<int> ptr1 { new int(666) };
unique_ptr<int> ptr2(new int(666));
unique_ptr<int> ptr3 = new int(666);	// 错误
```

因此我们很容易理解为什么括号初始化又叫统一初始化，在C++中这三种方式都被看做是初始化表达式，但是只有花括号任何地方都能被使用。

括号表达式还有一个少见的特性，即它不允许内置类型间隐式的**变窄转换（*narrowing conversion*）**。如果一个使用了括号初始化的表达式的值，不能保证由被初始化的对象的类型来表示，代码就不会通过编译：

```c++
double x, y, z;

int sum1{ x + y + z };          //错误！double的和可能不能表示为int
```

使用圆括号和"="的初始化不检查是否转换为变窄转换，因为由于历史遗留问题它们必须要兼容老旧代码：

```c++
int sum2(x + y +z);             //可以（表达式的值被截为int）

int sum3 = x + y + z;           //同上
```

另一个值得注意的特性是括号表达式对于C++最令人头疼的解析问题有天生的免疫性:

```c++
Widget w1(10);                  //使用实参10调用Widget的一个构造函数
Widget w2();                    //最令人头疼的解析！声明一个函数w2，返回Widget
```

由于函数声明中形参列表不能带花括号，所以使用花括号初始化表明你想调用默认构造函数构造对象就没有问题：

```c++
Widget w3{};                    //调用没有参数的构造函数构造对象
```

关于括号初始化还有很多要说的。它的语法能用于各种不同的上下文，它防止了**隐式的变窄转换**，而且对于C++**最令人头疼的解析也天生免疫**。既然好到这个程度那为什么这个条款不叫“优先考虑括号初始化语法”呢？

在构造函数调用中，只要不包含`std::initializer_list`形参，那么花括号初始化和圆括号初始化都会产生一样的结果：

```c++
class Widget { 
public:  
    Widget(int i, bool b);      //构造函数未声明
    Widget(int i, double d);    //std::initializer_list这个形参 
    …
};
Widget w1(10, true);            //调用第一个构造函数
Widget w2{10, true};            //也调用第一个构造函数
Widget w3(10, 5.0);             //调用第二个构造函数
Widget w4{10, 5.0};             //也调用第二个构造函数
```

如果编译器遇到一个花括号初始化并且有一个带有std::initializer_list的构造函数，那么它一定会选择该构造函数。就像这样：

```c++
class Widget { 
public:  
    Widget(int i, bool b);      //同上
    Widget(int i, double d);    //同上
    Widget(std::initializer_list<long double> il);      //新添加的
    …
}; 

```

`w2`和`w4`将会使用新添加的构造函数，即使另一个非`std::initializer_list`构造函数和实参更匹配：

```c++
Widget w1(10, true);    //使用圆括号初始化，同之前一样
                        //调用第一个构造函数

Widget w2{10, true};    //使用花括号初始化，但是现在
                        //调用带std::initializer_list的构造函数
                        //(10 和 true 转化为long double)

Widget w3(10, 5.0);     //使用圆括号初始化，同之前一样
                        //调用第二个构造函数 

Widget w4{10, 5.0};     //使用花括号初始化，但是现在
                        //调用带std::initializer_list的构造函数
                        //(10 和 5.0 转化为long double)
```

甚至普通构造函数和移动构造函数都会被带`std::initializer_list`的构造函数劫持：

```c++
class Widget { 
public:  
    Widget(int i, bool b);                              //同之前一样
    Widget(int i, double d);                            //同之前一样
    Widget(std::initializer_list<long double> il);      //同之前一样
    operator float() const;                             //转换为float
    …
};

Widget w5(w4);                  //使用圆括号，调用拷贝构造函数

Widget w6{w4};                  //使用花括号，调用std::initializer_list构造
                                //函数（w4转换为float，float转换为double）

Widget w7(std::move(w4));       //使用圆括号，调用移动构造函数

Widget w8{std::move(w4)};       //使用花括号，调用std::initializer_list构造
                                //函数（与w6相同原因）
```

**编译器一遇到括号初始化就选择带`std::initializer_list`的构造函数的决心是如此强烈**，以至于就算带`std::initializer_list`的构造函数不能被调用，它也会硬选:

```c++
class Widget { 
public: 
    Widget(int i, bool b);                      //同之前一样
    Widget(int i, double d);                    //同之前一样
    Widget(std::initializer_list<bool> il);     //现在元素类型为bool
    …                                           //没有隐式转换函数
};

Widget w{10, 5.0};              //错误！要求变窄转换
```

这里，编译器会直接忽略前面两个构造函数（其中第二个构造函数是所有实参类型的最佳匹配），然后尝试调用`std::initializer_list<bool>`构造函数。调用这个函数将会把`int(10)`和`double(5.0)`转换为`bool`，由于会产生变窄转换（`bool`不能准确表示其中任何一个值），括号初始化拒绝变窄转换，所以这个调用无效，代码无法通过编译。

**只有当没办法把括号初始化中实参的类型转化为`std::initializer_list`时，编译器才会回到正常的函数决议流程中**。比如我们在构造函数中用`std::initializer_list<std::string>`代替`std::initializer_list<bool>`，这时非`std::initializer_list`构造函数将再次成为函数决议的候选者，因为没有办法把`int`和`bool`转换为`std::string`:

```c++
class Widget { 
public:  
    Widget(int i, bool b);                              //同之前一样
    Widget(int i, double d);                            //同之前一样
    //现在std::initializer_list元素类型为std::string
    Widget(std::initializer_list<std::string> il);
    …                                                   //没有隐式转换函数
};

Widget w1(10, true);     // 使用圆括号初始化，调用第一个构造函数
Widget w2{10, true};     // 使用花括号初始化，现在调用第一个构造函数		(无法转换为string)
Widget w3(10, 5.0);      // 使用圆括号初始化，调用第二个构造函数
Widget w4{10, 5.0};      // 使用花括号初始化，现在调用第二个构造函数
```

假如你使用的花括号初始化是空集，并且你欲构建的对象有默认构造函数，也有`std::initializer_list`构造函数。你的空的花括号意味着什么？

**如果没有实参，就该使用默认构造函数，但如有一个空的`std::initializer_list`，就该调用`std::initializer_list`构造函数：**

```c++
class Widget { 
public:  
    Widget();                                   //默认构造函数
    Widget(std::initializer_list<int> il);      //std::initializer_list构造函数

    …                                           //没有隐式转换函数
};

Widget w1;                      //调用默认构造函数
Widget w2{};                    //也调用默认构造函数
Widget w3();                    //最令人头疼的解析！声明一个函数

Widget w4({});                  //使用空花括号列表调用std::initializer_list构造函数
Widget w5{{}};                  //同上
```

`std::initializer_list`重载不会和其他重载函数比较，它直接盖过了其它重载函数，其它重载函数几乎不会被考虑。所以如果你要加入`std::initializer_list`构造函数，请三思而后行。



作为一个类库使用者，你必须认真的在花括号和圆括号之间选择一个来创建对象。

大多数开发者都使用其中一种作为默认情况，只有当他们不能使用这种的时候才会考虑另一种。**默认使用花括号初始化的开发者主要被适用面广、禁止变窄转换、免疫C++最令人头疼的解析这些优点所吸引**。这些开发者知道在一些情况下（比如给定一个容器大小和一个初始值创建`std::vector`）要使用圆括号。

**默认使用圆括号初始化的开发者主要被C++98语法一致性、避免`std::initializer_list`自动类型推导、避免不会不经意间调用`std::initializer_list`构造函数这些优点所吸引**。这些开发者也承认有时候只能使用花括号（比如创建一个包含着特定值的容器）。

关于花括号初始化和圆括号初始化哪种更好大家没有达成一致，所以我的建议是选择一种并坚持使用它。

如果你是一个模板的作者，花括号和圆括号创建对象就更麻烦了。通常不能知晓哪个会被使用。举个例子，假如你想创建一个接受任意数量的参数来创建的对象。使用可变参数模板（*variadic template*）可以非常简单的解决：

```c++
template<typename T,            //要创建的对象类型
         typename... Ts>        //要使用的实参的类型
void doSomeWork(Ts&&... params)
{
    create local T object from params...
    …
} 
T localObject(std::forward<Ts>(params)...);             //使用圆括号
T localObject{std::forward<Ts>(params)...};             //使用花括号
```

考虑这样的调用代码：

```c++
std::vector<int> v; 
…
doSomeWork<std::vector<int>>(10, 20);
```

如果`doSomeWork`创建`localObject`时使用的是圆括号，`std::vector`就会包含10个元素。如果`doSomeWork`创建`localObject`时使用的是花括号，`std::vector`就会包含2个元素。哪个是正确的？`doSomeWork`的作者不知道，只有调用者知道。

这正是标准库函数`std::make_unique`和`std::make_shared`（参见[Item21](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item21.html)）面对的问题。它们的解决方案是使用圆括号，并被记录在文档中作为接口的一部分。

> **请记住：**

- ***括号初始化是最广泛使用的初始化语法，它防止变窄转换，并且对于C++最令人头疼的解析有天生的免疫性***
- ***在构造函数重载决议中，编译器会尽最大努力将括号初始化与`std::initializer_list`参数匹配，即便其他构造函数看起来好像是更好的选择***
- ***对于数值类型的`std::vector`来说使用花括号初始化和圆括号初始化会造成巨大的不同***
- ***在模板类选择使用圆括号初始化或使用花括号初始化创建对象是一个挑战***



####	item 8:优先考虑nullptr而非0和NULL



在C++98中，对指针类型和整型进行重载意味着可能导致奇怪的事情。如果给下面的重载函数传递`0`或`NULL`，它们绝不会调用指针版本的重载函数：

```c++
void f(int);        //三个f的重载函数
void f(bool);
void f(void*);

f(0);               //调用f(int)而不是f(void*)

f(NULL);            //可能不会被编译，一般来说调用f(int)，
                    //绝对不会调用f(void*)
```



`nullptr`的优点是它不是整型。老实说它也不是一个指针类型，但是你可以把它认为是**所有**类型的指针。**`nullptr`的真正类型是`std::nullptr_t`**，在一个完美的循环定义以后，`std::nullptr_t`又被定义为`nullptr`。**`std::nullptr_t`可以隐式转换为指向任何内置类型的指针**，这也是为什么`nullptr`表现得像所有类型的指针。



**使用`nullptr`代替`0`和`NULL`可以避开了那些令人奇怪的函数重载决议**，这不是它的唯一优势。它也可以使代码表意明确，尤其是当涉及到与`auto`声明的变量一起使用时。举个例子，假如你在一个代码库中遇到了这样的代码：

```c++
auto result = findRecord( /* arguments */ );
if (result == 0) {
    …
} 
// 如果你不知道findRecord返回了什么（或者不能轻易的找出），那么你就不太清楚到底result是一个指针类型还是一个整型。
auto result = findRecord( /* arguments */ );

if (result == nullptr) {  
    …
}
//这就没有任何歧义：result的结果一定是指针类型。

```

当模板出现时，nullptr就更有用了：

```c++
template<typename FuncType,
         typename MuxType,
         typename PtrType>
decltype(auto) lockAndCall(FuncType func,       //C++14
                           MuxType& mutex,
                           PtrType ptr)
{ 
    MuxGuard g(mutex);  
    return func(ptr); 
}
```

可以写这样的代码调用`lockAndCall`模板（两个版本都可）：

```c++
auto result1 = lockAndCall(f1, f1m, 0);         // PtrType被推导为int
...
auto result2 = lockAndCall(f2, f2m, NULL);      // PtrType被推导为整型（看不同实现）
...
auto result3 = lockAndCall(f3, f3m, nullptr);   // PtrType被推导为std::nullptr_t

```

模板类型推导将`0`和`NULL`推导为一个错误的类型（即它们的实际类型，而不是作为空指针的隐含意义），这就导致在当你想要一个空指针时，它们的替代品`nullptr`很吸引人。**使用`nullptr`，模板不会有什么特殊的转换**。另外，使用`nullptr`不会让你受到同重载决议特殊对待`0`和`NULL`一样的待遇。当你想用一个空指针，使用`nullptr`，不用`0`或者`NULL`。



> **请记住**

- ***优先使用nullptr，而不是0和NULL***
- ***避免在整数和指针类型上重载***



####	Item 9:优先考虑别名声明而非typedef

假如你正在使用std::unique_ptr，但我猜没有人喜欢写上几次 `std::unique_ptr<std::unordered_map<std::string, std::string>>`这样的类型，它可能会让你患上腕管综合征的风险大大增加。

避免上述医疗悲剧也很简单，引入`typedef`即可：

```c++
typedef
    std::unique_ptr<std::unordered_map<std::string, std::string>>
    UPtrMapSS; 
```

但`typedef`是C++98的东西。虽然它可以在C++11中工作，但是C++11也提供了一个**别名声明（*alias declaration*）**：

```c++
using UPtrMapSS =
    std::unique_ptr<std::unordered_map<std::string, std::string>>;
```

由于这里给出的`typedef`和别名声明做的都是完全一样的事情，我们有理由想知道会不会出于一些技术上的原因两者有一个更好。

这里，在说它们之前我想提醒一下很多人都发现当声明一个函数指针时别名声明更容易理解：

```c++
//FP是一个指向函数的指针的同义词，它指向的函数带有
//int和const std::string&形参，不返回任何东西
typedef void (*FP)(int, const std::string&);    //typedef

//含义同上
using FP = void (*)(int, const std::string&);   //别名声明	更容易理解
```



不过有一个地方使用别名声明吸引人的理由是存在的：模板。**特别地，别名声明可以被模板化（这种情况下称为别名模板*alias template*s）但是`typedef`不能**。这使得C++11程序员可以很直接的表达一些C++98中只能把`typedef`嵌套进模板化的`struct`才能表达的东西。考虑一个链表的别名，链表使用自定义的内存分配器，`MyAlloc`。使用别名模板，这真是太容易了：

```c++
template<typename T>                            //MyAllocList<T>是
using MyAllocList = std::list<T, MyAlloc<T>>;   //std::list<T, MyAlloc<T>>
                                                //的同义词

MyAllocList<Widget> lw;                         //用户代码
```

使用`typedef`，你就只能从头开始：

```c++
template<typename T>                            //MyAllocList<T>是
struct MyAllocList {                            //std::list<T, MyAlloc<T>>
    typedef std::list<T, MyAlloc<T>> type;      //的同义词  
};

MyAllocList<Widget>::type lw;                   //用户代码
```

更糟糕的是，如果你想使用在一个模板内使用`typedef`声明一个链表对象，而这个对象又使用了模板形参，你就不得不在`typedef`前面加上`typename`：

```c++
template<typename T>
class Widget {                              //Widget<T>含有一个
private:                                    //MyAllocLIst<T>对象
    typename MyAllocList<T>::type list;     //作为数据成员
    …
}; 
```

这里`MyAllocList<T>::type`使用了一个类型，**这个类型依赖于模板参数`T`**。因此`MyAllocList<T>::type`是一个**依赖类型（*dependent type*）**，在C++=规则中的一个提到必须要在依赖类型名前加上`typename`。

如果使用别名声明定义一个`MyAllocList`，就不需要使用`typename`（同时省略麻烦的“`::type`”后缀）：

```c++
template<typename T> 
using MyAllocList = std::list<T, MyAlloc<T>>;   //同之前一样

template<typename T> 
class Widget {
private:
    MyAllocList<T> list;                        //没有“typename”
    …                                           //没有“::type”
};
```

对你来说，`MyAllocList<T>`（使用了模板别名声明的版本）可能看起来和`MyAllocList<T>::type`（使用`typedef`的版本）一样都应该依赖模板参数`T`。

当编译器处理`Widget`模板时遇到`MyAllocList<T>`（使用模板别名声明的版本），它们知道`MyAllocList<T>`是一个类型名，因为`MyAllocList`是一个**别名模板**：它**一定**是一个类型名。因此`MyAllocList<T>`就是一个**非依赖类型**（*non-dependent type*），就不需要也不允许使用`typename`修饰符。

当编译器在`Widget`的模板中看到`MyAllocList<T>::type`（使用`typedef`的版本），**它不能确定那是一个类型的名称。因为可能存在一个`MyAllocList`的它们没见到的特化版本**，那个版本的`MyAllocList<T>::type`指代了一种不是类型的东西。那听起来很不可思议，但不要责备编译器穷尽考虑所有可能。因为人确实能写出这样的代码。



如果你尝试过**模板元编程（*template metaprogramming*，TMP**）， 你一定会碰到取模板类型参数然后基于它创建另一种类型的情况。举个例子，给一个类型`T`，如果你想去掉`T`的常量修饰和引用修饰（`const`- or reference qualifiers），比如你想把`const std::string&`变成`std::string`。又或者你想给一个类型加上`const`或变为左值引用，比如把`Widget`变成`const Widget`或`Widget&`。（如果你没有用过模板元编程，太遗憾了，因为如果你真的想成为一个高效C++程序员，你需要至少熟悉C++在这方面的基本知识。你可以看看在[Item23](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item23.html)，[27](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item27.html)里的TMP的应用实例，包括我提到的类型转换）。

C++11在***type traits*（类型特性）**中给了你一系列工具去实现类型转换，如果要使用这些模板请包含头文件`<type_traits>`。里面有许许多多*type traits*，也不全是类型转换的工具，也包含一些可预测接口的工具。给一个你想施加转换的类型`T`，结果类型就是`std::`transformation`<T>::type`，比如：

```c++
std::remove_const<T>::type          //从const T中产出T
std::remove_reference<T>::type      //从T&和T&&中产出T
std::add_lvalue_reference<T>::type  //从T中产出T&
```

注意类型转换尾部的`::type`。如果你在一个模板内部将他们施加到类型形参上（实际代码中你也总是这么用），你也需要在它们前面加上`typename`。至于为什么要这么做是因为这些C++11的*type traits*是通过在`struct`内嵌套`typedef`来实现的。是的，它们使用类型同义词（译注：根据上下文指的是使用`typedef`的做法）技术实现，而正如我之前所说这比别名声明要差。

关于为什么这么实现是有历史原因的，**因为标准委员会没有及时认识到别名声明是更好的选择，**所以直到**C++14**它们才提供了使用别名声明的版本。这些别名声明有一个通用形式：对于C++11的类型转换`std::`transformation`<T>::type`在C++14中变成了`std::`transformation`_t`。举个例子或许更容易理解：

```c++
std::remove_const<T>::type          //C++11: const T → T 
std::remove_const_t<T>              //C++14 等价形式

std::remove_reference<T>::type      //C++11: T&/T&& → T 
std::remove_reference_t<T>          //C++14 等价形式

std::add_lvalue_reference<T>::type  //C++11: T → T& 
std::add_lvalue_reference_t<T>      //C++14 等价形式
```

C++11的的形式在C++14中也有效，但是我不能理解为什么你要去用它们。就算你没办法使用C++14，使用别名模板也是小儿科。只需要C++11的语言特性，甚至每个小孩都能仿写，对吧？如果你有一份C++14标准，就更简单了，只需要复制粘贴：

```c++
template <class T> 
using remove_const_t = typename remove_const<T>::type;

template <class T> 
using remove_reference_t = typename remove_reference<T>::type;

template <class T> 
using add_lvalue_reference_t =
  typename add_lvalue_reference<T>::type; 
```

> **请记住**

- ***`typedef`不支持模板化，但是别名声明支持***
- ***别名模板避免了使用`::type`后缀，而且在模板中使用`typedef`还需要在前面加上`typename`***
- ***C++14提供了C++11所有type traits转换的别名声明版本***



####	Item 10:优先考虑限域枚举而非未限域枚举





> **请记住**

- ***C++98的`enum`即非限域`enum`***
- ***限域`enum`的枚举名仅在`enum`内可见。要转换为其它类型只能使用cast***
- ***非限域/限域`enum`都支持底层类型说明语法，限域`enum`底层类型默认是`int`。非限域`enum`没有默认底层类型。***
- ***限域`enum`总是可以前置声明。非限域`enum`仅当指定它们的底层类型时才能前置。***



####	Item 11:优先考虑使用delete函数而非使用未定义的私有声明

如果你写的代码要被其他人使用，你不想让他们调用某个特殊的函数，你通常不会声明这个函数。无声明，不函数。简简单单！但有时C++会给你自动声明一些函数（拷贝控制函数，移动函数），如果你想防止客户调用这些函数，事情就不那么简单了。

我们只关注拷贝构造函数和拷贝赋值运算符。在C++98中，你想要禁止使用成员函数，几乎总是拷贝构造函数或者赋值运算符，或者两者都是。

在C++98中防止调用这些函数的方法是将它们**声明为私有（`private`）成员函数并且不定义**。举个例子，在C++ 标准库*iostream*继承链的顶部是模板类`basic_ios`。所有*istream*和*ostream*类都继承此类（直接或者间接）。拷贝*istream*和*ostream*是不合适的，因为这些操作应该怎么做是模棱两可的。比如一个`istream`对象，代表一个输入值的流，流中有一些已经被读取，有一些可能马上要被读取。如果一个*istream*被拷贝，需要拷贝将要被读取的值和已经被读取的值吗？解决这个问题最好的方法是不定义这个操作。直接禁止拷贝流。

要使这些*istream*和*ostream*类不可拷贝，`basic_ios`在C++98中是这样声明的（包括注释）：

```c++
template <class charT, class traits = char_traits<charT> >
class basic_ios : public ios_base {
public:
    …

private:
    basic_ios(const basic_ios& );           // not defined
    basic_ios& operator=(const basic_ios&); // not defined
};
```

将它们声明为私有成员可以防止客户调用这些函数，故意不定义它们意味着假如还是有代码使用它们（比如类的成员函数或者是友元），就会在链接时引发缺少函数定义（*missing function definitions*）错误。

在C++11中有一种更好的方式达到相同目的：用“`= delete`”将拷贝构造函数和拷贝赋值运算符标记为**delete函数**。上面相同的代码在C++11中是这样声明的：

```c++
template <class charT, class traits = char_traits<charT> >
class basic_ios : public ios_base {
public:
    …

    basic_ios(const basic_ios& ) = delete;
    basic_ios& operator=(const basic_ios&) = delete;
    …
};
```

删除这些函数（译注：添加"`= delete`"）和声明为私有成员可能看起来只是方式不同，别无其他区别。其实还有一些实质性意义。***deleted*函数不能以任何方式被调用，即使你在成员函数或者友元函数里面调用*deleted*函数也不能通过编译**。这是较之C++98行为的一个改进，C++98中不正确的使用这些函数在链接时才被诊断出来。

通常，*deleted*函数被声明为`public`而不是`private`。这也是有原因的。当客户端代码试图调用成员函数，C++会在检查*deleted*状态前检查它的访问性。当客户端代码调用一个私有的*deleted*函数，一些编译器只会给出该函数是`private`的错误（译注：而没有诸如该函数被*deleted*修饰的错误），即使函数的访问性不影响它是否能被使用。所以值得牢记，如果要将老代码的“私有且未定义”函数替换为*deleted*函数时请一并修改它的访问性为`public`，这样可以让编译器产生更好的错误信息。



*deleted*函数还有一个重要的优势是**任何函数都可以标记为*deleted***（=default只能使用在有合成版本的函数上），而只有成员函数可被标记为`private`。假如我们有一个非成员函数，它接受一个整型参数，检查它是否为幸运数：

```c++
bool isLucky(int number);
// C++有沉重的C包袱，使得含糊的、能被视作数值的任何类型都能隐式转换为int，但是有一些调用可能是没有意义的：

if (isLucky('a')) …         //字符'a'是幸运数？
if (isLucky(true)) …        //"true"是?
if (isLucky(3.5)) …         //难道判断它的幸运之前还要先截尾成3？
```

如果幸运数必须真的是整型，我们该禁止这些调用通过编译。

其中一种方法就是创建*deleted*重载函数，其参数就是我们想要过滤的类型：

```c++
bool isLucky(int number);       //原始版本
bool isLucky(char) = delete;    //拒绝char
bool isLucky(bool) = delete;    //拒绝bool
bool isLucky(double) = delete;  //拒绝float和double
```

虽然*deleted*函数不能被使用，但它们还是存在于你的程序中。也即是说，**重载决议会考虑它们**。这也是为什么上面的函数声明导致编译器拒绝一些不合适的函数调用。

```c++
if (isLucky('a')) …     //错误！调用deleted函数
if (isLucky(true)) …    //错误！
if (isLucky(3.5f)) …    //错误！
```

另一个*deleted*函数用武之地（`private`成员函数做不到的地方）是**禁止一些模板的实例化**：

```c++
template<typename T>
void processPointer(T* ptr);
```

在指针的世界里有两种特殊情况。一是`void*`指针，因为没办法对它们进行解引用，或者加加减减等。另一种指针是`char*`，因为它们通常代表C风格的字符串，而不是正常意义下指向单个字符的指针。这两种情况要特殊处理，在`processPointer`模板里面，我们假设正确的函数应该拒绝这些类型。也即是说，`processPointer`不能被`void*`和`char*`调用。

要想确保这个很容易，使用`delete`标注模板实例：

```c++
template<>
void processPointer<void>(void*) = delete;

template<>
void processPointer<char>(char*) = delete;
```

现在如果使用`void*`和`char*`调用`processPointer`就是无效的，按常理说`const void*`和`const char*`也应该无效，所以这些实例也应该标注`delete`:

```c++
template<>
void processPointer<const void>(const void*) = delete;

template<>
void processPointer<const char>(const char*) = delete;
```



有趣的是，如果类里面有一个函数模板，你可能想用`private`（经典的C++98惯例）来禁止这些函数模板实例化，但是不能这样做，**因为不能给特化的成员模板函数指定一个不同于主函数模板的访问级别**。如果`processPointer`是类`Widget`里面的模板函数， 你想禁止它接受`void*`参数，那么通过下面这样C++98的方法就不能通过编译：

```c++
class Widget {
public:
    …
    template<typename T>
    void processPointer(T* ptr)
    { … }

private:
    template<>                          //错误！
    void processPointer<void>(void*);
    
};
```

问题是模板特例化必须位于一个命名空间作用域，而不是类作用域。*deleted*函数不会出现这个问题，因为它不需要一个不同的访问级别，且他们可以在类外被删除（因此位于命名空间作用域）：

```c++
class Widget {
public:
    …
    template<typename T>
    void processPointer(T* ptr)
    { … }
    …

};

template<>                                          //还是public，
void Widget::processPointer<void>(void*) = delete;  //但是已经被删除了
```

事实上C++98的最佳实践即声明函数为`private`但不定义是在做C++11 *deleted*函数要做的事情。作为模仿者，C++98的方法不是十全十美。**它不能在类外正常工作，不能总是在类中正常工作，它的罢工可能直到链接时才会表现出来。所以请坚定不移的使用*deleted*函数。**

> **请记住：**

- ***比起声明函数为`private`但不定义，使用`delete`函数更好***
- ***任何函数都能被删除（be deleted），包括非成员函数和模板实例***





####	Item 12:使用override声明重写函数

在C++面向对象的世界里，涉及的概念有类，继承，虚函数。这个世界最基本的概念是派生类的虚函数**重写**基类同名函数。令人遗憾的是虚函数重写可能一不小心就错了。似乎这部分语言的设计理念是不仅仅要遵守墨菲定律，还应该尊重它。

虽然“重写（*overriding*）”听起来像“重载（*overloading*）”，然而两者完全不相关，所以让我澄清一下，正是虚函数重写机制的存在，才使我们可以**通过基类的接口调用派生类的成员函数**：

```c++
class Base {
public:
    virtual void doWork();          //基类虚函数
    …
};

class Derived: public Base {
public:
    virtual void doWork();          //重写Base::doWork
    …                               //（这里“virtual”是可以省略的）
}; 

std::unique_ptr<Base> upb =         //创建基类指针指向派生类对象
    std::make_unique<Derived>();    //关于std::make_unique
…                                   //请参见Item21

    
upb->doWork();                      //通过基类指针调用doWork，
                                    //实际上是派生类的doWork
                                    //函数被调用
```

要想重写一个函数，必须满足下列要求：

- **基类函数必须是`virtual`**
- **基类和派生类函数名必须完全一样（除非是析构函数)**
- **基类和派生类函数形参类型必须完全一样**
- **基类和派生类函数常量性·constness·必须完全一样**
- **基类和派生类函数的返回值和异常说明（*exception specifications*）必须兼容**

除了这些C++98就存在的约束外，C++11又添加了一个：

- **函数的引用限定符（*reference qualifiers*）必须完全一样。成员函数的引用限定符是C++11很少抛头露脸的特性，所以如果你从没听过它无需惊讶。它可以限定成员函数只能用于左值或者右值。成员函数不需要`virtual`也能使用它们：**

```c++
class Widget {
public:
    …
    void doWork() &;    //只有*this为左值的时候才能被调用
    void doWork() &&;   //只有*this为右值的时候才能被调用
}; 
…
Widget makeWidget();    //工厂函数（返回右值）
Widget w;               //普通对象（左值）
…
w.doWork();             //调用被左值引用限定修饰的Widget::doWork版本
                        //（即Widget::doWork &）
makeWidget().doWork();  //调用被右值引用限定修饰的Widget::doWork版本
                        //（即Widget::doWork &&）
```

这么多的重写需求意味着哪怕一个小小的错误也会造成巨大的不同。代码中包含重写错误通常是有效的，但它的意图不是你想要的。因此你不能指望当你犯错时编译器能通知你。比如，下面的代码是完全合法的，咋一看，还很有道理，但是它没有任何虚函数重写——没有一个派生类函数联系到基类函数。你能识别每种情况的错误吗，换句话说，为什么派生类函数没有重写同名基类函数？

```c++
class Base {
public:
    virtual void mf1() const;
    virtual void mf2(int x);
    virtual void mf3() &;
    void mf4() const;
};

class Derived: public Base {
public:
    virtual void mf1();
    virtual void mf2(unsigned int x);
    virtual void mf3() &&;
    void mf4() const;
};
```

需要一点帮助吗？

- `mf1`在`Base`基类声明为`const`，但是`Derived`派生类没有这个常量限定符
- `mf2`在`Base`基类声明为接受一个`int`参数，但是在`Derived`派生类声明为接受`unsigned int`参数
- `mf3`在`Base`基类声明为左值引用限定，但是在`Derived`派生类声明为右值引用限定
- `mf4`在`Base`基类没有声明为`virtual`虚函数

你可能会想，“哎呀，实际操作的时候，这些warnings都能被编译器探测到，所以我不需要担心。”你说的可能对，也可能不对。就我目前检查的两款编译器来说，这些代码编译时**没有任何warnings**，即使我开启了输出所有warnings。（其他编译器可能会为这些问题的部分输出warnings，但不是全部。）

由于正确声明派生类的重写函数很重要，但很容易出错，C++11提供一个方法让你可以显式地指定一个派生类函数是基类版本的重写：将它声明为`override`。还是上面那个例子，我们可以这样做：

```c++
class Derived: public Base {
public:
    virtual void mf1() override;
    virtual void mf2(unsigned int x) override;
    virtual void mf3() && override;
    virtual void mf4() const override;
};
//代码不能编译，当然了，因为这样写的时候，编译器会抱怨所有与重写有关的问题。这也是你想要的，以及为什么要在所有重写函数后面加上override。
```

比起让编译器通过warnings告诉你想重写的而实际没有重写，不如给你的派生类重写函数全都加上`override`。如果你考虑修改修改基类虚函数的函数签名，`override`还可以帮你评估后果。如果派生类全都用上`override`，你可以只改变基类函数签名，重编译系统，再看看你造成了多大的问题（即，多少派生类不能通过编译），然后决定是否值得如此麻烦更改函数签名。没有`override`，你只能寄希望于完善的单元测试，因为，正如我们所见，派生类虚函数本想重写基类，但是没有，编译器也没有探测并发出诊断信息。

C++既有很多关键字，C++11引入了两个**上下文关键字（*contextual keywords*）**，`override`和`final`（向虚函数添加`final`可以防止派生类重写。`final`也能用于类，这时这个类不能用作基类）。**这两个关键字的特点是它们是保留的，它们只是位于特定上下文才被视为关键字**。对于`override`，**它只在成员函数声明结尾处才被视为关键字**。这意味着如果你以前写的代码里面已经用过**override**这个名字，那么换到C++11标准你也无需修改代码：

```c++
class Warning {         //C++98潜在的传统类代码
public:
    …
    void override();    //C++98和C++11都合法（且含义相同）
    …
};
```

在来看看**成员函数引用限定（*reference qualifiers*）**



如果我们想写一个函数**只接受左值实参**，我们声明一个`non-const`左值引用形参：

```c++
void doSomething(Widget& w);    //只接受左值Widget对象,所以形参没有const
```

如果我们想写一个函数**只接受右值实参**，我们声明一个右值引用形参：

```c++
void doSomething(Widget&& w);   //只接受右值Widget对象
```

对成员函数添加引用限定不常见，但是可以见。举个例子，假设我们的`Widget`类有一个`std::vector`数据成员，我们提供一个访问函数让客户端可以直接访问它：

```c++
class Widget {
public:
    using DataType = std::vector<double>;   //“using”的信息参见Item9
    …
    DataType& data() { return values; }
    …
private:
    DataType values;
};
```

这是最具封装性的设计，只给外界保留一线光。但先把这个放一边，思考一下下面的客户端代码：

```c++
Widget w;
…
auto vals1 = w.data();  //拷贝w.values到vals1
```

`Widget::data`函数的返回值是一个左值引用（准确的说是`std::vector<double>&`）, 因为左值引用是左值，所以`vals1`是从左值初始化的。因此`vals1`由`w.values`拷贝构造而得，就像注释说的那样。

现在假设我们有一个创建`Widget`s的工厂函数:

```c++
Widget makeWidget();
```

我们想用`makeWidget`返回的`Widget`里的`std::vector`初始化一个变量：

```c++
auto vals2 = makeWidget().data();   //拷贝Widget里面的值到vals2
```

再说一次，`Widgets::data`返回的是左值引用，还有，左值引用是左值。所以，**我们的对象（`vals2`）得从`Widget`里的`values`拷贝构造。这一次，`Widget`是`makeWidget`返回的临时对象（即右值）**，**所以拷贝它的std::vector数据成员纯属浪费。最好是移动**，但是因为`data`返回左值引用，C++的规则要求编译器不得不生成一个拷贝。（这其中有一些优化空间，被称作“as if rule”，但是你依赖编译器使用这个优化规则就有点傻。）（译注：“as if rule”简单来说就是在不影响程序的“外在表现”情况下做一些改变）

我们需要的是指明当`data`被右值`Widget`对象调用的时候结果也应该是一个右值。现在就可以使用引用限定，为左值`Widget`和右值`Widget`写一个`data`的重载函数来达成这一目的：

```c++
class Widget {
public:
    using DataType = std::vector<double>;
    …
    DataType& data() &              //对于左值Widgets,
    { return values; }              //返回左值
    
    DataType data() &&              //对于右值Widgets,
    { return std::move(values); }   //返回右值
    …

private:
    DataType values;
};

```

注意`data`重载的返回类型是不同的，左值引用重载版本返回一个左值引用（即一个左值），右值引用重载返回一个临时对象（即一个右值）。这意味着现在客户端的行为和我们的期望相符了：

```c++
auto vals1 = w.data();              //调用左值重载版本的Widget::data，
                                    //拷贝构造vals1
auto vals2 = makeWidget().data();   //调用右值重载版本的Widget::data, 
                                    //移动构造vals2
```

这真的很棒，但别被这结尾的暖光照耀分心以致忘记了该条款的中心。这个条款的中心是只要你在派生类声明想要重写基类虚函数的函数，就加上`override`。

> **请记住：**

- ***为重写函数加上`override`***
- ***成员函数引用限定让我们可以区别对待左值对象和右值对象（即*this）**



####	Item 13:优先考虑const_iterator而非iterator

STL `const_iterator`等价于指向常量的指针（pointer-to-const）。它们都指向不能被修改的值。条款的实践是能加上`const`就加上，这也指示我们需要一个迭代器时只要没必要修改迭代器指向的值，就应当使用`const_iterator`。



上面的说法对C++11和C++98都是正确的，**但是在C++98中，标准库对`const_iterator`的支持不是很完整**。首先不容易创建它们，其次就算你有了它，它的使用也是受限的。假如你想在`std::vector<int>`中查找第一次出现1983（C++代替C with classes的那一年）的位置，然后插入1998（第一个ISO C++标准被接纳的那一年）。如果*vector*中没有1983，那么就在*vector*尾部插入。在C++98中使用`iterator`可以很容易做到：

```c++
std::vector<int> values;
…
std::vector<int>::iterator it =
    std::find(values.begin(), values.end(), 1983);
values.insert(it, 1998);
```

但是这里`iterator`真的不是一个好的选择，因为这段代码不修改`iterator`指向的内容。应该使用`const_iterator`重写这段代码，但是在C++98中就不是了。下面是一种概念上可行但是不正确的方法：

```c++
typedef std::vector<int>::iterator IterT;               //typedef
typedef std::vector<int>::const_iterator ConstIterT;

std::vector<int> values;
…
ConstIterT ci =
    std::find(static_cast<ConstIterT>(values.begin()),  //cast
              static_cast<ConstIterT>(values.end()),    //cast
              1983);

values.insert(static_cast<IterT>(ci), 1998);    //可能无法通过编译，
                                                //原因见下
```

`typedef`不是强制的，但是可以让代码中的*cast*更好写。（你可能想知道为什么我使用`typedef`而不是[Item9](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item9.html)提到的别名声明，因为这段代码在演示C++98做法，别名声明是C++11加入的特性）

之所以`std::find`的调用会出现类型转换是因为在C++98中`values`是non-`const`容器，没办法简简单单的从non-`const`容器中获取`const_iterator`。严格来说类型转换不是必须的，因为用其他方法获取`const_iterator`也是可以的（比如你可以把`values`绑定到reference-to-`const`变量上，然后再用这个变量代替`values`），但不管怎么说，从non-`const`容器中获取`const_iterator`的做法都有点别扭。

当你费劲地获得了`const_iterator`，事情可能会变得更糟，因为C++98中，插入操作（以及删除操作）的位置只能由`iterator`指定，`const_iterator`是不被接受的。这也是我在上面的代码中，将`const_iterator`（我那么小心地从`std::find`搞出来的东西）转换为`iterator`的原因，因为向`insert`传入`const_iterator`不能通过编译。

老实说，我上面展示的代码可能就编译不通过，这是因为并没有从 const_iterator 到 interator 的便捷转换，即使用 static_cast 也不行，甚至最暴力的 reinterpret_cast 也不成。 （这不是 C++98 的限制，C++11 也同样如此。 const_iterator 不能简单地转换成 iterator ， 不管看似有多么合理。）还有一些方法可以生成类似 const_iterator 行为的 iterator ，但是 它们都不是很明显，也不通用，本书中就不讨论了。除此之外，我希望我所表达的观点已经 明确： const_iterator 在 C++98 中非常麻烦，不值得花心思。到最后，在任何可能的地方， 开发者们都不会使用 const_iterator ，**在 C++98 中 const_iterator 是非常不实用的**。

**所有的这些都在C++11中改变了，现在`const_iterator`既容易获取又容易使用**。容器的成员函数`cbegin`和`cend`产出`const_iterator`，甚至对于`non-const`容器也可用，那些之前使用*iterator*指示位置（如`insert`和`erase`）的STL成员函数也可以使用`const_iterator`了。使用C++11 `const_iterator`重写C++98使用`iterator`的代码也稀松平常：

```c++
std::vector<int> values;                                //和之前一样
…
auto it =                                               //使用cbegin
    std::find(values.cbegin(), values.cend(), 1983);//和cend
values.insert(it, 1998);
```

只有一种情况，C++11对于`const_iterator`支持不足（译注：C++14支持但是C++11的时候还没）的情况是：当你想写最大程度通用的库，并且这些库代码为一些容器和类似容器的数据结构提供`begin`、`end`（以及`cbegin`，`cend`，`rbegin`，`rend`等）作为**非成员函数**而不是成员函数时。其中一种情况就是原生数组，还有一种情况是一些只由自由函数组成接口的第三方库。（译注：自由函数*free function*，指的是非成员函数，即一个函数，只要不是成员函数就可被称作*free function*）最大程度通用的库会考虑使用非成员函数而不是假设成员函数版本存在。

举个例子，我们可以泛化下面的`findAndInsert`：

```c++
template<typename C, typename V>
void findAndInsert(C& container,            //在容器中查找第一次
                   const V& targetVal,      //出现targetVal的位置，
                   const V& insertVal)      //然后在那插入insertVal
{
    using std::cbegin;
    using std::cend;

    auto it = std::find(cbegin(container),  //非成员函数cbegin
                        cend(container),    //非成员函数cend
                        targetVal);
    container.insert(it, insertVal);
}
```

它可以在C++14工作良好，但是很遗憾，C++11不在良好之列。**由于标准化的疏漏，C++11只添加了非成员函数`begin`和`end`，但是没有添加`cbegin`，`cend`，`rbegin`，`rend`，`crbegin`，`crend`。C++14修订了这个疏漏。**

如果你使用C++11，并且想写一个最大程度通用的代码，而你使用的STL没有提供缺失的非成员函数`cbegin`和它的朋友们，你可以简单的写下你自己的实现。比如，**下面就是非成员函数`cbegin`的实现**：

```c++
template <class C>
auto cbegin(const C& container)->decltype(std::begin(container))			// C++11
{
    return std::begin(container);   //解释见下
}		
```

你可能很惊讶非成员函数`cbegin`没有调用成员函数`cbegin`吧？我也是。但是请跟逻辑走。这个`cbegin`模板接受任何代表类似容器的数据结构的实参类型`C`，并且通过reference-to-`const`形参`container`访问这个实参。如果`C`是一个普通的容器类型（如`std::vector<int>`），`container`将会引用一个`const`版本的容器（如`const std::vector<int>&`）。对`const`容器调用非成员函数`begin`（由C++11提供）将产出`const_iterator`，这个迭代器也是模板要返回的。用这种方法实现的好处是就算容器只提供`begin`成员函数（对于容器来说，C++11的非成员函数`begin`调用这些成员函数）不提供`cbegin`成员函数也没问题。那么现在你可以将这个非成员函数`cbegin`施于只直接支持`begin`的容器。

**如果`C`是原生数组，这个模板也能工作**。这时，`container`成为一个`const`数组的引用。C++11为数组提供特化版本的非成员函数`begin`，它返回指向数组第一个元素的指针。一个`const`数组的元素也是`const`，所以对于`const`数组，非成员函数`begin`返回指向`const`的指针（pointer-to-`const`）。在数组的上下文中，所谓指向`const`的指针（pointer-to-`const`），也就是`const_iterator`了。

回到最开始，**本条款的中心是鼓励你只要能就使用`const_iterator`**。最原始的动机——只要它有意义就加上`const`——是C++98就有的思想。但是在C++98，它（译注：`const_iterator`）只是一般有用，到了C++11，它就是极其有用了，C++14在其基础上做了些修补工作。

> **请记住：**

- ***优先考虑`const_iterator`而非`iterator`***
- ***在最大程度的通用的代码中，优先考虑非成员函数版本的`begin`，`end`，`rbegin`等，而非同名成员函数***







####	Item 14:如果函数不抛出异常请使用noexcept

在C++98中，异常说明（*exception specifications*）是喜怒无常的野兽。你不得不写出函数可能抛出的异常类型，如果函数实现有所改变，异常说明也可能需要修改。改变异常说明会影响客户端代码，因为调用者可能依赖原版本的异常说明。编译器不会在函数实现，异常说明和客户端代码之间提供一致性保障。大多数程序员最终都认为不值得为C++98的异常说明做得如此麻烦。

**在C++11标准化过程中，大家一致认为异常说明真正有用的信息是一个函数是否会抛出异常**。非黑即白，一个函数可能抛异常，或者不会。**这种"可能-绝不"的二元论构成了C++11异常说的基础，从根本上改变了C++98的异常说明**。（C++98风格的异常说明也有效，但是已经标记为deprecated（废弃））。在C++11中，无条件的`noexcept`保证函数不会抛出任何异常。

关于一个函数是否已经声明为`noexcept`是接口设计的事。函数的异常抛出行为是客户端代码最关心的。**调用者可以查看函数是否声明为`noexcept`，这个可以影响到调用代码的异常安全性（*exception safety*）和效率**。就其本身而言，**函数是否为`noexcept`和成员函数是否`const`一样重要。当你知道这个函数不会抛异常而没加上`noexcept`，那这个接口说明就有点差劲了**。

不过这里还有给不抛异常的函数加上`noexcept`的动机：**它允许编译器生成更好的目标代码**。要想知道为什么，了解C++98和C++11指明一个函数不抛异常的方式是很有用了。考虑一个函数`f`，它保证调用者永远不会收到一个异常。两种表达方式如下：

```c++
int f(int x) throw();   //C++98风格，没有来自f的异常
int f(int x) noexcept;  //C++11风格，没有来自f的异常
```

如果在运行时，`f`出现一个异常，那么就和`f`的异常说明冲突了。在C++98的异常说明中，调用栈（the *call stack*）会展开至`f`的调用者，在一些与这地方不相关的动作后，程序被终止。C++11异常说明的运行时行为有些不同：调用栈只是**可能**在程序终止前展开。

**展开调用栈和可能展开调用栈两者对于代码生成（code generation）有非常大的影响**。在一个`noexcept`函数中，当异常可能传播到函数外时，优化器不需要保证运行时栈（the runtime stack）处于可展开状态；也不需要保证当异常离开`noexcept`函数时，`noexcept`函数中的对象按照构造的反序析构。而标注“`throw()`”异常声明的函数缺少这样的优化灵活性，没加异常声明的函数也一样。可以总结一下：

```c++
RetType function(params) noexcept;  //极尽所能优化
RetType function(params) throw();   //较少优化
RetType function(params);           //较少优化
```

**`noexcept`函数较比`non-noexcept`函数更容易优化**，这是一个充分的理由使得你当知道它不抛异常时加上`noexcept`。



还有一些函数更符合这个情况（***`noexcept`是函数接口的一部分，这意味着调用者可能会依赖它***）。移动操作是绝佳的例子。假如你有一份C++98代码，里面用到了`std::vector<Widget>`。`Widget`通过`push_back`一次又一次的添加进`std::vector`：

```c++
std::vector<Widget> vw;
…
Widget w;
…                   //用w做点事
vw.push_back(w);    //把w添加进vw
…

```

....



> **请记住**

- ***`noexcept`是函数接口的一部分，这意味着调用者可能会依赖它***
- ***`noexcept`函数较之于`non-noexcept`函数更容易优化***
- ***`noexcept`对于移动语义，`swap`，内存释放函数和析构函数非常有用***
- ***大多数函数是异常中立（异常无关，可能抛出也可能不抛出异常）而不是`noexcept`***



####	Item 15:尽可能的使用constexpr

C++11中最容易混淆的新词，非constexpr莫属。当用于对象时，它本质上是const的一种增强形式。但是当用于函数时，它就有完全不同的含义。

从概念上讲，constexpr表示的是一个编译期间已知的常量值。但是当constexpr用于函数时，就不一样。不能假定constexpr函数的结果是const，也不能想当然地认为它们地值在编译期间是已知的。



编译期可知的值“享有特权”，它们可能被存放到只读存储空间中。对于那些嵌入式系统的开发者，这个特性是相当重要的。更广泛的应用是“其值编译期可知”的常量整数会出现在需要“整型常量表达式（**integral constant expression**）的上下文中，**这类上下文包括数组大小，整数模板参数（包括`std::array`对象的长度），枚举名的值，对齐修饰符（译注：[`alignas(val)`](https://en.cppreference.com/w/cpp/language/alignas)）**，等等。如果你想在这些上下文中使用变量，你一定会希望将它们声明为`constexpr`，因为编译器会确保它们是编译期可知的：

```c++
int sz;                             //non-constexpr变量
…
constexpr auto arraySize1 = sz;     //错误！sz的值在
                                    //编译期不可知
std::array<int, sz> data1;          //错误！一样的问题
constexpr auto arraySize2 = 10;     //没问题，10是
                                    //编译期可知常量
std::array<int, arraySize2> data2;  //没问题, arraySize2是constexpr
```



注意`const`不提供`constexpr`所能保证之事，因为`const`对象不需要在编译期初始化它的值。



```c++
int sz;                            //和之前一样
…
const auto arraySize = sz;         //没问题，arraySize是sz的const复制
std::array<int, arraySize> data;   //错误，arraySize值在编译期不可知
```



**简而言之，所有`constexpr`对象都是`const`（顶层const），但不是所有`const`对象都是`constexpr`**。如果你想编译器保证一个变量有一个值，这个值可以放到那些需要编译期常量（compile-time constants）的上下文的地方，你需要的工具是`constexpr`而不是`const`。



涉及到`constexpr`函数时，`constexpr`对象的使用情况就更有趣了。如果实参是编译期常量，这些函数将产出编译期常量；如果实参是运行时才能知道的值，它们就将产出运行时值。这听起来就像你不知道它们要做什么一样，那么想是错误的，请这么看：

- `constexpr`函数可以用于需求编译期常量的上下文。如果你传给`constexpr`函数的实参在编译期可知，那么结果将在编译期计算。如果实参的值在编译期不知道，你的代码就会被拒绝。
- 当一个`constexpr`函数被一个或者多个编译期不可知值调用时，它就像普通函数一样，运行时计算它的结果。这意味着你不需要两个函数，一个用于编译期计算，一个用于运行时计算。`constexpr`全做了。

假设我们需要一个数据结构来存储一个实验的结果，而这个实验可能以各种方式进行。实验期间风扇转速，温度等等都可能导致亮度值改变，亮度值可以是高，低，或者无。如果有**n**个实验相关的环境条件，它们每一个都有三个状态，最终可以得到的组合有3n个。储存所有实验结果的所有组合需要足够存放3n个值的数据结构。假设每个结果都是`int`并且**n**是编译期已知的（或者可以被计算出的），一个`std::array`是一个合理的选择。我们需要一个方法在编译期计算3n。C++标准库提供了`std::pow`，它的数学功能正是我们所需要的，但是，对我们来说，这里还有两个问题。第一，`std::pow`是为浮点类型设计的，我们需要整型结果。第二，`std::pow`不是`constexpr`（即，不保证使用编译期可知值调用而得到编译期可知的结果），所以我们不能用它作为`std::array`的大小。

幸运的是，我们可以应需写个`pow`。我将展示怎么快速完成它，不过现在让我们先看看它应该怎么被声明和使用：

```c++
constexpr                                   //pow是绝不抛异常的
int pow(int base, int exp) noexcept         //constexpr函数
{
 …                                          //实现在下面
}
constexpr auto numConds = 5;                //（上面例子中）条件的个数
std::array<int, pow(3, numConds)> results;  //结果有3^numConds个元素
```

回忆下`pow`前面的`constexpr`不表明`pow`返回一个`const`值，它只说了如果`base`和`exp`是编译期常量，`pow`的值可以被当成编译期常量使用。如果`base`和/或`exp`不是编译期常量，`pow`结果将会在运行时计算。这意味着`pow`不止可以用于像`std::array`的大小这种需要编译期常量的地方，它也可以用于运行时环境：

```c++
auto base = readFromDB("base");     //运行时获取这些值
auto exp = readFromDB("exponent"); 
auto baseToExp = pow(base, exp);    //运行时调用pow函数
```

因为`constexpr`函数必须能在编译期值调用的时候返回编译期结果，就必须对它的实现施加一些限制。这些限制在C++11和C++14标准间有所出入。

**C++11中，`constexpr`函数的代码不超过一行语句：一个`return`**。听起来很受限，但实际上有两个技巧可以扩展`constexpr`函数的表达能力。第一，使用三元运算符“`?:`”来代替`if`-`else`语句，第二，使用递归代替循环。因此`pow`可以像这样实现：

```c++
constexpr int pow(int base, int exp) noexcept
{
    return (exp == 0 ? 1 : base * pow(base, exp - 1));
}
```

这样没问题，但是很难想象除了使用函数式语言的程序员外会觉得这样硬核的编程方式更好。**在C++14中，`constexpr`函数的限制变得非常宽松了**，所以下面的函数实现成为了可能：

```c++
constexpr int pow(int base, int exp) noexcept   //C++14
{
    auto result = 1;
    for (int i = 0; i < exp; ++i) result *= base;
    
    return result;
}
```

`constexpr`函数限制为只能获取和返回**字面值类型**，这基本上意味着那些有了值的类型能在编译期决定。**在C++11中，除了`void`外的所有内置类型，以及一些用户定义类型都可以是字面值类型，因为构造函数和其他成员函数可能是`constexpr`**：

```c++
class Point {
public:
    constexpr Point(double xVal = 0, double yVal = 0) noexcept
    : x(xVal), y(yVal)
    {}

    constexpr double xValue() const noexcept { return x; } 
    constexpr double yValue() const noexcept { return y; }

    void setX(double newX) noexcept { x = newX; }
    void setY(double newY) noexcept { y = newY; }

private:
    double x, y;
};
```

**`Point`的构造函数可被声明为`constexpr`，因为如果传入的参数在编译期可知，`Point`的数据成员也能在编译器可知。因此这样初始化的`Point`就能为`constexpr`：**

```c++
constexpr Point p1(9.4, 27.7);  //没问题，constexpr构造函数
                                //会在编译期“运行”
constexpr Point p2(28.8, 5.3);  //也没问题
```

类似的，`xValue`和`yValue`的*getter*（取值器）函数也能是`constexpr`，因为如果对一个编译期已知的`Point`对象（如一个`constexpr` `Point`对象）调用*getter*，数据成员`x`和`y`的值也能在编译期知道。这使得我们可以写一个`constexpr`函数，里面调用`Point`的*getter*并初始化`constexpr`的对象：

```c++
constexpr
Point midpoint(const Point& p1, const Point& p2) noexcept
{
    return { (p1.xValue() + p2.xValue()) / 2,   //调用constexpr
             (p1.yValue() + p2.yValue()) / 2 }; //成员函数
}
constexpr auto mid = midpoint(p1, p2);      //使用constexpr函数的结果
                                            //初始化constexpr对象
```

这太令人激动了。它意味着`mid`对象通过调用构造函数，*getter*和非成员函数来进行初始化过程就能在只读内存中被创建出来！它也意味着你可以在模板实参或者需要枚举名的值的表达式里面使用像`mid.xValue() * 10`的表达式！（因为`Point::xValue`返回`double`，`mid.xValue() * 10`也是个`double`。浮点数类型不可被用于实例化模板或者说明枚举名的值，但是它们可以被用来作为产生整数值的大表达式的一部分。比如，`static_cast<int>(mid.xValue() * 10)`可以被用来实例化模板或者说明枚举名的值。）它也意味着以前相对严格的编译期完成的工作和运行时完成的工作的界限变得模糊，一些传统上在运行时的计算过程能并入编译时。越多这样的代码并入，你的程序就越快。（然而，编译会花费更长时间）

在C++11中，有两个限制使得`Point`的成员函数`setX`和`setY`不能声明为`constexpr`。**第一，它们修改它们操作的对象的状态， 并且在C++11中，`constexpr`成员函数是隐式的`const`。第二，它们有`void`返回类型，`void`类型不是C++11中的字面值类型**。这两个限制在C++14中放开了，所以C++14中`Point`的*setter*（赋值器）也能声明为`constexpr`：

```c++
class Point {
public:
    …
    constexpr void setX(double newX) noexcept { x = newX; } //C++14
    constexpr void setY(double newY) noexcept { y = newY; } //C++14
    …
};
```

现在也能写这样的函数：

```c++
//返回p相对于原点的镜像
constexpr Point reflection(const Point& p) noexcept
{
    Point result;                   //创建non-const Point
    result.setX(-p.xValue());       //设定它的x和y值
    result.setY(-p.yValue());
    return result;                  //返回它的副本
}
```

客户端代码可以这样写：

```c++
constexpr Point p1(9.4, 27.7);          //和之前一样
constexpr Point p2(28.8, 5.3);
constexpr auto mid = midpoint(p1, p2);

constexpr auto reflectedMid =         //reflectedMid的值
    reflection(mid);                  //(-19.1, -16.5)在编译期可知

```

本条款的建议是尽可能的使用`constexpr`，现在我希望大家已经明白缘由：**`constexpr`对象和`constexpr`函数可以使用的范围比non-`constexpr`对象和函数大得多。使用`constexpr`关键字可以最大化你的对象和函数可以使用的场景**。

还有个重要的需要注意的是**`constexpr`是对象和函数接口的一部分**。**加上`constexpr`相当于宣称“我能被用在C++要求常量表达式的地方”**。如果你声明一个对象或者函数是`constexpr`，客户端程序员就可能会在那些场景中使用它。如果你后面认为使用`constexpr`是一个错误并想移除它，你可能造成大量客户端代码不能编译。（为了debug或者性能优化而添加I/O到一个函数中这样简单的动作可能就导致这样的问题，因为I/O语句一般不被允许出现在`constexpr`函数里）“尽可能”的使用`constexpr`表示你需要长期坚持对某个对象或者函数施加这种限制。

> **请记住**

- ***`constexpr`对象是`const`，并且使用编译时已知的值进行初始化***
- ***当用编译时已知值作为实参调用`constexpr`函数时，生成的是编译时结果***
- ***`constexpr`对象和函数比`non-constexpr`对象和函数可使用的场景更大***
- ***`constexpr`是对象和函数接口的一部分***







####	Item 16:让const成员函数线程安全





####	Item 17:理解特殊成员函数的生成







> **请记住**

- ***特殊成员函数是编译器可能自动生成的函数：默认构造函数，析构函数，拷贝操作，移动操作***
- ***移动操作仅当类没有显式声明移动操作，拷贝操作，析构函数时才自动生成***
- ***拷贝构造函数仅当类没有显式声明拷贝构造函数时才自动生成，拷贝赋值运算符仅当类没有显式声明拷贝赋值运算符时才自动生成。如果用户声明了移动操作，拷贝构造函数和拷贝赋值运算符是delete的。当用户声明了析构函数，拷贝操作不会自动生成***
- ***成员函数模板不抑制特殊成员函数的生成***



##	4.智能指针

**原始指针存在的问题：**

- **它的声明不能指示所指到底是单个对象还是数组。**
- **它的声明没有告诉你用完后是否应该销毁它，即指针是否拥有所指之物。**
- **如果你决定你应该销毁指针所指对象，没人告诉你该用`delete`还是其他析构机制（比如将指针传给专门的销毁函数）。**
- **如果你发现该用`delete`。 原因1说了可能不知道该用单个对象形式（“`delete`”）还是数组形式（“`delete[]`”）。如果用错了结果是未定义的。**
- **假设你确定了指针所指，知道销毁机制，也很难确定你在所有执行路径上都执行了恰为一次销毁操作（包括异常产生后的路径）。少一条路径就会产生资源泄漏，销毁多次还会导致未定义行为。**
- **一般来说没有办法告诉你指针是否变成了悬空指针（dangling pointers），即内存中不再存在指针所指之物。在对象销毁后指针仍指向它们就会产生悬空指针。**



**智能指针**（*smart pointers*）是解决这些问题的一种办法。智能指针包裹原始指针，它们的行为看起来像被包裹的原始指针，但避免了原始指针的很多陷阱。你应该更倾向于智能指针而不是原始指针。**几乎原始指针能做的所有事情智能指针都能做**，而且出错的机会更少。



**在C++11中存在四种智能指针：`std::auto_ptr`，`std::unique_ptr`，`std::shared_ptr`，` std::weak_ptr`。都是被设计用来帮助管理动态对象的生命周期，在适当的时间通过适当的方式来销毁对象，以避免出现资源泄露或者异常行为。**

**`std::auto_ptr`是来自C++98的已废弃遗留物**，它是一次标准化的尝试，后来变成了C++11的`std::unique_ptr`。要正确的模拟原生指针需要移动语义，但是C++98没有这个东西。取而代之，`std::auto_ptr`拉拢拷贝操作来达到自己的移动意图。这导致了令人奇怪的代码（拷贝一个`std::auto_ptr`会将它本身设置为null！）和令人沮丧的使用限制（比如不能将`std::auto_ptr`放入容器）。

`std::unique_ptr`能做`std::auto_ptr`可以做的所有事情以及更多。它能高效完成任务，而且不会扭曲自己的原本含义而变成拷贝对象。在所有方面它都比`std::auto_ptr`好。现在`std::auto_ptr`唯一合法的使用场景就是代码使用C++98编译器编译。除非你有上述限制，否则你就该把`std::auto_ptr`替换为`std::unique_ptr`而且绝不回头。

各种智能指针的API有极大的不同。唯一功能性相似的可能就是默认构造函数。因为有很多关于这些API的详细手册，所以我将只关注那些API概览没有提及的内容，比如值得注意的使用场景，运行时性能分析等，掌握这些信息可以更高效的使用智能指针。



####	Item 18:对于独占资源使用std::unique_ptr

当你需要一个智能指针时，`std::unique_ptr`通常是最合适的。可以合理假设，**默认情况下，`std::unique_ptr`大小等同于原始指针**，而且对于大多数操作（包括取消引用），**他们执行的指令完全相同**。这意味着你甚至可以在内存和时间都比较紧张的情况下使用它。**如果原始指针够小够快，那么`std::unique_ptr`一样可以**。

`std::unique_ptr`体现了专有所有权（*exclusive ownership*）语义。一个non-null `std::unique_ptr`始终拥有其指向的内容。**移动一个`std::unique_ptr`将所有权从源指针转移到目的指针。（源指针被设为null。）拷贝一个`std::unique_ptr`是不允许的**，**因为如果你能拷贝一个`std::unique_ptr`，你会得到指向相同内容的两个`std::unique_ptr`，每个都认为自己拥有（并且应当最后销毁）资源，销毁时就会出现重复销毁**。**因此，`std::unique_ptr`是一种只可移动类型（*move-only type***）。当析构时，一个non-null `std::unique_ptr`销毁它指向的资源。默认情况下，资源析构通过对`std::unique_ptr`里原始指针调用`delete`来实现。



`std::unique_ptr`的常见用法是作为继承层次结构中对象的**工厂函数**返回类型。假设我们有一个投资类型（比如股票、债券、房地产等）的继承结构，使用基类`Investment`:

```c++
class Investment { … };
class Stock: public Investment { … };
class Bond: public Investment { … };
class RealEstate: public Investment { … };
```

![image-20230402211150235](/images/mdpic/image-20230402211150235.png)

这种继承关系的工厂函数在堆上分配一个对象然后返回指针，调用方在不需要的时候有责任销毁对象。这使用场景完美匹配`std::unique_ptr`，因为调用者对工厂返回的资源负责（即对该资源的专有所有权），并且`std::unique_ptr`在自己被销毁时会自动销毁指向的内容。`Investment`继承关系的工厂函数可以这样声明：

```c++
template<typename... Ts>            
std::unique_ptr<Investment>	makeInvestment(Ts&&... params);
//返回指向对象的std::unique_ptr，对象使用给定实参创建
```

调用者应该在单独的作用域中使用返回的`std::unique_ptr`智能指针：

```c++
{
    …
    auto pInvestment =                  //pInvestment是
        makeInvestment( arguments );    //std::unique_ptr<Investment>类型
    …
}                                       //销毁 *pInvestment
```

但是也可以在所有权转移的场景中使用它，比如将工厂返回的`std::unique_ptr`移入容器中，然后将容器元素移入一个对象的数据成员中，然后对象过后被销毁。发生这种情况时，这个对象的`std::unique_ptr`数据成员也被销毁，并且智能指针数据成员的析构将导致从工厂返回的资源被销毁。如果所有权链由于异常或者其他非典型控制流出现中断（比如提前从函数return或者循环中的`break`），则拥有托管资源的`std::unique_ptr`将保证指向内容的析构函数被调用，销毁对应资源。**（这个规则也有些例外。大多数情况发生于不正常的程序终止。如果一个异常传播到线程的基本函数（比如程序初始线程的`main`函数）外，或者违反`noexcept`说明（见[Item14](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item14.html)），局部变量可能不会被销毁；如果`std::abort`或者退出函数（如`std::_Exit`，`std::exit`，或`std::quick_exit`）被调用，局部变量一定没被销毁。）**



默认情况下，销毁将通过`delete`进行，但是在构造过程中，`std::unique_ptr`对象可以被设置为使用（对资源的）**自定义删除器**：当资源需要销毁时可调用的任意函数（或者函数对象，包括*lambda*表达式）。如果通过`makeInvestment`创建的对象不应仅仅被`delete`，而应该先写一条日志:

```c++
auto delInvmt = [](Investment* pInvestment)         //自定义删除器
                {                                   //（lambda表达式）
                    makeLogEntry(pInvestment);
                    delete pInvestment; 
                };

template<typename... Ts>
std::unique_ptr<Investment, decltype(delInvmt)>     //更改后的返回类型
makeInvestment(Ts&&... params)
{
    std::unique_ptr<Investment, decltype(delInvmt)> //应返回的指针
        pInv(nullptr, delInvmt);
    if (/*一个Stock对象应被创建*/)
    {
        pInv.reset(new Stock(std::forward<Ts>(params)...));
    }
    else if ( /*一个Bond对象应被创建*/ )   
    {     
        pInv.reset(new Bond(std::forward<Ts>(params)...));   
    }   
    else if ( /*一个RealEstate对象应被创建*/ )   
    {     
        pInv.reset(new RealEstate(std::forward<Ts>(params)...));   
    }   
    return pInv;
}
```



这个实现确实相当棒，如果你理解了：

- `delInvmt`是从`makeInvestment`返回的对象的自定义的删除器。所有的自定义的删除行为接受要销毁对象的原始指针，然后执行所有必要行为实现销毁操作。在上面情况中，操作包括调用`makeLogEntry`然后应用`delete`。使用*lambda*创建`delInvmt`是方便的，而且，正如稍后看到的，比编写常规的函数更有效。
- 当使用自定义删除器时，删除器类型必须作为第二个类型实参传给`std::unique_ptr`。在上面情况中，就是`delInvmt`的类型，这就是为什么`makeInvestment`返回类型是`std::unique_ptr<Investment, decltype(delInvmt)>`。（对于`decltype`，更多信息查看[Item3](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item3.html)）
- `makeInvestment`的基本策略是创建一个空的`std::unique_ptr`，然后指向一个合适类型的对象，然后返回。为了将自定义删除器`delInvmt`与`pInv`关联，我们把`delInvmt`作为`pInv`构造函数的第二个实参。
- 尝试将原始指针（比如`new`创建）赋值给`std::unique_ptr`通不过编译，因为是一种从原始指针到智能指针的隐式转换。这种隐式转换会出问题，所以C++11的智能指针禁止这个行为。这就是通过`reset`来让`pInv`接管通过`new`创建的对象的所有权的原因。
- **使用`new`时，我们使用`std::forward`把传给`makeInvestment`的实参完美转发出去（查看[Item25](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item25.html)）。这使调用者提供的所有信息可用于正在创建的对象的构造函数。**
- **自定义删除器的一个形参，类型是`Investment*`，不管在`makeInvestment`内部创建的对象的真实类型（如`Stock`，`Bond`，或`RealEstate`）是什么，它最终在*lambda*表达式中，作为`Investment*`对象被删除。这意味着我们通过基类指针删除派生类实例，为此，基类`Investment`必须有虚析构函数：**

```c++
class Investment {
public:
    …
    virtual ~Investment();          //关键设计部分！
    …
};

```

在C++14中，函数的返回类型推导存在（参阅[Item3](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item3.html)），意味着`makeInvestment`可以以更简单，更封装的方式实现：

```c++
template<typename... Ts>
auto makeInvestment(Ts&&... params)                 //C++14
{
    auto delInvmt = [](Investment* pInvestment)     //现在在
                    {                               //makeInvestment里
                        makeLogEntry(pInvestment);
                        delete pInvestment; 
                    };

    std::unique_ptr<Investment, decltype(delInvmt)> //同之前一样
        pInv(nullptr, delInvmt);
    if ( … )                                        //同之前一样
    {
        pInv.reset(new Stock(std::forward<Ts>(params)...));
    }
    else if ( … )                                   //同之前一样
    {     
        pInv.reset(new Bond(std::forward<Ts>(params)...));   
    }   
    else if ( … )                                   //同之前一样
    {     
        pInv.reset(new RealEstate(std::forward<Ts>(params)...));   
    }   
    return pInv;                                    //同之前一样
}
```

我之前说过，当使用默认删除器时（如`delete`），你可以合理假设`std::unique_ptr`对象和原始指针大小相同。当自定义删除器时，情况可能不再如此。函数指针形式的删除器，通常会使`std::unique_ptr`的从一个字（*word*）大小增加到两个。对于函数对象形式的删除器来说，变化的大小取决于函数对象中存储的状态多少，**无状态函数（stateless function）**对象（比如不捕获变量的*lambda*表达式）对大小没有影响，这意味当自定义删除器可以实现为函数或者*lambda*时，尽量使用*lambda*：

![image-20230402211851846](/images/mdpic/image-20230402211851846.png)

```c++
auto delInvmt1 = [](Investment* pInvestment)        //无状态lambda的
                 {                                  //自定义删除器
                     makeLogEntry(pInvestment);
                     delete pInvestment; 
                 };

template<typename... Ts>                            //返回类型大小是
std::unique_ptr<Investment, decltype(delInvmt1)>    //Investment*的大小
makeInvestment(Ts&&... args);

void delInvmt2(Investment* pInvestment)             //函数形式的
{                                                   //自定义删除器
    makeLogEntry(pInvestment);
    delete pInvestment;
}
template<typename... Ts>                            //返回类型大小是
std::unique_ptr<Investment, void (*)(Investment*)>  //Investment*的指针
makeInvestment(Ts&&... params);                     //加至少一个函数指针的大小

```

我之前说过，当使用默认删除器时（如`delete`），你可以合理假设`std::unique_ptr`对象和原始指针大小相同。当自定义删除器时，情况可能不再如此。函数指针形式的删除器，通常会使`std::unique_ptr`的从一个字（*word*）大小增加到两个。对于函数对象形式的删除器来说，变化的大小取决于函数对象中存储的状态多少，无状态函数（stateless function）对象（比如不捕获变量的*lambda*表达式）对大小没有影响，这意味当自定义删除器可以实现为函数或者*lambda*时，尽量使用*lambda*：

```c++
auto delInvmt1 = [](Investment* pInvestment)        //无状态lambda的
                 {                                  //自定义删除器
                     makeLogEntry(pInvestment);
                     delete pInvestment; 
                 };

template<typename... Ts>                            //返回类型大小是
std::unique_ptr<Investment, decltype(delInvmt1)>    //Investment*的大小
makeInvestment(Ts&&... args);

void delInvmt2(Investment* pInvestment)             //函数形式的
{                                                   //自定义删除器
    makeLogEntry(pInvestment);
    delete pInvestment;
}
template<typename... Ts>                            //返回类型大小是
std::unique_ptr<Investment, void (*)(Investment*)>  //Investment*的指针
makeInvestment(Ts&&... params);                     //加至少一个函数指针的大小
```



具有很多状态的自定义删除器会产生大尺寸`std::unique_ptr`对象。如果你发现自定义删除器使得你的`std::unique_ptr`变得过大，你需要审视修改你的设计。

工厂函数不是`std::unique_ptr`的唯一常见用法。作为实现**Pimpl Idiom**（译注：*pointer to implementation*，一种隐藏实际实现而减弱编译依赖性的设计思想，《Effective C++》条款31对此有过叙述）的一种机制，它更为流行。代码并不复杂，但是在某些情况下并不直观，所以这安排在[Item22](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item22.html)的专门主题中。

`std::unique_ptr`有两种形式，一种用于单个对象（`std::unique_ptr<T>`），一种用于数组（`std::unique_ptr<T[]>`）。结果就是，指向哪种形式没有歧义。`std::unique_ptr`的API设计会自动匹配你的用法，比如`operator[]`就是数组对象，解引用操作符（`operator*`和`operator->`）就是单个对象专有。

你应该对数组的`std::unique_ptr`的存在兴趣泛泛，因为`std::array`，`std::vector`，`std::string`这些更好用的数据容器应该取代原始数组。`std::unique_ptr<T[]>`有用的唯一情况是你使用类似C的API返回一个指向堆数组的原始指针，而你想接管这个数组的所有权。

`std::unique_ptr`是C++11中表示专有所有权的方法，但是其最吸引人的功能之一是它可以轻松高效的转换为`std::shared_ptr`：

```c++
std::shared_ptr<Investment> sp =            //将std::unique_ptr
    makeInvestment(arguments);              //转为std::shared_ptr

std::shared_ptr<Investment> sp = std::move(unique_prt...)	//也是可以的
```

这就是`std::unique_ptr`非常适合用作工厂函数返回类型的原因的关键部分。 工厂函数无法知道调用者是否要对它们返回的对象使用专有所有权语义，或者共享所有权（即`std::shared_ptr`）是否更合适。 通过返回`std::unique_ptr`，工厂为调用者提供了最有效的智能指针，但它们并不妨碍调用者用其更灵活的兄弟替换它。（有关`std::shared_ptr`的信息，请转到[Item19](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item19.html)。)



> **请记住**

- ***`std::unique_ptr`是轻量级、快速的、只可移动（move-only）的管理专有所有权语义资源的智能指针***
- ***默认情况，资源销毁通过`delete`实现，但是支持自定义删除器。有状态的删除器和函数指针会增加`std::unique_ptr`对象的大小***
- ***将`std::unique_ptr`转化为`std::shared_ptr`非常简单***



####	Item 19:对于共享资源使用std::shard_ptr

`std::shared_ptr`通过**引用计数（*reference count*）**来确保它是否是最后一个指向某种资源的指针，引用计数关联资源并跟踪有多少`std::shared_ptr`指向该资源。`std::shared_ptr`构造函数递增引用计数值（注意是**通常**——原因参见下面），析构函数递减值，拷贝赋值运算符做前面这两个工作。（**如果`sp1`和`sp2`是`std::shared_ptr`并且指向不同对象，赋值“`sp1 = sp2;`”会使`sp1`指向`sp2`指向的对象。直接效果就是`sp1`引用计数减一，`sp2`引用计数加一。**）如果`std::shared_ptr`在计数值递减后发现引用计数值为零，没有其他`std::shared_ptr`指向该资源，它就会销毁资源。



引用计数暗示着性能问题：

- **`std::shared_ptr`大小是原始指针的两倍**，因为它内部包含一个指向资源的原始指针，还包含一个指向资源的引用计数值的原始指针。（这种实现法并不是标准要求的，但是我（指原书作者Scott Meyers）熟悉的所有标准库都这样实现。）
- **引用计数的内存必须动态分配**。 概念上，引用计数与所指对象关联起来，但是实际上被指向的对象不知道这件事情（译注：不知道有一个关联到自己的计数值）。因此它们没有办法存放一个引用计数值。（一个好消息是任何对象——甚至是内置类型的——都可以由`std::shared_ptr`管理。）[Item21](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item21.html)会解释使用`std::make_shared`创建`std::shared_ptr`可以避免引用计数的动态分配，但是还存在一些`std::make_shared`不能使用的场景，这时候引用计数就会动态分配。
- **递增递减引用计数必须是原子性的**，因为多个reader、writer可能在不同的线程。比如，指向某种资源的`std::shared_ptr`可能在一个线程执行析构（于是递减指向的对象的引用计数），在另一个不同的线程，`std::shared_ptr`指向相同的对象，但是执行的却是拷贝操作（因此递增了同一个引用计数）。原子操作通常比非原子操作要慢，所以即使引用计数通常只有一个*word*大小，你也应该假定读写它们是存在开销的。
- 

我写道`std::shared_ptr`构造函数只是“通常”递增指向对象的引用计数会不会让你有点好奇？创建一个指向对象的`std::shared_ptr`就产生了又一个指向那个对象的`std::shared_ptr`，为什么我没说**总是**增加引用计数值？

原因是移动构造函数的存在。**从另一个`std::shared_ptr`移动构造新`std::shared_ptr`会将原来的`std::shared_ptr`设置为null，那意味着老的`std::shared_ptr`不再指向资源，同时新的`std::shared_ptr`指向资源。这样的结果就是不需要修改引用计数值**。因此移动`std::shared_ptr`会比拷贝它要快：拷贝要求递增引用计数值，移动不需要。移动赋值运算符同理，所以移动构造比拷贝构造快，移动赋值运算符也比拷贝赋值运算符快。

类似`std::unique_ptr`（参见[Item18](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item18.html)），`std::shared_ptr`使用`delete`作为资源的默认销毁机制，但是它也支持自定义的删除器。这种支持有别于`std::unique_ptr`。对于`std::unique_ptr`来说，删除器类型是智能指针类型的一部分。对于`std::shared_ptr`则不是：

```c++
auto loggingDel = [](Widget *pw)        //自定义删除器
                  {                     //（和条款18一样）
                      makeLogEntry(pw);
                      delete pw;
                  };

std::unique_ptr<                        //删除器类型是
    Widget, decltype(loggingDel)        //指针类型的一部分
    > upw(new Widget, loggingDel);
std::shared_ptr<Widget>                 //删除器类型不是
    spw(new Widget, loggingDel);        //指针类型的一部分
```

`std::shared_ptr`的设计更为灵活。考虑有两个`std::shared_ptr<Widget>`，每个自带不同的删除器（比如通过*lambda*表达式自定义删除器）：

```c++
auto customDeleter1 = [](Widget *pw) { … };     //自定义删除器，
auto customDeleter2 = [](Widget *pw) { … };     //每种类型不同
std::shared_ptr<Widget> pw1(new Widget, customDeleter1);
std::shared_ptr<Widget> pw2(new Widget, customDeleter2);
```

因为`pw1`和`pw2`有相同的类型，所以它们都可以放到存放那个类型的对象的容器中：

```c++
std::vector<std::shared_ptr<Widget>> vpw{ pw1, pw2 };
```

它们也能相互赋值，也可以传入一个形参为`std::shared_ptr<Widget>`的函数。但是自定义删除器类型不同的`std::unique_ptr`就不行，因为`std::unique_ptr`把删除器视作类型的一部分。

另一个不同于`std::unique_ptr`的地方是，**指定自定义删除器不会改变`std::shared_ptr`对象的大小**。不管删除器是什么，一个`std::shared_ptr`对象都是两个指针大小。这是个好消息，但是它应该让你隐隐约约不安。自定义删除器可以是函数对象，函数对象可以包含任意多的数据。它意味着函数对象是任意大的。`std::shared_ptr`怎么能引用一个任意大的删除器而不使用更多的内存？

它不能。它必须使用更多的内存。然而，那部分内存不是`std::shared_ptr`对象的一部分。**那部分在堆上面**，或者`std::shared_ptr`创建者利用`std::shared_ptr`对自定义分配器的支持能力，那部分内存随便在哪都行。我前面提到了`std::shared_ptr`对象包含了所指对象的引用计数的指针。没错，但是有点误导人。因为引用计数是另一个更大的数据结构的一部分，那个数据结构通常叫做**控制块**（*control block*）。每个`std::shared_ptr`管理的对象都有个相应的控制块。控制块除了包含引用计数值外还有一个自定义删除器的拷贝，当然前提是存在自定义删除器。如果用户还指定了自定义分配器，控制块也会包含一个分配器的拷贝。控制块可能还包含一些额外的数据，正如[Item21](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item21.html)提到的，**一个次级引用计数*weak count***，但是目前我们先忽略它。我们可以想象`std::shared_ptr`对象在内存中是这样：

![image-20230402222407521](/images/mdpic/image-20230402222407521.png)

当指向对象的`std::shared_ptr`一创建，对象的控制块就建立了。至少我们期望是如此。通常，对于一个创建指向对象的`std::shared_ptr`的函数来说不可能知道是否有其他`std::shared_ptr`早已指向那个对象，所以控制块的创建会遵循下面几条规则：

- **`std::make_shared`（参见[Item21](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item21.html)）总是创建一个控制块**。它创建一个要指向的新对象，所以可以肯定`std::make_shared`调用时对象不存在其他控制块。
- **当从独占指针（即`std::unique_ptr`或者`std::auto_ptr`）上构造出`std::shared_ptr`时会创建控制块**。独占指针没有使用控制块，所以指针指向的对象没有关联控制块。（作为构造的一部分，`std::shared_ptr`侵占独占指针所指向的对象的独占权，所以独占指针被设置为null）
- **当从原始指针上构造出`std::shared_ptr`时会创建控制块**。如果你想从一个早已存在控制块的对象上创建`std::shared_ptr`，你将假定传递一个`std::shared_ptr`或者`std::weak_ptr`（参见[Item20](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item20.html)）作为构造函数实参，而不是原始指针。用`std::shared_ptr`或者`std::weak_ptr`作为构造函数实参创建`std::shared_ptr`不会创建新控制块，因为它可以依赖传递来的智能指针指向控制块。

这些规则造成的后果就是从原始指针上构造超过一个`std::shared_ptr`就会让你走上未定义行为的快车道，因为指向的对象有多个控制块关联。多个控制块意味着多个引用计数值，多个引用计数值意味着对象将会被销毁多次（每个引用计数一次）。那意味着像下面的代码是有问题的，很有问题，问题很大：

```c++
auto pw = new Widget;                           //pw是原始指针
…
std::shared_ptr<Widget> spw1(pw, loggingDel);   //为*pw创建控制块
…
std::shared_ptr<Widget> spw2(pw, loggingDel);   //为*pw创建第二个控制块
```

创建原始指针`pw`指向动态分配的对象很糟糕，因为它完全背离了这章的建议：倾向于使用智能指针而不是原始指针。（如果你忘记了该建议的动机，请翻到[本章开头](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item18.html)）。撇开那个不说，创建`pw`那一行代码虽然让人厌恶，但是至少不会造成未定义程序行为。

现在，传给`spw1`的构造函数一个原始指针，它会为指向的对象创建一个控制块（因此有个引用计数值）。这种情况下，指向的对象是`*pw`（即`pw`指向的对象）。就其本身而言没什么问题，但是将同样的原始指针传递给`spw2`的构造函数会再次为`*pw`创建一个控制块（所以也有个引用计数值）。**因此`*pw`有两个引用计数值，每一个最后都会变成零，然后最终导致`*pw`销毁两次。第二个销毁会产生未定义行为。**

`std::shared_ptr`给我们上了两堂课。**第一，避免传给`std::shared_ptr`构造函数原始指针。通常替代方案是使用`std::make_shared`**（参见[Item21](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item21.html)），不过上面例子中，我们使用了自定义删除器，用`std::make_shared`就没办法做到。**第二，如果你必须传给`std::shared_ptr`构造函数原始指针，直接传`new`出来的结果，不要传指针变量**。如果上面代码第一部分这样重写：

```c++
std::shared_ptr<Widget> spw1(new Widget,    //直接使用new的结果
                             loggingDel);

```

会少了很多从原始指针上构造第二个`std::shared_ptr`的诱惑。相应的，创建`spw2`也会很自然的用`spw1`作为初始化参数（即用`std::shared_ptr`拷贝构造函数），那就没什么问题了：

```c++
std::shared_ptr<Widget> spw2(spw1);         //spw2使用spw1一样的控制块
```





**一个尤其令人意外的地方是使用`this`指针作为`std::shared_ptr`构造函数实参的时候可能导致创建多个控制块**。假设我们的程序使用`std::shared_ptr`管理`Widget`对象，我们有一个数据结构用于跟踪已经处理过的`Widget`对象：

```c++
std::vector<std::shared_ptr<Widget>> processedWidgets;

class Widget {
public:
    …
    void process();
    …
};

void Widget::process()
{
    …                                       //处理Widget
    processedWidgets.emplace_back(this);    //然后将它加到已处理过的Widget
}                                           //的列表中，这是错的！
```

注释已经说了这是错的——或者至少大部分是错的。（错误的部分是传递`this`，而不是使用了`emplace_back`。如果你不熟悉`emplace_back`，参见[Item42](https://cntransgroup.github.io/EffectiveModernCppChinese/8.Tweaks/item42.html)）。上面的代码可以通过编译，但是向`std::shared_ptr`的容器传递一个原始指针（`this`），`std::shared_ptr`会由此为指向的`Widget`（`*this`）创建一个控制块。那看起来没什么问题，**直到你意识到如果成员函数外面早已存在指向那个`Widget`对象的指针，它是未定义行为的。**



`std::shared_ptr`API已有处理这种情况的设施。它的名字可能是C++标准库中最奇怪的一个：**`std::enable_shared_from_this`。**如果你想创建一个用`std::shared_ptr`管理的类，这个类能够用`this`指针安全地创建一个`std::shared_ptr`，`std::enable_shared_from_this`就可作为基类的模板类。在我们的例子中，`Widget`将会继承自`std::enable_shared_from_this`：

```c++
class Widget: public std::enable_shared_from_this<Widget> {
public:
    …
    void process();
    …
};
```

正如我所说，`std::enable_shared_from_this`是一个基类模板。它的模板参数总是某个继承自它的类，所以`Widget`继承自`std::enable_shared_from_this<Widget>`。如果某类型继承自一个由该类型（译注：作为模板类型参数）进行模板化得到的基类这个东西让你心脏有点遭不住，别去想它就好了。代码完全合法，而且它背后的设计模式也是没问题的，并且这种设计模式还有个标准名字，尽管该名字和`std::enable_shared_from_this`一样怪异。这个标准名字就是奇异递归模板模式（*The Curiously Recurring Template Pattern*（*CRTP*））。如果你想学更多关于它的内容，请搜索引擎一展身手，现在我们要回到`std::enable_shared_from_this`上。

`std::enable_shared_from_this`定义了一个成员函数，成员函数会创建指向当前对象的`std::shared_ptr`却不创建多余控制块。这个成员函数就是**`shared_from_this`，**无论在哪当你想在成员函数中使用`std::shared_ptr`指向`this`所指对象时都请使用它。这里有个`Widget::process`的安全实现：

```c++
void Widget::process()
{
    //和之前一样，处理Widget
    …
    //把指向当前对象的std::shared_ptr加入processedWidgets
    processedWidgets.emplace_back(shared_from_this());
}

```

从内部来说，`shared_from_this`查找当前对象控制块，然后创建一个新的`std::shared_ptr`关联这个控制块。**设计的依据是当前对象已经存在一个关联的控制块**。要想符合设计依据的情况，必须已经存在一个指向当前对象的`std::shared_ptr`（比如调用`shared_from_this`的成员函数外面已经存在一个`std::shared_ptr`）。**如果没有`std::shared_ptr`指向当前对象（即当前对象没有关联控制块），行为是未定义的，`shared_from_this`通常抛出一个异常**。

**为了阻止用户在没有一个 std::shared_ptr 指向该对象之前，使用一个里面调用 shared_from_this的成员函数，继承自`std::enable_shared_from_this`的子类通常会把它们的构造函数声明为 `private`，**并且让客户端通过返回`std::shared_ptr`的工厂函数创建对象。以`Widget`为例，代码可以是这样：

```c++
class Widget: public std::enable_shared_from_this<Widget> {
public:
    //完美转发参数给private构造函数的工厂函数
    template<typename... Ts>
    static std::shared_ptr<Widget> create(Ts&&... params);
    …
    void process();     //和前面一样
    …
private:
    …                   //构造函数
};
```

（只要创建了对象，就一定有一个`shared_ptr`指向该对象）



你可能隐约记得我们讨论控制块的动机是想了解有关`std::shared_ptr`的成本。既然我们已经知道了怎么避免创建过多控制块，就让我们回到原来的主题。

控制块通常只占几个*word*大小，自定义删除器和分配器可能会让它变大一点。通常控制块的实现比你想的更复杂一些。**它使用继承，甚至里面还有一个虚函数（用来确保指向的对象被正确销毁）**。这意味着使用`std::shared_ptr`还会招致控制块使用虚函数带来的成本。

了解了动态分配控制块，任意大小的删除器和分配器，虚函数机制，原子性的引用计数修改，你对于`std::shared_ptr`的热情可能有点消退。可以理解，对每个资源管理问题来说都没有最佳的解决方案。但就它提供的功能来说，`std::shared_ptr`的开销是非常合理的。在通常情况下，使用默认删除器和默认分配器，使用`std::make_shared`创建`std::shared_ptr`，产生的控制块只需三个word大小。它的分配基本上是无开销的。（开销被并入了指向的对象的分配成本里。细节参见[Item21](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item21.html)）。对`std::shared_ptr`解引用的开销不会比原始指针高。执行需要原子引用计数修改的操作需要承担一两个原子操作开销，这些操作通常都会一一映射到机器指令上，所以即使对比非原子指令来说，原子指令开销较大，但是它们仍然只是单个指令上的。对于每个被`std::shared_ptr`指向的对象来说，控制块中的虚函数机制产生的开销通常只需要承受一次，即对象销毁的时候。

作为这些轻微开销的交换，你得到了动态分配的资源的生命周期自动管理的好处。大多数时候，比起手动管理，使用`std::shared_ptr`管理共享性资源都是非常合适的。如果你还在犹豫是否能承受`std::shared_ptr`带来的开销，那就再想想你是否需要共享所有权。如果独占资源可行或者**可能**可行，用`std::unique_ptr`是一个更好的选择。它的性能表现更接近于原始指针，并且从`std::unique_ptr`升级到`std::shared_ptr`也很容易，因为`std::shared_ptr`可以从`std::unique_ptr`上创建。

**反之不行**。**当你的资源由`std::shared_ptr`管理，现在又想修改资源生命周期管理方式是没有办法的。即使引用计数为一，你也不能重新修改资源所有权，改用`std::unique_ptr`管理它**。资源和指向它的`std::shared_ptr`的签订的所有权协议是“除非死亡否则永不分开”。**不能分离，不能废除，没有特许**。

`std::shared_ptr`不能处理的另一个东西是数组。和`std::unique_ptr`不同的是：

**`std::shared_ptr`的API设计之初就是针对单个对象的，没有办法`std::shared_ptr<T[]>`**。一次又一次，“聪明”的程序员踌躇于是否该使用`std::shared_ptr<T>`指向数组，然后传入自定义删除器来删除数组（即`delete []`）。这可以通过编译，但是是一个糟糕的主意。

一方面，`std::shared_ptr`没有提供`operator[]`，所以数组索引操作需要借助怪异的指针算术。另一方面，`std::shared_ptr`支持转换为指向基类的指针，这对于单个对象来说有效，但是当用于数组类型时相当于在类型系统上开洞。（出于这个原因，`std::unique_ptr<T[]>` API禁止这种转换。）更重要的是，C++11已经提供了很多内置数组的候选方案（比如`std::array`，`std::vector`，`std::string`）。声明一个指向傻瓜数组的智能指针（译注：也是”聪明的指针“之意）几乎总是表示着糟糕的设计。

> **请记住**

- ***`std::shared_ptr`为有共享所有权的任意资源提供一种自动垃圾回收的便捷方式***
- ***和`std::unique_ptr`比较，`std::shared_ptr`对象通常大两倍，控制块会产生开销，需要原子性的引用计数修改操作。***
- ***默认资源销毁是通过`delete`，但是也支持自定义删除器。删除器的类型是什么对于`std::shared_ptr`的类型没有影响。***
- ***避免从原始指针变量上创建`std::shared_ptr`。***



####	Item 20:当std::shared_ptr可能悬空时使用std::weak_ptr

说起来有些矛盾，如果有一个像`std::shared_ptr`（见[Item19](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item19.html)），但是不参与资源所有权共享的指针，那样可能会比较方便。换句话说，是一个类似`std::shared_ptr`但不影响对象引用计数的指针。这种类型的智能指针必须要解决一个`std::shared_ptr`不存在的问题：**可能指向已经销毁的对象。一个真正的智能指针应该跟踪所指对象，在悬空时知晓，悬空（*dangle*）就是指针指向的对象不再存在。这就是对`std::weak_ptr`最精确的描述。**

std::weak_ptr表现的不那么智能，std::weak_ptr**不能解引用**，**也不能测试是否为空值**。**这是因为std::weak_ptr不能被单独使用，它是std::shared_ptr的一种附加类型。**



这种关系与生俱来，std::weak_ptr 通常由 std::shared_ptr 创建，它们指向相同的对象， 但是 std::weak_ptr **不会影响到它所指向对象的引用计数**：

```c++
auto spw =                      //spw创建之后，指向的Widget的
    std::make_shared<Widget>(); //引用计数（ref count，RC）为1。
                                //std::make_shared的信息参见条款21
…
std::weak_ptr<Widget> wpw(spw); //wpw指向与spw所指相同的Widget。RC仍为1
…
spw = nullptr;                  //RC变为0，Widget被销毁。
                                //wpw现在悬空
```

悬空的`std::weak_ptr`被称作已经**expired**（过期）。你可以用它直接做测试：

```c++
if (wpw.expired()) …            //如果wpw没有指向对象…
```

但是通常你期望的是检查`std::weak_ptr`是否已经过期，如果没有过期则访问其指向的对象。这做起来可不是想着那么简单。因为缺少解引用操作，没有办法写这样的代码。即使有，将检查和解引用分开会引入一个竞争：在调用`expired`和解引用操作之间，另一个线程可能对指向这对象的`std::shared_ptr`重新赋值或者析构，并由此造成对象的析构。这种情况下，你的解引用将会产生未定义行为。

我么需要的是，将检查std::weak_ptr是否过期，以及如果未过期的话获得访问所指对象的权限这两种操作，合成一个**原子操作**。这可以通过从`std::weak_ptr`创建`std::shared_ptr`来实现。

具体有两种形式可以从`std::weak_ptr`上创建`std::shared_ptr`，具体用哪种取决于`std::weak_ptr`过期时你希望`std::shared_ptr`表现出什么行为。

一种形式是`std::weak_ptr::lock`，它返回一个`std::shared_ptr`，如果`std::weak_ptr`过期这个`std::shared_ptr`为空：

```c++
std::shared_ptr<Widget> spw1 = wpw.lock();  //如果wpw过期，spw1就为空
 											
auto spw2 = wpw.lock();                     //同上，但是使用auto
```

另一种形式是以`std::weak_ptr`为实参构造`std::shared_ptr`。这种情况中，**如果`std::weak_ptr`过期，会抛出一个异常**：

```c++
std::shared_ptr<Widget> spw3(wpw);        //如果wpw过期，抛出std::bad_weak_ptr异常
```



如果还对为什么需要std::weak_ptr有疑惑，可以看看下面三个例子：

1. 观察者模式。

2. 环形引用

   ![image-20230403174818172](/images/mdpic/image-20230403174818172.png)



从效率角度来看，`std::weak_ptr`与`std::shared_ptr`基本相同。两者的大小是相同的，使用相同的控制块（参见[Item19](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item19.html)），构造、析构、赋值操作涉及引用计数的原子操作。这可能让你感到惊讶，因为本条款开篇就提到`std::weak_ptr`不影响引用计数。我写的是`std::weak_ptr`不参与对象的**共享所有权**，因此不影响**指向对象的引用计数**。实际上在控制块中还是有第二个引用计数，**`std::weak_ptr`操作的是第二个引用计数。**想了解细节的话，继续看[Item21](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item21.html)吧。

> **请记住**

- ***对可能悬挂（dangle）的`shared_ptr`使用`weak_ptr`***
- ***`weak_ptr`的潜在应用场景包括缓存，观察者列表以及防止环状`shared_ptr`***



####	Item 21:优先考虑使用std::make_unique和std::make_shared，而非直接使用new

让我们先对`std::make_unique`和`std::make_shared`做个铺垫。`std::make_shared`是C++11标准的一部分，但很可惜的是，**`std::make_unique`不是。它从C++14开始加入标准库**。如果你在使用C++11，不用担心，一个基础版本的`std::make_unique`是很容易自己写出的，如下：

```c++
template<typename T, typename... Ts>
std::unique<T> make_unique(Ts&&... params){
    return std::unique_ptr<T>(new T(std::forward<Ts>(params)...));
}
```

正如你看到的，`make_unique`只是将它的参数完美转发到所要创建的对象的构造函数，从`new`产生的原始指针里面构造出`std::unique_ptr`，并返回这个`std::unique_ptr`。这种形式的函数不支持数组和自定义析构（见[Item18](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item18.html)），但它给出了一个示范：只需一点努力就能写出你想要的`make_unique`函数。（**要想实现一个特性完备的`make_unique`，就去找提供这个的标准化文件吧，然后拷贝那个实现。你想要的这个文件是N3656，是Stephan T. Lavavej写于2013-04-18的文档。）**需要记住的是，不要把它放到`std`命名空间中，因为你可能并不希望看到升级C++14标准库的时候你放进`std`命名空间的内容和编译器供应商提供的`std`命名空间的内容发生冲突。



`std::make_unique`和`std::make_shared`是**三个make函数 中的两个**：接收任意的多参数集合，完美转发到构造函数去动态分配一个对象，然后返回这个指向这个对象的指针。**第三个`make`函数是`std::allocate_shared`。它行为和`std::make_shared`一样，只不过第一个参数是用来动态分配内存的*allocator*对象。**



即使通过用和不用`make`函数来创建智能指针的一个小小比较，也揭示了为何使用`make`函数更好的**第一个**原因。例如：

```c++
auto upw1(std::make_unique<Widget>());      //使用make函数
std::unique_ptr<Widget> upw2(new Widget);   //不使用make函数
auto spw1(std::make_shared<Widget>());      //使用make函数
std::shared_ptr<Widget> spw2(new Widget);   //不使用make函数
```

我高亮了关键区别：使用`new`的版本重复了类型，但是`make`函数的版本没有。（用`new`的声明语句需要写2遍`Widget`，`make`函数只需要写一次。）

重复写类型和软件工程里面一个关键原则相冲突：应该避免重复代码。源代码中的重复增加了编译的时间，会导致目标代码冗余，并且通常会让代码库使用更加困难。它经常演变成不一致的代码，而代码库中的不一致常常导致bug。此外，打两次字比一次更费力，**而且没人不喜欢少打字吧？**

**第二个**使用`make`函数的原因和异常安全有关。假设我们有个函数按照某种优先级处理`Widget`：

```c++
void processWidget(std::shared_ptr<Widget> spw, int priority);
```

值传递`std::shared_ptr`可能看起来很可疑，**但是[Item41](https://cntransgroup.github.io/EffectiveModernCppChinese/8.Tweaks/item41.html)解释了，如果`processWidget`总是复制`std::shared_ptr`**（例如，通过将其存储在已处理的`Widget`的一个数据结构中），那么这可能是一个合理的设计选择。

现在假设我们有一个函数来计算相关的优先级，

```c++
int computePriority();
```

并且我们在调用`processWidget`时使用了`new`而不是`std::make_shared`：

```c++
processWidget(std::shared_ptr<Widget>(new Widget),  //潜在的资源泄漏！
              computePriority());
```

如注释所说，这段代码可能在`new`一个`Widget`时发生泄漏。为何？调用的代码和被调用的函数都用`std::shared_ptr`s，且`std::shared_ptr`s就是设计出来防止泄漏的。它们会在最后一个`std::shared_ptr`销毁时自动释放所指向的内存。如果每个人在每个地方都用`std::shared_ptr`s，这段代码怎么会泄漏呢？

**答案和编译器将源码转换为目标代码有关**。在运行时，一个函数的实参必须先被计算，这个函数再被调用，所以在调用`processWidget`之前，必须执行以下操作，`processWidget`才开始执行：

- **表达式“`new Widget`”必须计算，例如，一个`Widget`对象必须在堆上被创建**
- **负责管理`new`出来指针的`std::shared_ptr<Widget>`构造函数必须被执行**
- **`computePriority`必须运行**

编译器不需要按照执行顺序生成代码。“`new Widget`”必须在`std::shared_ptr`的构造函数被调用前执行，因为`new`出来的结果作为构造函数的实参，但`computePriority`可能在这之前，之后，或者**之间**执行。也就是说，编译器可能按照这个执行顺序生成代码：

1. **执行“`new Widget`”**

2. **执行`computePriority`**

3. **运行`std::shared_ptr`构造函数**

   

**如果按照这样生成代码，并且在运行时`computePriority`产生了异常，那么第一步动态分配的`Widget`就会泄漏。因为它永远都不会被第三步的`std::shared_ptr`所管理了。**

使用`std::make_shared`可以防止这种问题。调用代码看起来像是这样：

```c++
processWidget(std::make_shared<Widget>(),   //没有潜在的资源泄漏
              computePriority());
```

在运行时，`std::make_shared`和`computePriority`其中一个会先被调用。如果是`std::make_shared`先被调用，在`computePriority`调用前，动态分配`Widget`的原始指针会安全的保存在作为返回值的`std::shared_ptr`中。如果`computePriority`产生一个异常，那么`std::shared_ptr`析构函数将确保管理的`Widget`被销毁。如果首先调用`computePriority`并产生一个异常，那么`std::make_shared`将不会被调用，因此也就不需要担心动态分配`Widget`（会泄漏）。

如果我们将`std::shared_ptr`，`std::make_shared`替换成`std::unique_ptr`，`std::make_unique`，同样的道理也适用。因此，在编写异常安全代码时，使用`std::make_unique`而不是`new`与使用`std::make_shared`（而不是`new`）同样重要。

**`std::make_shared`的一个特性（与直接使用`new`相比）是效率提升。使用`std::make_shared`允许编译器生成更小，更快的代码，并使用更简洁的数据结构。考虑以下对new的直接使用：**

```c++
std::shared_ptr<Widget> spw(new Widget);
```

**显然，这段代码需要进行内存分配，但它实际上执行了两次。**[Item19](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item19.html)解释了每个`std::shared_ptr`指向一个控制块，其中包含被指向对象的引用计数，还有其他东西。这个控制块的内存在`std::shared_ptr`构造函数中分配。因此，直接使用`new`需要为`Widget`进行一次内存分配，为控制块再进行一次内存分配。

如果使用`std::make_shared`代替：

```c++
auto spw = std::make_shared<Widget>();
```

**一次分配足矣。这是因为`std::make_shared`分配一块内存，同时容纳了`Widget`对象和控制块。**这种优化减少了程序的静态大小，因为代码只包含一个内存分配调用，并且它提高了可执行代码的速度，因为内存只分配一次。此外，使用`std::make_shared`避免了对控制块中的某些簿记信息的需要，潜在地减少了程序的总内存占用。

对于`std::make_shared`的效率分析同样适用于`std::allocate_shared`，因此`std::make_shared`的性能优势也扩展到了该函数。

更倾向于使用`make`函数而不是直接使用`new`的争论非常激烈。尽管它们在软件工程、异常安全和效率方面具有优势，**但本条款的建议是，更倾向于使用`make`函数，而不是完全依赖于它们。**这是因为有些情况下它们**不能或不应该被使用**。

**例如，`make`函数都不允许指定自定义删除器**（见[Item18](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item18.html)和[19](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item19.html)），但是`std::unique_ptr`和`std::shared_ptr`有构造函数这么做。有个`Widget`的自定义删除器：

```c++
auto widgetDeleter = [](Widget* pw) { … };
```

创建一个使用它的智能指针**只能直接使用`new`**：

```c++
std::unique_ptr<Widget, decltype(widgetDeleter)>
    upw(new Widget, widgetDeleter);

std::shared_ptr<Widget> spw(new Widget, widgetDeleter);
```

对于`make`函数，没有办法做同样的事情。



`make`函数第二个限制来自于其实现中的语法细节。[Item7](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item7.html)解释了，当构造函数重载，有使用`std::initializer_list`作为参数的重载形式和不用其作为参数的的重载形式，用花括号创建的对象更倾向于使用`std::initializer_list`作为形参的重载形式，而用小括号创建对象将调用不用`std::initializer_list`作为参数的的重载形式。`make`函数会将它们的参数完美转发给对象构造函数，但是它们是使用小括号还是花括号？对某些类型，问题的答案会很不相同。例如，在这些调用中，

```c++
auto upv = std::make_unique<std::vector<int>>(10, 20);
auto spv = std::make_shared<std::vector<int>>(10, 20);
```

生成的智能指针指向带有10个元素的`std::vector`，每个元素值为20，还是指向带有两个元素的`std::vector`，其中一个元素值10，另一个为20？或者结果是不确定的？

好消息是这并非不确定：两种调用都创建了10个元素，每个值为20的`std::vector`。**这意味着在`make`函数中，完美转发使用小括号，而不是花括号**。**坏消息是如果你想用花括号初始化指向的对象，你必须直接使用`new`**。使用`make`函数会需要能够完美转发花括号初始化的能力，但是，正如[Item30](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item30.html)所说，花括号初始化无法完美转发。但是，[Item30](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item30.html)介绍了一个变通的方法：使用`auto`类型推导从花括号初始化创建`std::initializer_list`对象（见[Item2](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item2.html)），然后将`auto`创建的对象传递给`make`函数。

```c++
//创建std::initializer_list
auto initList = { 10, 20 };
//使用std::initializer_list为形参的构造函数创建std::vector
auto spv = std::make_shared<std::vector<int>>(initList);
```

**对于`std::unique_ptr`，只有这两种情景（自定义删除器和花括号初始化）使用`make`函数有点问题**。



对于`std::shared_ptr`和它的`make`函数，**还有2个问题。都属于边缘情况**，但是一些开发者常碰到，你也可能是其中之一。



一些类重载了`operator new`和`operator delete`。这些函数的存在意味着对这些类型的对象的全局内存分配和释放是不合常规的。设计这种定制操作往往只会精确的分配、释放对象大小的内存。例如，`Widget`类的`operator new`和`operator delete`只会处理`sizeof(Widget)`大小的内存块的分配和释放。这种系列行为不太适用于`std::shared_ptr`对自定义分配（通过`std::allocate_shared`）和释放（通过自定义删除器）的支持，因为`std::allocate_shared`需要的内存总大小不等于动态分配的对象大小，还需要**再加上**控制块大小。**因此，使用`make`函数去创建重载了`operator new`和`operator delete`类的对象是个典型的糟糕想法。**



**与直接使用`new`相比，`std::make_shared`在大小和速度上的优势源于`std::shared_ptr`的控制块与指向的对象放在同一块内存中**。当对象的引用计数降为0，对象被销毁（即析构函数被调用）。**但是，因为控制块和对象被放在同一块分配的内存块中，直到控制块的内存也被销毁，对象占用的内存才被释放。**

正如我说，控制块除了引用计数，还包含簿记信息。引用计数追踪有多少`std::shared_ptr`s指向控制块，**但控制块还有第二个计数，记录多少个`std::weak_ptr`s指向控制块。第二个引用计数就是*weak count*。**（实际上，*weak count*的值不总是等于指向控制块的`std::weak_ptr`的数目，因为库的实现者找到一些方法在*weak count*中添加附加信息，促进更好的代码产生。为了本条款的目的，我们会忽略这一点，假定*weak count*的值等于指向控制块的`std::weak_ptr`的数目。）**当一个`std::weak_ptr`检测它是否过期时（见[Item19](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item19.html)），它会检测指向的控制块中的引用计数（而不是*weak count*）**。如果引用计数是0（即对象没有`std::shared_ptr`再指向它，已经被销毁了），`std::weak_ptr`就已经过期。否则就没过期。

**只要`std::weak_ptr`s引用一个控制块（即*weak count*大于零），该控制块必须继续存在。只要控制块存在，包含它的内存就必须保持分配。通过`std::shared_ptr`的`make`函数分配的内存，直到最后一个`std::shared_ptr`和最后一个指向它的`std::weak_ptr`已被销毁，才会释放。**

如果对象类型非常大，而且销毁最后一个`std::shared_ptr`和销毁最后一个`std::weak_ptr`之间的时间很长，那么在销毁对象和释放它所占用的内存之间可能会出现**延迟**。

```c++
class ReallyBigType { … };

auto pBigObj =                          //通过std::make_shared
    std::make_shared<ReallyBigType>();  //创建一个大对象
                    
…           //创建std::shared_ptrs和std::weak_ptrs
            //指向这个对象，使用它们

…           //最后一个std::shared_ptr在这销毁，
            //但std::weak_ptrs还在

…           //在这个阶段，原来分配给大对象的内存还分配着

…           //最后一个std::weak_ptr在这里销毁；
            //控制块和对象的内存被释放
```

直接只用`new`，一旦最后一个`std::shared_ptr`被销毁，`ReallyBigType`对象的内存就会被释放：

```c++
class ReallyBigType { … };              //和之前一样

std::shared_ptr<ReallyBigType> pBigObj(new ReallyBigType);
                                        //通过new创建大对象

…           //像之前一样，创建std::shared_ptrs和std::weak_ptrs
            //指向这个对象，使用它们
            
…           //最后一个std::shared_ptr在这销毁,
            //但std::weak_ptrs还在；
            //对象的内存被释放

…           //在这阶段，只有控制块的内存仍然保持分配

…           //最后一个std::weak_ptr在这里销毁；
            //控制块内存被释放

```

如果你发现自己处于不可能或不合适使用`std::make_shared`的情况下，你将想要保证自己不受我们之前看到的异常安全问题的影响。最好的方法是确保在直接使用`new`时，在**一个不做其他事情的语句中**，立即将结果传递到智能指针构造函数。这可以防止编译器生成的代码在使用`new`和调用管理`new`出来对象的智能指针的构造函数之间发生异常。

例如，考虑我们前面讨论过的`processWidget`函数，对其非异常安全调用的一个小修改。这一次，我们将指定一个自定义删除器:

```c++
void processWidget(std::shared_ptr<Widget> spw,     //和之前一样
                   int priority);
void cusDel(Widget *ptr);                           //自定义删除器
```

这是非异常安全调用:

```c++
processWidget( 									    //和之前一样，
    std::shared_ptr<Widget>(new Widget, cusDel),    //潜在的内存泄漏！
    computePriority() 
);
```

回想一下：如果`computePriority`在“`new Widget`”之后，而在`std::shared_ptr`构造函数之前调用，并且如果`computePriority`产生一个异常，那么动态分配的`Widget`将会泄漏。

**这里使用自定义删除排除了对`std::make_shared`的使用**，因此避免出现问题的方法是将`Widget`的分配和`std::shared_ptr`的构造放入它们自己的语句中，然后使用得到的`std::shared_ptr`调用`processWidget`。这是该技术的本质，不过，正如我们稍后将看到的，我们可以对其进行调整以提高其性能：

```c++
std::shared_ptr<Widget> spw(new Widget, cusDel);
processWidget(spw, computePriority());  // 正确，但是没优化，见下
```

这是可行的，因为`std::shared_ptr`获取了传递给它的构造函数的原始指针的所有权，即使构造函数产生了一个异常。此例中，如果`spw`的构造函数抛出异常（比如无法为控制块动态分配内存），仍然能够保证`cusDel`会在“`new Widget`”产生的指针上调用。

**一个小小的性能问题是，在非异常安全调用中，我们将一个右值传递给`processWidget`：**

```c++
processWidget(
    std::shared_ptr<Widget>(new Widget, cusDel),    //实参是一个右值
    computePriority()
);
```

**但是在异常安全调用中，我们传递了左值：**

```c++
processWidget(spw, computePriority());              //实参是左值
```

**因为`processWidget`的`std::shared_ptr`形参是传值，从右值构造只需要移动，而传递左值构造需要拷贝。**对`std::shared_ptr`而言，**这种区别是有意义的，因为拷贝`std::shared_ptr`需要对引用计数原子递增，移动则不需要对引用计数有操作。为了使异常安全代码达到非异常安全代码的性能水平，我们需要用`std::move`将`spw`转换为右值**（见[Item23](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item23.html)）：

```c++
processWidget(std::move(spw), computePriority());   //高效且异常安全
```

这很有趣，也值得了解，但通常是无关紧要的，因为您很少有理由不使用`make`函数。除非你有令人信服的理由这样做，否则你应该使用`make`函数。



> **请记住**

- ***和直接使用`new`相比，`make`函数消除了代码重复，提高了异常安全性。对于`std::make_shared`和`std::allocate_shared`，生成的代码更小更快。***
- ***不适合使用`make`函数的情况包括需要指定自定义删除其和希望用花括号初始化。***
- ***对于`std::shared_ptr`，其他不建议使用`make`函数的情况包括***
  - ***有自定义内存管理的类***
  - ***特别关注内存的系统，非常大的对象，以及`std::weak_ptr`比对应的`std::shared_ptr`活得更久***



####	Item 22:当使用Pimpl时，请在实现文件中定义特殊成员函数

如果你曾经与**过多的编译（build）次数**斗争过，你会对**Pimpl（*pointer to implementation*）做法**很熟悉。 凭借这样一种技巧，你可以将类数据成员替换成一个指向包含具体实现的类（或结构体）的指针，并将放在主类（primary class）的数据成员们移动到实现类（implementation class）去，而这些数据成员的访问将通过指针间接访问。 举个例子，假如有一个类`Widget`看起来如下：

```c++
class Widget() {                    //定义在头文件“widget.h”
public:
    Widget();
    …
private:
    std::string name;
    std::vector<double> data;
    Gadget g1, g2, g3;              //Gadget是用户自定义的类型
};
```

因为类`Widget`的数据成员包含有类型`std::string`，`std::vector`和`Gadget`， 定义有这些类型的头文件在类`Widget`编译的时候，必须被包含进来，**这意味着类`Widget`的使用者必须要`#include <string>`，`<vector>`以及`gadget.h`**。 这些头文件将会**增加类`Widget`使用者的编译时间**，**并且让这些使用者依赖于这些头文件（编译依赖性）**。 如果一个头文件的内容变了，类`Widget`使用者也**必须要重新编译**。 标准库文件`<string>`和`<vector>`不是很常变，但是`gadget.h`可能会经常修订。

在C++98中使用Pimpl惯用法，可以把`Widget`的数据成员替换成一个原始指针，指向一个已经被声明过却还未被定义的结构体，如下:

```c++
class Widget                        //仍然在“widget.h”中
{
public:
    Widget();
    ~Widget();                      //析构函数在后面会分析
    …

private:
    struct Impl;                    //声明一个 实现结构体
    Impl *pImpl;                    //以及指向它的指针
};

```

因为类`Widget`不再提到类型`std::string`，`std::vector`以及`Gadget`，`Widget`的使用者不再需要为了这些类型而引入头文件。 这可以**加速编译**，并且意味着，**如果这些头文件中有所变动，`Widget`的使用者不会受到影响**。

一个已经被声明，却还未被实现的类型，被称为**未完成类型**（*incomplete type*）。 `Widget::Impl`就是这种类型。 你能对一个未完成类型做的事很少，但是声明一个指向它的指针是可以的。Pimpl惯用法利用了这一点。

Pimpl惯用法的第一步，是声明一个数据成员，它是个指针，指向一个未完成类型。 第二步是动态分配和回收一个对象，该对象包含那些以前在原来的类中的数据成员。 内存分配和回收的代码都写在实现文件里，比如，对于类`Widget`而言，写在`Widget.cpp`里:

```c++
#include "widget.h"             //以下代码均在实现文件“widget.cpp”里
#include "gadget.h"
#include <string>
#include <vector>

struct Widget::Impl {           //含有之前在Widget中的数据成员的
    std::string name;           //Widget::Impl类型的定义
    std::vector<double> data;
    Gadget g1,g2,g3;
};

Widget::Widget()                //为此Widget对象分配数据成员
: pImpl(new Impl)
{}

Widget::~Widget()               //销毁数据成员
{ delete pImpl; }
```



在这里我把`#include`命令写出来是为了明确一点，**对于`std::string`，`std::vector`和`Gadget`的头文件的整体依赖依然存在**。 **然而，这些依赖从头文件`widget.h`（它被所有`Widget`类的使用者包含，并且对他们可见）移动到了`widget.cpp`****（该文件只被`Widget`类的实现者包含，并只对他可见）**。 我高亮了其中动态分配和回收`Impl`对象的部分。这就是为什么我们需要`Widget`的析构函数——我们需要`Widget`被销毁时回收该对象。

但是，我展示给你们看的是一段C++98的代码，散发着一股已经过去了几千年的腐朽气息。 它使用了原始指针，原始的`new`和原始的`delete`，一切都让它如此的...原始。这一章建立在“智能指针比原始指针更好”的主题上，并且，如果我们想要的只是在类`Widget`的构造函数动态分配`Widget::impl`对象，在`Widget`对象销毁时一并销毁它， `std::unique_ptr`（见[Item18](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item18.html)）是最合适的工具。在头文件中用**`std::unique_ptr`替代原始指针**，就有了头文件中如下代码:

```
class Widget {                      //在“widget.h”中
public:
    Widget();
    …

private:
    struct Impl;
    std::unique_ptr<Impl> pImpl;    //使用智能指针而不是原始指针
};
```

实现文件也可以改成如下：

```c++
#include "widget.h"                 //在“widget.cpp”中
#include "gadget.h"
#include <string>
#include <vector>

struct Widget::Impl {               //跟之前一样
    std::string name;
    std::vector<double> data;
    Gadget g1,g2,g3;
};

Widget::Widget()                    //根据条款21，通过std::make_unique
: pImpl(std::make_unique<Impl>())   //来创建std::unique_ptr
{}
```

你会注意到，`Widget`的析构函数不存在了。这是因为我们没有代码加在里面了。 `std::unique_ptr`在自身析构时，会自动销毁它所指向的对象，所以我们自己无需手动销毁任何东西。这就是智能指针的众多优点之一：它使我们从手动资源释放中解放出来。

以上的代码能编译，但是，最普通的`Widget`用法却会导致**编译出错**：

```c++
#include "widget.h"

Widget w;                           //错误！
```

你所看到的错误信息根据编译器不同会有所不同，但是其文本一般会提到一些有关于“把`sizeof`或`delete`应用到未完成类型上”的信息。对于未完成类型，使用以上操作是禁止的。

在Pimpl惯用法中使用`std::unique_ptr`会抛出错误，有点惊悚，因为第一`std::unique_ptr`宣称它支持未完成类型，第二，Pimpl惯用法是`std::unique_ptr`的最常见的使用情况之一。 幸运的是，让这段代码能正常运行很简单。 只需要对上面出现的问题的原因有一个基础的认识就可以了。

在对象`w`被析构时（例如离开了作用域），问题出现了。在这个时候，它的析构函数被调用。我们在类的定义里使用了`std::unique_ptr`，所以我们没有声明一个析构函数，因为我们并没有任何代码需要写在里面。**根据编译器自动生成的特殊成员函数的规则（见 [Item17](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item17.html)），编译器会自动为我们生成一个析构函数。** **在这个析构函数里，编译器会插入一些代码来调用类`Widget`的数据成员`pImpl`的析构函数。 `pImpl`是一个`std::unique_ptr<Widget::Impl>`，也就是说，一个使用默认删除器的`std::unique_ptr`。** **默认删除器是一个函数，它使用`delete`来销毁内置于`std::unique_ptr`的原始指针。然而，在使用`delete`之前，通常会使默认删除器使用C++11的特性`static_assert`来确保原始指针指向的类型不是一个未完成类型。 当编译器为`Widget w`的析构生成代码时，它会遇到`static_assert`检查并且失败，这通常是错误信息的来源。 这些错误信息只在对象`w`销毁的地方出现，因为类`Widget`的析构函数，正如其他的编译器生成的特殊成员函数一样，是暗含`inline`属性的。 错误信息自身往往指向对象`w`被创建的那行，因为这行代码明确地构造了这个对象，导致了后面潜在的析构。**

为了解决这个问题，**你只需要确保在编译器生成销毁`std::unique_ptr<Widget::Impl>`的代码之前， `Widget::Impl`已经是一个完成类型（*complete type*）**。 当编译器“看到”它的定义的时候，该类型就成为完成类型了。 但是 `Widget::Impl`的定义在`widget.cpp`里。**成功编译的关键，就是在`widget.cpp`文件内，让编译器在“看到” `Widget`的析构函数实现之前（也即编译器插入的，用来销毁`std::unique_ptr`这个数据成员的代码的，那个位置），先定义`Widget::Impl`。**

做出这样的调整很容易。只需要先在`widget.h`里，只声明类`Widget`的析构函数，但不要在这里定义它：

```c++
class Widget {                  //跟之前一样，在“widget.h”中
public:
    Widget();
    ~Widget();                  //只有声明语句
    …

private:                        //跟之前一样
    struct Impl;
    std::unique_ptr<Impl> pImpl;
};

```

在`widget.cpp`文件中，在结构体`Widget::Impl`被定义之后，再定义析构函数：

```c++
#include "widget.h"                 //跟之前一样，在“widget.cpp”中
#include "gadget.h"
#include <string>
#include <vector>

struct Widget::Impl {               //跟之前一样，定义Widget::Impl
    std::string name;
    std::vector<double> data;
    Gadget g1,g2,g3;
}

Widget::Widget()                    //跟之前一样
: pImpl(std::make_unique<Impl>())
{}

Widget::~Widget()                   //析构函数的定义   此时,它能看到Impl的实现
{}

```

这样就可以了，并且这样增加的代码也最少，你声明`Widget`析构函数只是为了在 Widget 的实现文件中（译者注：指`widget.cpp`）写出它的定义，但是如果你想强调编译器自动生成的析构函数会做和你一样正确的事情，你可以直接使用“`= default`”定义析构函数体

```c++
Widget::~Widget() = default;        //同上述代码效果一致
```

使用了Pimpl惯用法的类自然适合支持移动操作，因为编译器自动生成的移动操作正合我们所意：对其中的`std::unique_ptr`进行移动。 **正如[Item17](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item17.html)所解释的那样，声明一个类`Widget`的析构函数会阻止编译器生成移动操作，所以如果你想要支持移动操作，你必须自己声明相关的函数。**考虑到编译器自动生成的版本会正常运行，你可能会很想按如下方式实现它们：

```c++
class Widget {                                  //仍然在“widget.h”中
public:
    Widget();
    ~Widget();

    Widget(Widget&& rhs) = default;             //思路正确，
    Widget& operator=(Widget&& rhs) = default;  //但代码错误
    …

private:                                        //跟之前一样
    struct Impl;
    std::unique_ptr<Impl> pImpl;
};
```

**这样的做法会导致同样的错误**，和之前的声明一个不带析构函数的类的错误一样，**并且是因为同样的原因**。 **编译器生成的移动赋值操作符，在重新赋值之前，需要先销毁指针`pImpl`指向的对象。然而在`Widget`的头文件里，`pImpl`指针指向的是一个未完成类型**。移动构造函数的情况有所不同。 移动构造函数的问题是编译器自动生成的代码里，包含有抛出异常的事件，在这个事件里会生成销毁`pImpl`的代码。然而，销毁`pImpl`需要`Impl`是一个完成类型。

因为这个问题同上面一致，所以解决方案也一样——把移动操作的定义移动到实现文件里：

```c++
class Widget {                          //仍然在“widget.h”中
public:
    Widget();
    ~Widget();

    Widget(Widget&& rhs);               //只有声明
    Widget& operator=(Widget&& rhs);
    …

private:                                //跟之前一样
    struct Impl;
    std::unique_ptr<Impl> pImpl;
};
```

```c++
#include <string>                   //跟之前一样，仍然在“widget.cpp”中
…
    
struct Widget::Impl { … };          //跟之前一样

Widget::Widget()                    //跟之前一样
: pImpl(std::make_unique<Impl>())
{}

Widget::~Widget() = default;        //跟之前一样

Widget::Widget(Widget&& rhs) = default;             //这里定义
Widget& Widget::operator=(Widget&& rhs) = default;

```

**Pimpl惯用法是用来减少类的实现和类使用者之间的编译依赖的一种方法**，但是，从概念而言，使用这种惯用法并不改变这个类的表现。 原来的类`Widget`包含有`std::string`，`std::vector`和`Gadget`数据成员，并且，假设类型`Gadget`，如同`std::string`和`std::vector`一样，允许复制操作，所以类`Widget`支持复制操作也很合理。 我们必须要自己来写这些函数，因为第一，**对包含有只可移动（*move-only*）类型，如`std::unique_ptr`的类，编译器不会生成复制操作；**第二，**即使编译器帮我们生成了，生成的复制操作也只会复制`std::unique_ptr`（也即浅拷贝（*shallow copy*）），而实际上我们需要复制指针所指向的对象（也即深拷贝（*deep copy*））**。

使用我们已经熟悉的方法，我们在头文件里声明函数，而在实现文件里去实现他们:

```c++
class Widget {                          //仍然在“widget.h”中
public:
    …

    Widget(const Widget& rhs);          //只有声明
    Widget& operator=(const Widget& rhs);

private:                                //跟之前一样
    struct Impl;
    std::unique_ptr<Impl> pImpl;
};
```

```c++
#include <string>                   //跟之前一样，仍然在“widget.cpp”中
…
    
struct Widget::Impl { … };          //跟之前一样

Widget::~Widget() = default;		//其他函数，跟之前一样

Widget::Widget(const Widget& rhs)   //拷贝构造函数
: pImpl(std::make_unique<Impl>(*rhs.pImpl))
{}

Widget& Widget::operator=(const Widget& rhs)    //拷贝operator=
{
    *pImpl = *rhs.pImpl;
    return *this;
}
```

两个函数的实现都比较中规中矩。 在每个情况中，我们都只从源对象（`rhs`）中，复制了结构体`Impl`的内容到目标对象中（`*this`）。**我们利用了编译器会为我们自动生成结构体`Impl`的复制操作函数的机制，而不是逐一复制结构体`Impl`的成员，自动生成的复制操作能自动复制每一个成员**。 因此我们通过调用编译器生成的`Widget::Impl`的复制操作函数来实现了类`Widget`的复制操作。 在复制构造函数中，注意，我们仍然遵从了[Item21](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item21.html)的建议，使用`std::make_unique`而非直接使用`new`。

为了实现Pimpl惯用法，`std::unique_ptr`是我们使用的智能指针，因为位于对象内部的`pImpl`指针（例如，在类`Widget`内部），对所指向的对应实现的对象的享有独占所有权。**然而，有趣的是，如果我们使用`std::shared_ptr`而不是`std::unique_ptr`来做`pImpl`指针， 我们会发现本条款的建议不再适用。 我们不需要在类`Widget`里声明析构函数，没有了用户定义析构函数，编译器将会愉快地生成移动操作，并且将会如我们所期望般工作。**`widget.h`里的代码如下，

```c++
class Widget {                      //在“widget.h”中
public:
    Widget();
    …                               //没有析构函数和移动操作的声明

private:
    struct Impl;
    std::shared_ptr<Impl> pImpl;    //用std::shared_ptr
};                                  //而不是std::unique_ptr

```

这是`#include`了`widget.h`的客户代码，

```c++
Widget w1;
auto w2(std::move(w1));     //移动构造w2
w1 = std::move(w2);         //移动赋值w1
```

这些都能编译，并且工作地如我们所望：`w1`将会被默认构造，它的值会被移动进`w2`，随后值将会被移动回`w1`，然后两者都会被销毁（因此导致指向的`Widget::Impl`对象一并也被销毁）。

**`std::unique_ptr`和`std::shared_ptr`在`pImpl`指针上的表现上的区别的深层原因在于，他们支持自定义删除器的方式不同。** **对`std::unique_ptr`而言，删除器的类型是这个智能指针的一部分**，这让编译器有可能生成更小的运行时数据结构和更快的运行代码。 **这种更高效率的后果之一就是`std::unique_ptr`指向的类型，在编译器的生成特殊成员函数（如析构函数，移动操作）被调用时，必须已经是一个完成类型**。 而对`std::shared_ptr`而言，删除器的类型不是该智能指针的一部分，这让它会生成更大的运行时数据结构和稍微慢点的代码，但是当编译器生成的特殊成员函数被使用的时候，指向的对象不必是一个完成类型。（**译者注：知道`std::unique_ptr`和`std::shared_ptr`的实现，这一段才比较容易理解。**）

对于Pimpl惯用法而言，在`std::unique_ptr`和`std::shared_ptr`的特性之间，没有一个比较好的折中。 因为对于像`Widget`的类以及像`Widget::Impl`的类之间的关系而言，他们是独享占有权关系，这让`std::unique_ptr`使用起来很合适。 然而，有必要知道，在其他情况中，当共享所有权存在时，`std::shared_ptr`是很适用的选择的时候，就没有`std::unique_ptr`所必需的声明——定义（function-definition）这样的麻烦事了。



> **请记住:**

- ***`Pimpl`手法通过减少在类实现和类使用者之间的编译依赖来减少编译时间***
- ***对于`std::unique_ptr`类型的`pImpl`指针，需要在头文件的类里声明特殊的成员函数，但是在实现文件里面来实现它们。即使是编译器自动生成的代码可以正常工作，也要这么做***
- ***以上建议只适用于`std::unique_ptr`，不适用于`std::shared_ptr`***



##	5. 右值引用，移动语义，完美转发

当你第一次了解到移动语义（*move semantics*）和完美转发（*perfect forwarding*）的时候，它们看起来非常直观：

- **移动语义**使编译器有可能用廉价的移动操作来代替昂贵的拷贝操作。正如拷贝构造函数和拷贝赋值操作符给了你控制拷贝语义的权力，移动构造函数和移动赋值操作符也给了你控制移动语义的权力。移动语义也允许创建只可移动（*move-only*）的类型，例如`std::unique_ptr`，`std::future`和`std::thread`。
- **完美转发**使接收任意数量实参的函数模板成为可能，它可以将实参转发到其他的函数，使目标函数接收到的实参与被传递给转发函数的实参保持一致。

**右值引用**是连接这两个截然不同的概念的胶合剂。它是使移动语义和完美转发变得可能的基础语言机制。

你对这些特点越熟悉，你就越会发现，你的初印象只不过是冰山一角。移动语义、完美转发和右值引用的世界比它所呈现的更加微妙。举个例子，**`std::move`并不移动任何东西，完美转发也并不完美。移动操作并不永远比复制操作更廉价**；即便如此，它也并不总是像你期望的那么廉价。而且，它也并不总是被调用，即使在当移动操作可用的时候。构造“`type&&`”也并非总是代表一个右值引用。

无论你挖掘这些特性有多深，它们看起来总是还有更多隐藏起来的部分。幸运的是，它们的深度总是有限的。本章将会带你到最基础的部分。一旦到达，C++11的这部分特性将会具有非常大的意义。比如，你会掌握`std::move`和`std::forward`的惯用法。你能够适应“`type&&`”的歧义性质。你会理解移动操作的令人惊奇的不同表现的背后真相。这些片段都会豁然开朗。在这一点上，你会重新回到一开始的状态，因为移动语义、完美转发和右值引用都会又一次显得直截了当。但是这一次，它们不再使人困惑。

在本章的这些小节中，非常重要的一点是要牢记形参永远是**左值**，即使它的类型是一个右值引用。比如，假设

```c++
void f(Widget&& w);
```

形参`w`是一个左值，即使它的类型是一个rvalue-reference-to-`Widget`。



####	Item:理解std::move和std::forward

为了了解`std::move`和`std::forward`，一种有用的方式是从**它们不做什么**这个角度来了解它们。**`std::move`不移动（move）任何东西，`std::forward`也不转发（forward）任何东西。在运行时，它们不做任何事情。它们不产生任何可执行代码，一字节也没有。**

**`std::move`和`std::forward`仅仅是执行转换（cast）的函数（事实上是函数模板）。`std::move`无条件的将它的实参转换为右值，而`std::forward`只在特定情况满足时下进行转换。**它们就是如此。这样的解释带来了一些新的问题，但是从根本上而言，这就是全部内容。

为了使这个故事更加的具体，这里是一个C++11的`std::move`的示例实现。它并不完全满足标准细则，但是它已经非常接近了：

```c++
template<typename T>                            //在std命名空间
typename remove_reference<T>::type&&
move(T&& param)
{
    using ReturnType =                          //别名声明，见条款9
        typename remove_reference<T>::type&&;

    return static_cast<ReturnType>(param);
}
```

正如你所见，`std::move`接受一个对象的引用（准确的说，一个通用引用（universal reference），见[Item24](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item24.html))，返回一个指向同对象的引用。

该函数返回类型的`&&`部分表明`std::move`函数返回的是一个右值引用，但是，正如[Item28](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item28.html)所解释的那样，如果类型`T`恰好是一个左值引用，那么`T&&`将会成为一个左值引用。为了避免如此，*type trait*（见[Item9](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item9.html)）`std::remove_reference`应用到了类型`T`上，**因此确保了`&&`被正确的应用到了一个不是引用的类型上**。这保证了`std::move`返回的真的是右值引用，这很重要，因为函数返回的右值引用是右值。因此，`std::move`将它的实参转换为一个右值，这就是它的全部作用。

此外，`std::move`在C++14中可以被更简单地实现。多亏了函数返回值类型推导（见[Item3](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item3.html)）和标准库的**模板别名`std::remove_reference_t`**（见[Item9](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item9.html)），`std::move`可以这样写：

```c++
template<typename T>
decltype(auto) move(T&& param)          //C++14，仍然在std命名空间
{
    using ReturnType = remove_referece_t<T>&&;
    return static_cast<ReturnType>(param);
}
```

看起来更简单，不是吗？

**因为`std::move`除了转换它的实参到右值以外什么也不做，有一些提议说它的名字叫`rvalue_cast`之类可能会更好**。虽然可能确实是这样，但是它的名字已经是`std::move`，所以记住`std::move`做什么和不做什么很重要。它只进行转换，不移动任何东西。

当然，右值本来就是移动操作的候选者，所以对一个对象使用`std::move`就是告诉编译器，这个对象很适合被移动。所以这就是为什么`std::move`叫现在的名字：更容易指定可以被移动的对象。

事实上，右值只不过**经常**是移动操作的候选者。假设你有一个类，它用来表示一段注解。这个类的构造函数接受一个包含有注解的`std::string`作为形参，然后它复制该形参到数据成员。假设你了解[Item41](https://cntransgroup.github.io/EffectiveModernCppChinese/8.Tweaks/item41.html)，你声明一个值传递的形参：

```c++
class Annotation {
public:
    explicit Annotation(std::string text);  //将会被复制的形参，
    …                                       //如同条款41所说，
};                                          //值传递

```

但是`Annotation`类的构造函数仅仅是需要读取`text`的值，它并不需要修改它。为了和历史悠久的传统：能使用`const`就使用`const`保持一致，你修订了你的声明以使`text`变成`const`：

```c++
class Annotation {
public:
    explicit Annotation(const std::string text);
    …
};

```

当复制`text`到一个数据成员的时候，为了避免一次复制操作的代价，你仍然记得来自[Item41](https://cntransgroup.github.io/EffectiveModernCppChinese/8.Tweaks/item41.html)的建议，把`std::move`应用到`text`上，因此产生一个右值：

```c++
class Annotation {
public:
    explicit Annotation(const std::string text)
    ：value(std::move(text))    //“移动”text到value里；这段代码执行起来
    { … }                       //并不是看起来那样
    
    …

private:
    std::string value;
};
```

这段代码可以编译，可以链接，可以运行。这段代码将数据成员`value`设置为`text`的值。这段代码与你期望中的完美实现的唯一区别，是`text`并不是被移动到`value`，而是被**拷贝**。诚然，`text`通过`std::move`被转换到右值，但是`text`被声明为`const std::string`，所以在转换之前，`text`是一个左值的`const std::string`，而转换的结果是一个右值的`const std::string`，**但是纵观全程，`const`属性一直保留**。

当编译器决定哪一个`std::string`的构造函数被调用时，考虑它的作用，将会有两种可能性：

```c++
class string {                  //std::string事实上是
public:                         //std::basic_string<char>的类型别名
    …
    string(const string& rhs);  //拷贝构造函数
    string(string&& rhs);       //移动构造函数
    …
};
```

在类`Annotation`的构造函数的成员初始化列表中，`std::move(text)`的结果是一个`const std::string`的右值。这个右值不能被传递给`std::string`的移动构造函数，因为移动构造函数只接受一个指向**non-`const`\**的`std::string`的右值引用。然而，该右值却可以被传递给`std::string`的拷贝构造函数，因为lvalue-reference-to-`const`允许被绑定到一个`const`右值上。因此，`std::string`在成员初始化的过程中调用了\**拷贝**构造函数，即使`text`已经被转换成了右值。这样是为了确保维持`const`属性的正确性。从一个对象中移动出某个值通常代表着修改该对象，所以语言不允许`const`对象被传递给可以修改他们的函数（例如移动构造函数）。

从这个例子中，可以总结出两点。

**第一，不要在你希望能移动对象的时候，声明他们为`const`。对`const`对象的移动请求会悄无声息的被转化为拷贝操作。**

**第二点，`std::move`不仅不移动任何东西，而且它也不保证它执行转换的对象可以被移动。关于`std::move`，你能确保的唯一一件事就是将它应用到一个对象上，你能够得到一个右值。**

关于`std::forward`的故事与`std::move`是相似的，但是与`std::move`总是**无条件**的将它的实参为右值不同，`std::forward`只有在满足一定条件的情况下才执行转换。`std::forward`是**有条件**的转换。要明白什么时候它执行转换，什么时候不，想想`std::forward`的典型用法。最常见的情景是一个模板函数，接收一个通用引用形参，并将它传递给另外的函数：

```c++
void process(const Widget& lvalArg);        //处理左值
void process(Widget&& rvalArg);             //处理右值

template<typename T>                        //用以转发param到process的模板
void logAndProcess(T&& param)
{
    auto now =                              //获取现在时间
        std::chrono::system_clock::now();
    
    makeLogEntry("Calling 'process'", now);
    process(std::forward<T>(param));
}
```

考虑两次对`logAndProcess`的调用，一次左值为实参，一次右值为实参：

```c++
Widget w;

logAndProcess(w);               //用左值调用
logAndProcess(std::move(w));    //用右值调用
```

在`logAndProcess`函数的内部，形参`param`被传递给函数`process`。函数`process`分别对左值和右值做了重载。当我们使用左值来调用`logAndProcess`时，自然我们期望该左值被当作左值转发给`process`函数，而当我们使用右值来调用`logAndProcess`函数时，我们期望`process`函数的右值重载版本被调用。

**但是`param`，正如所有的其他函数形参一样，是一个左值。每次在函数`logAndProcess`内部对函数`process`的调用，都会因此调用函数`process`的左值重载版本**。为防如此，我们需要一种机制：当且仅当传递给函数`logAndProcess`的用以初始化`param`的实参是一个右值时，`param`会被转换为一个右值。这就是`std::forward`做的事情。这就是为什么`std::forward`是一个**有条件**的转换：**它的实参用右值初始化时，转换为一个右值。**

你也许会想知道`std::forward`是怎么知道它的实参是否是被一个右值初始化的。举个例子，在上述代码中，`std::forward`是怎么分辨`param`是被一个左值还是右值初始化的？ 简短的说，该信息藏在函数`logAndProcess`的模板参数`T`中。该参数被传递给了函数`std::forward`，它解开了含在其中的信息。该机制工作的细节可以查询[Item28](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item28.html)。

**考虑到`std::move`和`std::forward`都可以归结于转换，它们唯一的区别就是`std::move`总是执行转换，而`std::forward`偶尔为之。**你可能会问是否我们可以免于使用`std::move`而在任何地方只使用`std::forward`。 从纯技术的角度，答案是yes：`std::forward`是可以完全胜任，`std::move`并非必须。当然，其实两者中没有哪一个函数是**真的必须**的，因为我们可以到处直接写转换代码，但是我希望我们能同意：这将相当的，嗯，让人恶心。

**`std::move`的吸引力在于它的便利性：减少了出错的可能性，增加了代码的清晰程度**。考虑一个类，我们希望统计有多少次移动构造函数被调用了。我们只需要一个`static`的计数器，它会在移动构造的时候自增。假设在这个类中，唯一一个非静态的数据成员是`std::string`，一种经典的移动构造函数（即，使用`std::move`）可以被实现如下：

```c++
class Widget {
public:
    Widget(Widget&& rhs)
    : s(std::move(rhs.s))
    { ++moveCtorCalls; }

    …

private:
    static std::size_t moveCtorCalls;
    std::string s;
};

```

如果要用`std::forward`来达成同样的效果，代码可能会看起来像：

```c++
class Widget{
public:
    Widget(Widget&& rhs)                    //不自然，不合理的实现
    : s(std::forward<std::string>(rhs.s))
    { ++moveCtorCalls; }

    …

}
```

注意，

第一，`std::move`只需要一个函数实参（`rhs.s`），而`std::forward`不但需要一个函数实参（`rhs.s`），还需要一个**模板类型实参`std::string`**。

其次，我们传递给`std::forward`的类型应当是一个non-reference，因为只有传递的实参是一个非左值引用，`std::forward`才能表示为右值。同样，这意味着`std::move`比起`std::forward`来说需要打更少的字，并且免去了传递一个表示我们正在传递一个右值的类型实参。同样，它根绝了我们传递错误类型的可能性（例如，`std::string&`可能导致数据成员`s`被复制而不是被移动构造）。



**更重要的是，`std::move`的使用代表着无条件向右值的转换，而使用`std::forward`只对绑定了右值的引用进行到右值转换**。**这是两种完全不同的动作。前者是典型地为了移动操作，而后者只是传递（亦为转发）一个对象到另外一个函数，保留它原有的左值属性或右值属性。因为这些动作实在是差异太大，所以我们拥有两个不同的函数（以及函数名）来区分这些动作。**



> **请记住:**

- ***`std::move`执行到右值的无条件的无条件的转换，但就自身而言，它不移动任何东西***
- ***`std::forward`只有当它的参数被绑定到一个右值时，才将参数转换为右值***
- ***`std::move`和`std::forward`在运行期什么也不做***



####	Item 24:区别通用引用和右值引用

据说，真相使人自由，然而在特定的环境下，一个精心挑选的谎言也同样使人解放。这一条款就是这样一个谎言。因为我们在和软件打交道，然而，让我们避开“谎言（lie）”这个词，不妨说，本条款包含了一种“抽象（abstraction）”。

为了声明一个指向某个类型`T`的右值引用，你写下了`T&&`。由此，一个合理的假设是，当你看到一个“`T&&`”出现在源码中，你看到的是一个右值引用。唉，事情并不如此简单（primer中的引用的例外）:

```c++
void f(Widget&& param);             //右值引用
Widget&& var1 = Widget();           //右值引用
auto&& var2 = var1;                 //不是右值引用

template<typename T>
void f(std::vector<T>&& param);     //右值引用

template<typename T>
void f(T&& param);                  //不是右值引用
```

事实上，“`T&&`”有两种不同的意思。第一种，当然是右值引用。这种引用表现得正如你所期待的那样：它们只绑定到右值上，**并且它们主要的存在原因就是为了识别可以移动操作的对象**。

“`T&&`”的另一种意思是，它既可以是右值引用，也可以是左值引用。这种引用在源码里看起来像右值引用（即“`T&&`”），但是它们可以表现得像是左值引用（即“`T&`”）。它们的二重性使它们既可以绑定到右值上（就像右值引用），也可以绑定到左值上（就像左值引用）。 此外，它们还可以绑定到`const`或者non-`const`的对象上，也可以绑定到`volatile`或者non-`volatile`的对象上，甚至可以绑定到既`const`又`volatile`的对象上。它们可以绑定到几乎任何东西。这种空前灵活的引用值得拥有自己的名字。我把它叫做**通用引用**（*universal references*）。（[Item25](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item25.html)解释了`std::forward`几乎总是可以应用到通用引用上，并且在这本书即将出版之际，一些C++社区的成员已经开始将这种通用引用称之为**转发引用**（*forwarding references*））。

**在两种情况下会出现通用引用**。



最常见的一种是**函数模板形参**，正如在之前的示例代码中所出现的例子：

```c++
template<typename T>
void f(T&& param);                  //param是一个通用引用
```

第二种情况是`auto`声明符，它是从以上示例中拿出的：

```c++
auto&& var2 = var1;                 //var2是一个通用引用
```

这两种情况的共同之处就是都存在**类型推导**（*type deduction*）。在模板`f`的内部，`param`的类型需要被推导，而在变量`var2`的声明中，`var2`的类型也需要被推导。同以下的例子相比较（同样来自于上面的示例代码），下面的例子不带有类型推导。如果你看见“`T&&`”不带有类型推导，那么你看到的就是一个右值引用：

```c++
void f(Widget&& param);         //没有类型推导，
                                //param是一个右值引用
Widget&& var1 = Widget();       //没有类型推导，
                                //var1是一个右值引用
```



因为通用引用是引用，所以它们必须被初始化。一个通用引用的初始值决定了它是代表了右值引用还是左值引用。如果初始值是一个右值，那么通用引用就会是对应的右值引用，如果初始值是一个左值，那么通用引用就会是一个左值引用。对那些是函数形参的通用引用来说，初始值在调用函数的时候被提供：

```c++
template<typename T>
void f(T&& param);              //param是一个通用引用

Widget w;
f(w);                           //传递给函数f一个左值；param的类型
                                //将会是Widget&，也即左值引用

f(std::move(w));                //传递给f一个右值；param的类型会是
                                //Widget&&，即右值引用
```

**对一个通用引用而言，类型推导是必要的**，但是它还不够。引用声明的**形式**必须正确，并且该形式是被限制的。它必须恰好为“`T&&`”。再看看之前我们已经看过的代码示例：

```c++
template <typename T>
void f(std::vector<T>&& param);     //param是一个右值引用
```

当函数`f`被调用的时候，类型`T`会被推导（除非调用者显式地指定它，这种边缘情况我们不考虑）。但是`param`的类型声明并不是`T&&`，而是一个`std::vector<T>&&`。这排除了`param`是一个通用引用的可能性。`param`因此是一个右值引用——当你向函数`f`传递一个左值时，你的编译器将会乐于帮你确认这一点:

```c++
std::vector<int> v;
f(v);                           //错误！不能将左值绑定到右值引用
```

**即使一个简单的`const`修饰符的出现**，也足以使一个引用失去成为通用引用的资格:

```c++
template <typename T>
void f(const T&& param);        //param是一个右值引用
```

如果你在一个模板里面看见了一个函数形参类型为“`T&&`”，你也许觉得你可以假定它是一个通用引用。错！这是由于在模板内部并不保证一定会发生类型推导。考虑如下`push_back`成员函数，来自`std::vector`：

```c++
template<class T, class Allocator = allocator<T>>   //来自C++标准
class vector
{
public:
    void push_back(T&& x);
    …
}
```

`push_back`函数的形参当然有一个通用引用的正确形式，然而，在这里并没有发生类型推导。因为`push_back`在有一个特定的`vector`实例之前不可能存在，而实例化`vector`时的类型已经决定了`push_back`的声明。也就是说，

```c++
std::vector<Widget> v;
```

将会导致`std::vector`模板被实例化为以下代码：

```c++
class vector<Widget, allocator<Widget>> {
public:
    void push_back(Widget&& x);             //右值引用
    …
};
```

现在你可以清楚地看到，函数`push_back`不包含任何类型推导。`push_back`对于`vector<T>`而言（有两个函数——它被重载了）总是声明了一个类型为rvalue-reference-to-`T`的形参。

作为对比，`std::vector`内的概念上相似的成员函数`emplace_back`，却确实包含类型推导:

```c++
template<class T, class Allocator = allocator<T>>   //依旧来自C++标准
class vector {
public:
    template <class... Args>
    void emplace_back(Args&&... args);
    …
};
```

这儿，类型参数（*type parameter*）`Args`是独立于`vector`的类型参数`T`的，所以`Args`会在每次`emplace_back`被调用的时候被推导。（好吧，`Args`实际上是一个[*parameter pack*](https://en.cppreference.com/w/cpp/language/parameter_pack)，而不是一个类型参数，但是为了方便讨论，我们可以把它当作是一个类型参数。）

虽然函数`emplace_back`的类型参数被命名为`Args`，但是它仍然是一个通用引用，这补充了我之前所说的，**通用引用的格式必须是“`T&&`”。你使用的名字`T`并不是必要的**。举个例子，如下模板接受一个通用引用，因为形式（“`type&&`”）是正确的，并且`param`的类型将会被推导（重复一次，不考虑边缘情况，即当调用者明确给定类型的时候）。

```c++
template<typename MyTemplateType>           //param是通用引用
void someFunc(MyTemplateType&& param);
```

我之前提到，类型为`auto`的变量可以是通用引用。更准确地说，**类型声明为`auto&&`的变量是通用引用，因为会发生类型推导，并且它们具有正确形式(`T&&`)**。`auto`类型的通用引用不如函数模板形参中的通用引用常见，但是它们在C++11中常常突然出现。**而它们在C++14中出现得更多，因为C++14的*lambda*表达式可以声明`auto&&`类型的形参**。举个例子，如果你想写一个C++14标准的*lambda*表达式，来记录任意函数调用的时间开销，你可以这样写：

```c++
auto timeFuncInvocation =
    [](auto&& func, auto&&... params)           //C++14
    {
        start timer;
        std::forward<decltype(func)>(func)(     //对params调用func
            std::forward<delctype(params)>(params)...
        );
        stop timer and record elapsed time;
    };

```

如果你对*lambda*里的代码“`std::forward<decltype(blah blah blah)>`”反应是“这是什么鬼...?!”，只能说你可能还没有读[Item33](https://cntransgroup.github.io/EffectiveModernCppChinese/6.LambdaExpressions/item33.html)。别担心。在本条款，重要的事是*lambda*表达式中声明的`auto&&`类型的形参。`func`是一个通用引用，可以被绑定到任何可调用对象，无论左值还是右值。`args`是0个或者多个通用引用（即它是个**通用引用*parameter pack***），它可以绑定到任意数目、任意类型的对象上。多亏了`auto`类型的通用引用，函数`timeFuncInvocation`可以对**近乎任意**（pretty much any）函数进行计时。(如果你想知道任意（any）和近乎任意（pretty much any）的区别，往后翻到[Item30](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item30.html))。

牢记整个本条款——通用引用的基础——是一个谎言，噢不，是一个“抽象”。其底层真相被称为**引用折叠（*reference collapsing*）**，[Item28](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item28.html)的专题将致力于讨论它。但是这个真相并不降低该抽象的有用程度。区分右值引用和通用引用将会帮助你更准确地阅读代码（“究竟我眼前的这个`T&&`是只绑定到右值还是可以绑定任意对象呢？”），并且，当你在和你的合作者交流时，它会帮助你避免歧义（“在这里我在用一个通用引用，而非右值引用”）。它也可以帮助你弄懂[Item25](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item25.html)和[26](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item26.html)，它们依赖于右值引用和通用引用的区别。所以，拥抱这份抽象，陶醉于它吧。就像牛顿的力学定律（本质上不正确），比起爱因斯坦的广义相对论（这是真相）而言，往往更简单，更易用。所以通用引用的概念，相较于穷究引用折叠的细节而言，是更合意之选。

> **请记住**

- ***如果一个函数模板形参的类型为`T&&`，并且`T`需要被推导得知，或者如果一个对象被声明为`auto&&`，这个形参或者对象就是一个通用引用***
- ***如果类型声明的形式不是标准的`type&&`，或者如果类型推导没有发生，那么`type`就代表一个右值引用***
- ***通用引用，如果它被右值初始化，就会对应地右值引用；如果它被左值初始化，就会成为左值引用***



####	Item 25:对右值引用使用std::move，对通用引用使用std::forward

右值引用仅绑定可以移动的对象。如果你有一个右值引用形参就知道这个对象可能会被移动：

```c++
class Widget {
    Widget(Widget&& rhs);       //rhs定义上引用一个有资格移动的对象
    …
};
```

在这种情况下，你希望给其他函数传递对象时，允许那些函数利用对象地右值。方法就是将绑定到这些对象的参数转换为右值。正如前面所提到的，std::move不仅仅能干这个，也是为了这个而创造的

```c++
class Widget {
public:
    Widget(Widget&& rhs)        //rhs是右值引用
    : name(std::move(rhs.name)),
      p(std::move(rhs.p))
      { … }
    …
private:
    std::string name;
    std::shared_ptr<SomeDataStructure> p;
};
```

另一方面（查看[Item24](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item24.html)），**通用引用**可能绑定到有资格移动的对象上。**通用引用使用右值初始化时，才将其强制转换为右值**。[Item23](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item23.html)阐释了这正是`std::forward`所做的：

```c++
class Widget {
public:
    template<typename T>
    void setName(T&& newName)           //newName是通用引用
    { name = std::forward<T>(newName); }

    …
};
```

简而言之，**在转发给其他函数时，右值引用应该无条件地转换为右值（通过std::move）**，因为它们总是绑定到右值，而**通用引用应该有条件地转换为右值（通过std::forward）**，因为它们只是有时绑定到右值

前面有提到，对右值引用使用`std::forward`也是可以的，但是代码太长，易出错并且不符合语言习惯。因此，应该避免对右值引用使用`std::forward`。

更糟糕的想法是对通用引用使用`std::move`，因为存在意外修改左值的问题：

```c++
class Widget {
public:
    template<typename T>
    void setName(T&& newName)       //通用引用可以编译，
    { name = std::move(newName); }  //但是代码太太太差了！
    …

private:
    std::string name;
    std::shared_ptr<SomeDataStructure> p;
};

std::string getWidgetName();        //工厂函数

Widget w;

auto n = getWidgetName();           //n是局部变量

w.setName(n);                       //把n移动进w！	n是左值！

…                                   //现在n的值未知  对n的操作都将是未定义行为
```

上面的例子，局部变量`n`被传递给`w.setName`，调用方可能认为这是对`n`的只读操作——这一点倒是可以被原谅。**但是因为`setName`内部使用`std::move`无条件将传递的引用形参转换为右值，`n`的值被移动进`w.name`**，**移动操作将把n内部的指针全部置为nullptr等**，调用`setName`返回时`n`最终变为未定义的值。这种行为使得调用者蒙圈了——还有可能变得狂躁。

你可能争辩说`setName`不应该将其形参声明为通用引用。此类引用不能使用`const`（见[Item24](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item24.html)），但是`setName`肯定不应该修改其形参。你可能会指出，如果为`const`左值和为右值分别重载`setName`可以避免整个问题，比如这样：

```c++
class Widget {
public:
    // 此时不是函数模板
    void setName(const std::string& newName)    //用const左值设置
    { name = newName; }
    
    void setName(std::string&& newName)         //用右值设置
    { name = std::move(newName); }
    
    …
};
```

这样的话，当然可以工作，但是有缺点。**首先编写和维护的代码更多（两个函数而不是单个模板）；其次，效率下降**。比如，考虑如下场景：

```c++
w.setName("Adela Novak");
```

使用通用引用的版本的`setName`，字面字符串“`Adela Novak`”可以被传递给`setName`，再传给`w`内部`std::string`的赋值运算符。`w`的`name`的数据成员通过字面字符串直接赋值，没有临时`std::string`对象被创建。但是，**`setName`重载版本，会有一个临时`std::string`对象被创建，`setName`形参绑定到这个对象**，然后这个临时`std::string`移动到`w`的数据成员中。一次`setName`的调用会包括`std::string`构造函数调用（创建中间对象），`std::string`赋值运算符调用（移动`newName`到`w.name`），`std::string`析构函数调用（析构中间对象）。这比调用接受`const char*`指针的`std::string`赋值运算符开销昂贵许多。增加的开销根据实现不同而不同，这些开销是否值得担心也跟应用和库的不同而有所不同，但是事实上，将通用引用模板替换成对左值引用和右值引用的一对函数重载在某些情况下会导致运行时的开销。如果把例子泛化，`Widget`数据成员是任意类型（而不是知道是个`std::string`），性能差距可能会变得更大，因为不是所有类型的移动操作都像`std::string`开销较小（参看[Item29](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item29.html)）。

**但是，关于对左值和右值的重载函数最重要的问题不是源代码的数量，也不是代码的运行时性能。而是设计的可扩展性差**。`Widget::setName`有一个形参，因此需要两种重载实现，但是对于有更多形参的函数，每个都可能是左值或右值，重载函数的数量几何式增长：n个参数的话，就要实现2n种重载。这还不是最坏的。有的函数——实际上是函数模板——接受**无限制**个数的参数，每个参数都可以是左值或者右值。此类函数的典型代表是`std::make_shared`，还有对于C++14的`std::make_unique`（见[Item21](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item21.html)）。查看他们的的重载声明：

```c++
template<class T, class... Args>                //来自C++11标准
shared_ptr<T> make_shared(Args&&... args);

template<class T, class... Args>                //来自C++14标准
unique_ptr<T> make_unique(Args&&... args);
```

对于这种函数，对于左值和右值分别重载就不能考虑了：通用引用是仅有的实现方案。对这种函数，我向你保证，肯定使用`std::forward`传递通用引用形参给其他函数。这也是你应该做的。



好吧，通常，最终。但是不一定最开始就是如此。**在某些情况，你可能需要在一个函数中多次使用绑定到右值引用或者通用引用的对象，并且确保在完成其他操作前，这个对象不会被移动。这时，你只想在*最后一次*使用时，使用`std::move`（对右值引用）或者`std::forward`（对通用引用）**。比如：

```c++
template<typename T>
void setSignText(T&& text)                  //text是通用引用
{
  sign.setText(text);                       //使用text但是不改变它
  
  auto now = 
      std::chrono::system_clock::now();     //获取现在的时间
  
  signHistory.add(now, 
                  std::forward<T>(text));   //有条件的转换为右值
}
```

这里，我们想要确保`text`的值不会被`sign.setText`改变，因为我们想要在`signHistory.add`中继续使用。因此`std::forward`只在最后使用。

对于`std::move`，同样的思路（即最后一次用右值引用的时候再调用`std::move`），但是需要注意，在有些稀少的情况下，你需要调用`std::move_if_noexcept`代替`std::move`。要了解何时以及为什么，参考[Item14](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item14.html)。

如果你在**按值**返回的函数中，返回值绑定到右值引用或者通用引用上，需要对返回的引用使用`std::move`或者`std::forward`。要了解原因，考虑两个矩阵相加的`operator+`函数，左侧的矩阵为右值（可以被用来保存求值之后的和）：

```c++
Matrix                              //按值返回
operator+(Matrix&& lhs, const Matrix& rhs)
{
    lhs += rhs;
    return std::move(lhs);	        //移动lhs到返回值中
}
```

通过在`return`语句中将`lhs`转换为右值（通过`std::move`），`lhs`可以移动到返回值的内存位置。如果省略了`std::move`调用:

```c++
Matrix                              //同之前一样
operator+(Matrix&& lhs, const Matrix& rhs)
{
    lhs += rhs;
    return lhs;                     //拷贝lhs到返回值中
}
```

**`lhs`是个左值的事实，会强制编译器拷贝它到返回值的内存空间。假定`Matrix`支持移动操作，并且比拷贝操作效率更高，在`return`语句中使用`std::move`的代码效率更高。**

**如果`Matrix`不支持移动操作，将其转换为右值不会变差，因为右值可以直接被`Matrix`的拷贝构造函数拷贝（见[Item23](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item23.html)）（const T&）。如果`Matrix`随后支持了移动操作，`operator+`将在下一次编译时受益。就是这种情况，通过将`std::move`应用到按值返回的函数中要返回的右值引用上，不会损失什么（还可能获得收益）。**

**使用通用引用和`std::forward`的情况类似**。考虑函数模板`reduceAndCopy`收到一个未规约（unreduced）对象`Fraction`，将其规约，并返回一个规约后的副本。如果原始对象是右值，可以将其移动到返回值中（避免拷贝开销），但是如果原始对象是左值，必须创建副本，因此如下代码：

```c++
template<typename T>
Fraction                            //按值返回
reduceAndCopy(T&& frac)             //通用引用的形参
{
    frac.reduce();
    return std::forward<T>(frac);		//移动右值，或拷贝左值到返回值中
}
```

如果`std::forward`被忽略，`frac`就被无条件复制到`reduceAndCopy`的返回值内存空间。



有些开发者获取到上面的知识后，**并尝试将其扩展到不适用的情况**。**“如果对要被拷贝到返回值的右值引用形参使用`std::move`，会把拷贝构造变为移动构造”**，他们想，“我也可以对我要返回的局部对象应用同样的优化。”换句话说，他们认为有个按值返回局部对象的函数，像这样，

```c++
Widget makeWidget()                 //makeWidget的“拷贝”版本
{
    Widget w;                       //局部对象
    …                               //配置w
    return w;                       //“拷贝”w到返回值中
}
```

他们想要“优化”代码，把“拷贝”变为移动：

```c++
Widget makeWidget()                 //makeWidget的移动版本
{
    Widget w;
    …
    return std::move(w);            //移动w到返回值中（不要这样做！）
}
```

我的注释告诉你这种想法是有问题的，但是问题在哪？

这是错的，因为对于这种优化，标准化委员会远领先于开发者。早就为人认识到的是，`makeWidget`的“拷贝”版本可以避免复制局部变量`w`的需要，通过在分配给函数返回值的内存中构造`w`来实现。这就是所谓的**返回值优化（*return value optimization*，RVO）**，这在C++标准中已经实现了。

说出这种优化反倒是一件麻烦事，因为你想只在那些不影响软件外在行为的地方允许这样的**拷贝消除**（copy elision）。对标准中教条的絮叨做些解释，这个特定的好事就是说，**编译器可能会在按值返回的函数中消除对局部对象的拷贝（或者移动）**

如果满足

（**1）局部对象与函数返回值的类型相同；**

**（2）局部对象就是要返回的东西，还有作为`return`语句的一部分而创建的临时对象。**

函数形参不满足要求。一些人将RVO的应用区分为命名的和未命名的（即临时的）局部对象，限制了RVO术语应用到未命名对象上，并把对命名对象的应用称为**命名返回值优化**（*named return value optimization*，NRVO）。）把这些记在脑子里，再看看`makeWidget`的“拷贝”版本：

```c++
Widget makeWidget()                 //makeWidget的“拷贝”版本
{
    Widget w;
    …
    return w;                       //“拷贝”w到返回值中
}
```

这里两个条件都满足，任何一个合适的C++编译器都会应用RVO来避免拷贝`w`。那意味着`makeWidget`的“拷贝”版本实际上不拷贝任何东西。

移动版本的`makeWidget`行为与其名称一样（假设`Widget`有移动构造函数），将`w`的内容移动到`makeWidget`的返回值位置。但是为什么编译器不使用RVO消除这种移动，而是在分配给函数返回值的内存中再次构造`w`呢？答案很简单：它们不能。

条件（2）中规定，仅当返回值为局部对象时，才进行RVO，但是`makeWidget`的移动版本不满足这条件，再次看一下返回语句：

```c++
return std::move(w);
```

**返回的已经不是局部对象`w`，而是`w`的引用——`std::move(w)`的结果**。返回局部对象的引用不满足RVO的第二个条件，所以编译器必须移动`w`到函数返回值的位置。**开发者试图对要返回的局部变量用`std::move`帮助编译器优化，反而限制了编译器的优化选项。**

但 RVO 的确是一种优化。编译器没有要求一定会省去拷贝和移动操作，即使允许那样做。也许你会怀疑，并且担心编译器会用拷贝操作惩罚你，仅仅因为它们可以做到。或者，也许你研究足够深入，会认识到存在某些情况，**RVO 是很难实现的**，例如，当一个函数中有 不同的控制路径返回不同的局部变量。（编译器必须要在返回值内存中构造局部变量，但编译器怎么知道要构造哪个合适呢？）如果是这样，你可能更愿意执行移动而不是拷贝。也就是说，你可能还是会想到使用 std::move，因为那样就不存在拷贝了。

那种情况下，**应用`std::move`到一个局部对象上仍然是一个坏主意**。C++标准关于RVO的部分表明，如果满足RVO的条件，但是编译器选择不执行拷贝消除，则返回的对象**必须被视为右值**。**实际上，标准要求当RVO被允许时，要么实行拷贝消除，要么将`std::move`隐式应用于返回的局部对象。**

因此，在`makeWidget`的“拷贝”版本中：

```c++
Widget makeWidget()                 //同之前一样
{
    Widget w;
    …
    return w;
}
```

编译器要不消除`w`的拷贝，要不把函数看成像下面写的一样：

```c++
Widget makeWidget()
{
    Widget w;
    …
    return std::move(w);            //把w看成右值，因为不执行拷贝消除
}
```

这种情况与按值返回函数形参的情况很像。

形参们没资格参与函数返回值的拷贝消除，但是如果作为返回值的话编译器会将其视作右值。结果就是，如果代码如下：

```c++
Widget makeWidget(Widget w)         //传值形参，与函数返回的类型相同
{
    …
    return w;
}

```

编译器必须看成像下面这样写的代码：

```c++
Widget makeWidget(Widget w)
{
    …
    return std::move(w);
}
```

这就意味着，如果你自己用了`std::move`，不仅帮不了编译器，反而肯定阻止了优化。反而肯定阻止了优化。**有些是应该对局部变量使用`std::move`，但是满足RVO的`return`语句或者返回一个传值形参不在此列。**



> **请记住:**

- ***最后一次使用时，在右值引用上使用`std::move`，在通用引用上使用`std::forward`***
- ***对按值返回的函数要返回的右值引用和通用引用，执行相同的操作***
- ***如果局部对象可以被返回值优化消除（RVO），就绝不使用`std::move`或者`std::forward`***



####	Item 26:避免重载通用引用

假如有如下代码：

```c++
std::multiset<std::string> names;           //全局数据结构
void logAndAdd(const std::string& name)
{
    auto now =                              //获取当前时间
        std::chrono::system_clock::now();
    log(now, "logAndAdd");                  //志记信息
    names.emplace(name);                    //把name加到全局数据结构中；
}                                           //emplace的信息见条款42
```

这份代码没有问题，但是同样的也没有效率。考虑这三个调用：

```c++
std::string petName("Darla");
logAndAdd(petName);                     //传递左值std::string
logAndAdd(std::string("Persephone"));	//传递右值std::string
logAndAdd("Patty Dog");                 //传递字符串字面值
```

第一个调用中，`logAndAdd`的形参`name`绑定到变量`petName`。在`logAndAdd`中`name`最终传给`names.emplace`。因为`name`是左值，会拷贝到`names`中。没有方法避免拷贝，因为是左值（`petName`）传递给`logAndAdd`的。

第二个调用中，形参`name`绑定到右值（显式从“`Persephone`”创建的临时`std::string`）。`name`本身是个左值，所以它被拷贝到`names`中，但是我们意识到，实际上，它可以被移动到`names`中。本次调用中，我们有个拷贝代价，但是我们应该能用移动勉强应付。

第三个调用中，形参`name`也绑定一个右值，但是这次是通过“`Patty Dog`”隐式创建的临时`std::string`变量。就像第二个调用中，`name`被拷贝到`names`，但是这里，传递给`logAndAdd`的实参是一个字符串字面量。如果直接将字符串字面量传递给`emplace`，就不会创建`std::string`的临时变量，而是直接在`std::multiset`中通过字面量构建`std::string`。在第三个调用中，我们有个`std::string`拷贝开销，但是我们连移动开销都不想要，更别说拷贝的。

我们可以通过使用通用引用（参见[Item24](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item24.html)）重写`logAndAdd`来使第二个和第三个调用效率提升，按照[Item25](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item25.html)的说法，`std::forward`转发这个引用到`emplace`。代码如下：

```c++
template<typename T>
void logAndAdd(T&& name)
{
    auto now = std::chrono::system_lock::now();
    log(now, "logAndAdd");
    names.emplace(std::forward<T>(name));
}

std::string petName("Darla");           //跟之前一样
logAndAdd(petName);                     //跟之前一样，拷贝左值到multiset
logAndAdd(std::string("Persephone"));	//移动右值而不是拷贝它
logAndAdd("Patty Dog");                 //在multiset直接创建std::string
                                        //而不是拷贝一个临时std::string
```

非常好，效率优化了！

在故事的最后，我们可以骄傲的交付这个代码，但是我还没有告诉你客户不总是有直接访问`logAndAdd`要求的名字的权限。有些客户只有索引，`logAndAdd`拿着索引在表中查找相应的名字。为了支持这些客户，`logAndAdd`需要重载为：

```c++
std::string nameFromIdx(int idx);   //返回idx对应的名字

void logAndAdd(int idx)             //新的重载
{
    auto now = std::chrono::system_lock::now();
    log(now, "logAndAdd");
    names.emplace(nameFromIdx(idx));
}
```

之后的两个调用按照预期工作：

```c++
std::string petName("Darla");           //跟之前一样

logAndAdd(petName);                     //跟之前一样，
logAndAdd(std::string("Persephone")); 	//这些调用都去调用
logAndAdd("Patty Dog");                 //T&&重载版本

logAndAdd(22);                          //调用int重载版本
```

事实上，这只能基本按照预期工作，假定一个客户将`short`类型索引传递给`logAndAdd`：

```c++
short nameIdx;
…                                       //给nameIdx一个值
logAndAdd(nameIdx);                     //错误！
```

最后一行的注释并不清楚明白，下面让我来说明发生了什么。

有两个重载的`logAndAdd`。使用通用引用的那个推导出`T`的类型是`short`，因此可以精确匹配。对于`int`类型参数的重载也可以在`short`类型提升后匹配成功。根据正常的重载解决规则，**精确匹配优先于类型提升的匹配**，所以被调用的是通用引用的重载。

在通用引用那个重载中，`name`形参绑定到要传入的`short`上，然后`name`被`std::forward`给`names`（一个`std::multiset<std::string>`）的`emplace`成员函数，然后又被转发给`std::string`构造函数。`std::string`没有接受`short`的构造函数，所以`logAndAdd`调用里的`multiset::emplace`调用里的`std::string`构造函数调用失败。所有这一切的原因就是**对于`short`类型通用引用重载优先于`int`类型的重载**。

**使用通用引用的函数在C++中是最贪婪的函数。它们几乎可以精确匹配任何类型的实参**（极少不适用的实参在[Item30](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item30.html)中介绍）。**这也是把重载和通用引用组合在一块是糟糕主意的原因：通用引用的实现会匹配比开发者预期要多得多的实参类型。**

一个更容易掉入这种陷阱的例子是写一个完美转发构造函数。简单对`logAndAdd`例子进行改造就可以说明这个问题。不用写接受`std::string`或者用索引查找`std::string`的自由函数，只是想一个构造函数有着相同操作的`Person`类：

```c++
class Person {
public:
    template<typename T>
    explicit Person(T&& n)              //完美转发的构造函数，初始化数据成员
    : name(std::forward<T>(n)) {}

    explicit Person(int idx)            //int的构造函数
    : name(nameFromIdx(idx)) {}
    …

private:
    std::string name;
};
```

就像在`logAndAdd`的例子中，传递一个不是`int`的整型变量（比如`std::size_t`，`short`，`long`等）会调用通用引用的构造函数而不是`int`的构造函数，这会导致编译错误。这里这个问题甚至更糟糕，因为`Person`中存在的重载比肉眼看到的更多。在[Item17](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item17.html)中说明，在适当的条件下，C++会生成拷贝和移动构造函数，即使类包含了模板化的构造函数，模板函数能实例化产生与拷贝和移动构造函数一样的签名，也在合适的条件范围内。如果拷贝和移动构造被生成，`Person`类看起来就像这样：

```c++
class Person {
public:
    template<typename T>            //完美转发的构造函数
    explicit Person(T&& n)
    : name(std::forward<T>(n)) {}

    explicit Person(int idx);       //int的构造函数

    Person(const Person& rhs);      //拷贝构造函数（编译器生成）
    Person(Person&& rhs);           //移动构造函数（编译器生成）
    …
};
```

只有你在花了很多时间在编译器领域时，下面的行为才变得直观（译者注：这里意思就是这种实现会导致不符合人类直觉的结果，下面就解释了这种现象的原因）：

```c++
Person p("Nancy"); 
auto cloneOfP(p);                   //从p创建新Person；这通不过编译！
```

这里我们试图通过一个`Person`实例创建另一个`Person`，显然应该调用拷贝构造即可。（`p`是左值，我们可以把通过移动操作来完成“拷贝”的想法请出去了。）但是这份代码不是调用拷贝构造函数，而是调用完美转发构造函数。然后，完美转发的函数将尝试使用`Person`对象`p`初始化`Person`的`std::string`数据成员，编译器就会报错。

“为什么？”你可能会疑问，“为什么拷贝构造会被完美转发构造替代？我们显然想拷贝`Person`到另一个`Person`”。确实我们是这样想的，但是编译器严格遵循C++的规则，这里的相关规则就是控制对重载函数调用的解析规则。

编译器的理由如下：`cloneOfP`被non-`const`左值`p`初始化，这意味着模板化构造函数可被实例化为采用`Person`类型的non-`const`左值。实例化之后，`Person`类看起来是这样的：

```c++
class Person {
public:
    explicit Person(Person& n)          //由完美转发模板初始化
    : name(std::forward<Person&>(n)) {}

    explicit Person(int idx);           //同之前一样

    Person(const Person& rhs);          //拷贝构造函数（编译器生成的）
    …
};
```

在这个语句中，

```c++
auto cloneOfP(p);
```

其中`p`被传递给拷贝构造函数或者完美转发构造函数。**调用拷贝构造函数要求在`p`前加上`const`的约束来满足函数形参的类型，而调用完美转发构造不需要加这些东西**。从模板产生的重载函数是更好的匹配，所以编译器按照规则：**调用最佳匹配的函数**。“拷贝”non-`const`左值类型的`Person`交由完美转发构造函数处理，而不是拷贝构造函数。

如果我们将本例中的传递的对象改为`const`的，会得到完全不同的结果：

```c++
const Person cp("Nancy");   //现在对象是const的
auto cloneOfP(cp);          //调用拷贝构造函数！
```

因为被拷贝的对象是`const`，是拷贝构造函数的精确匹配。虽然模板化的构造函数可以被实例化为有完全一样的函数签名，

```c++
class Person {
public:
    explicit Person(const Person& n);   //从模板实例化而来
  
    Person(const Person& rhs);          //拷贝构造函数（编译器生成的）
    …
};
```

但是没啥影响，**因为重载规则规定当模板实例化函数和非模板函数（或者称为“正常”函数）匹配优先级相当时，优先使用“正常”函数。拷贝构造函数（正常函数）因此胜过具有相同签名的模板实例化函数。**

（如果你想知道为什么编译器在生成一个拷贝构造函数时还会模板实例化一个相同签名的函数，参考[Item17](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item17.html)。）

当**继承**纳入考虑范围时，完美转发的构造函数与编译器生成的拷贝、移动操作之间的交互会更加复杂。尤其是，派生类的拷贝和移动操作的传统实现会表现得非常奇怪。来看一下：

```c++
class SpecialPerson: public Person {
public:
    SpecialPerson(const SpecialPerson& rhs) //拷贝构造函数，调用基类的
    : Person(rhs)                           //完美转发构造函数！
    { … }

    SpecialPerson(SpecialPerson&& rhs)      //移动构造函数，调用基类的
    : Person(std::move(rhs))                //完美转发构造函数！
    { … }
};
```

如同注释表示的，**派生类的拷贝和移动构造函数没有调用基类的拷贝和移动构造函数，而是调用了基类的完美转发构造函数！**为了理解原因，要知道派生类将`SpecialPerson`类型的实参传递给其基类，然后通过模板实例化和重载解析规则作用于基类`Person`。最终，代码无法编译，因为`std::string`没有接受一个`SpecialPerson`的构造函数。

我希望到目前为止，已经说服了你，如果可能的话，避免对通用引用形参的函数进行重载。但是，如果在通用引用上重载是糟糕的主意，那么如果需要可转发大多数实参类型的函数，但是对于某些实参类型又要特殊处理应该怎么办？存在多种办法。实际上，下一个条款，[Item27](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item27.html)专门来讨论这个问题，敬请阅读。

> **请记住**

- ***对通用引用形参的函数进行重载，通用引用函数的调用机会几乎总会比你期望的多得多***
- ***完美转发构造函数是糟糕的实现，因为对于`non-const`左值，它们比拷贝构造函数更加匹配，而且会劫持派生类对于基类的拷贝和移动构造函数的调用。***



####	Item 27:熟悉重载通用引用的替代品

[Item26](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item26.html)中说明了对使用通用引用形参的函数，无论是独立函数还是成员函数（尤其是构造函数），进行重载都会导致一系列问题。但是也提供了一些示例，如果能够按照我们期望的方式运行，重载可能也是有用的。这个条款探讨了几种，通过避免在通用引用上重载的设计，或者通过限制通用引用可以匹配的参数类型，来实现所期望行为的方法。



**[放弃重载]**

在[Item26](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item26.html)中的第一个例子中，`logAndAdd`是许多函数的代表，这些函数可以使用不同的名字来避免在通用引用上的重载的弊端。例如两个重载的`logAndAdd`函数，可以分别改名为`logAndAddName`和`logAndAddNameIdx`。但是，这种方式不能用在第二个例子，`Person`构造函数中，因为构造函数的名字被语言固定了（译者注：即构造函数名与类名相同）。此外谁愿意放弃重载呢？

**[传递const T&]**

一种替代方案是退回到C++98，然后将传递通用引用替换为传递lvalue-refrence-to-`const`。事实上，这是[Item26](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item26.html)中首先考虑的方法。缺点是效率不高。现在我们知道了通用引用和重载的相互关系，所以放弃一些效率来确保行为正确简单可能也是一种不错的折中。

**[传值]**

通常在不增加复杂性的情况下提高性能的一种方法是，将按传引用形参替换为按值传递，这是违反直觉的。该设计遵循[Item41](https://cntransgroup.github.io/EffectiveModernCppChinese/8.Tweaks/item41.html)中给出的建议，即在你知道要拷贝时就按值传递，因此会参考那个条款来详细讨论如何设计与工作，效率如何。这里，在`Person`的例子中展示：

```c++
class Person {
public:
    explicit Person(std::string n)  //代替T&&构造函数，
    : name(std::move(n)) {}         //std::move的使用见条款41
  
    explicit Person(int idx)        //同之前一样
    : name(nameFromIdx(idx)) {}
    …

private:
    std::string name;
};
```

因为没有`std::string`构造函数可以接受整型参数，所有`int`或者其他整型变量（比如`std::size_t`、`short`、`long`等）都会使用`int`类型重载的构造函数。相似的，所有`std::string`类似的实参（还有可以用来创建`std::string`的东西，比如字面量“`Ruth`”等）都会使用`std::string`类型的重载构造函数。没有意外情况。我想你可能会说有些人使用`0`或者`NULL`指代空指针会调用`int`重载的构造函数让他们很吃惊，但是这些人应该参考[Item8](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item8.html)反复阅读直到使用`0`或者`NULL`作为空指针让他们恶心。

**[使用*tag dispatch*]**

传递lvalue-reference-to-`const`以及按值传递都不支持完美转发。如果使用通用引用的动机是完美转发，我们就只能使用通用引用了，没有其他选择。但是又不想放弃重载。所以如果不放弃重载又不放弃通用引用，如何避免在通用引用上重载呢？

实际上并不难。通过查看所有重载的所有形参以及调用点的所有传入实参，然后选择最优匹配的函数——考虑所有形参/实参的组合。通用引用通常提供了最优匹配，但是如果通用引用是包含其他**非**通用引用的形参列表的一部分，则非通用引用形参的较差匹配会使有一个通用引用的重载版本不被运行。这就是*tag dispatch*方法的基础，下面的示例会使这段话更容易理解。

我们将标签分派应用于`logAndAdd`例子，下面是原来的代码，以免你再分心回去查看：

```c++
std::multiset<std::string> names;       //全局数据结构

template<typename T>                    //志记信息，将name添加到数据结构
void logAndAdd(T&& name)
{
    auto now = std::chrono::system_clokc::now();
    log(now, "logAndAdd");
    names.emplace(std::forward<T>(name));
}
```

就其本身而言，功能执行没有问题，但是如果引入一个`int`类型的重载来用索引查找对象，就会重新陷入[Item26](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item26.html)中描述的麻烦。这个条款的目标是避免它。不通过重载，我们重新实现`logAndAdd`函数分拆为两个函数，一个针对整型值，一个针对其他。`logAndAdd`本身接受所有实参类型，包括整型和非整型。

这两个真正执行逻辑的函数命名为`logAndAddImpl`，即我们使用重载。其中一个函数接受通用引用。所以我们同时使用了重载和通用引用。但是每个函数接受第二个形参，表征传入的实参是否为整型。这第二个形参可以帮助我们避免陷入到[Item26](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item26.html)中提到的麻烦中，因为我们将其安排为第二个实参决定选择哪个重载函数。

是的，我知道，“不要在啰嗦了，赶紧亮出代码”。没有问题，代码如下，这是最接近正确版本的：

```c++
template<typename T>
void logAndAdd(T&& name) 
{
    logAndAddImpl(std::forward<T>(name),
                  std::is_integral<T>());   //不那么正确
}
```

这个函数转发它的形参给`logAndAddImpl`函数，但是多传递了一个表示形参`T`是否为整型的实参。至少，这就是应该做的。对于右值的整型实参来说，这也是正确的。但是如同[Item28](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item28.html)中说明，如果左值实参传递给通用引用`name`，对`T`类型推断会得到左值引用。**所以如果左值`int`被传入`logAndAdd`，`T`将被推断为`int&`**。这不是一个整型类型，因为引用不是整型类型。这意味着`std::is_integral<T>`对于任何左值实参返回false，即使确实传入了整型值。

意识到这个问题基本相当于解决了它，因为C++标准库有一个*type trait*（参见[Item9](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item9.html)），`std::remove_reference`，函数名字就说明做了我们希望的：移除类型的引用说明符。所以正确实现的代码应该是这样：

```c++
template<typename T>
void logAndAdd(T&& name)
{
    logAndAddImpl(
        std::forward<T>(name),
        std::is_integral<typename std::remove_reference<T>::type>()
    );
}
```

这个代码很巧妙。（在C++14中，你可以通过`std::remove_reference_t<T>`来简化写法，参看[Item9](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item9.html)）

处理完之后，我们可以将注意力转移到名为`logAndAddImpl`的函数上了。有两个重载函数，第一个仅用于非整型类型（即`std::is_integral<typename std::remove_reference<T>::type>`是false）：

```c++
template<typename T>                            //非整型实参：添加到全局数据结构中
void logAndAddImpl(T&& name, std::false_type)	//译者注：高亮std::false_type
{
    auto now = std::chrono::system_clock::now();
    log(now, "logAndAdd");
    names.emplace(std::forward<T>(name));
}
```

一旦你理解了高亮参数的含义，代码就很直观。概念上，`logAndAdd`传递一个布尔值给`logAndAddImpl`表明是否传入了一个整型类型，但是`true`和`false`是**运行时**值，我们需要使用重载决议——**编译时**决策——来选择正确的`logAndAddImpl`重载。这意味着我们需要一个**类型**对应`true`，另一个不同的类型对应`false`。这个需要是经常出现的，**所以标准库提供了这样两个命名`std::true_type`和`std::false_type`**。`logAndAdd`传递给`logAndAddImpl`的实参是个对象，如果`T`是整型，对象的类型就继承自`std::true_type`，反之继承自`std::false_type`。最终的结果就是，当`T`不是整型类型时，这个`logAndAddImpl`重载是个可供调用的候选者。

第二个重载覆盖了相反的场景：当`T`是整型类型。在这个场景中，`logAndAddImpl`简单找到对应传入索引的名字，然后传递给`logAndAdd`：

```c++
std::string nameFromIdx(int idx);           //与条款26一样，整型实参：查找名字并用它调用logAndAdd
void logAndAddImpl(int idx, std::true_type) //译者注：高亮std::true_type
{
  logAndAdd(nameFromIdx(idx)); 
}
```

通过索引找到对应的`name`，然后让`logAndAddImpl`传递给`logAndAdd`（名字会被再`std::forward`给另一个`logAndAddImpl`重载），我们避免了将日志代码放入这个`logAndAddImpl`重载中。

在这个设计中，**类型`std::true_type`和`std::false_type`是“标签”（tag）**，其唯一目的就是强制重载解析按照我们的想法来执行。**注意到我们甚至没有对这些参数进行命名。他们在运行时毫无用处，事实上我们希望编译器可以意识到这些标签形参没被使用，然后在程序执行时优化掉它们。**（至少某些时候有些编译器会这样做。）通过创建标签对象，在`logAndAdd`内部将重载实现函数的调用“分发”（*dispatch*）给正确的重载。因此这个设计名称为：*tag dispatch*。这是模板元编程的标准构建模块，你对现代C++库中的代码了解越多，你就会越多遇到这种设计。

就我们的目的而言，***tag dispatch*的重要之处在于它可以允许我们组合重载和通用引用使用**，**而没有[Item26](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item26.html)中提到的问题**。

分发函数——`logAndAdd`——接受一个没有约束的通用引用参数，但是这个函数没有重载。

实现函数——`logAndAddImpl`——是重载的，一个接受通用引用参数，但是重载规则不仅依赖通用引用形参，还依赖新引入的**标签形参**，标签值设计来保证有不超过一个的重载是合适的匹配。**结果是标签来决定采用哪个重载函数**。通用引用参数可以生成精确匹配的事实在这里并不重要。



**[约束使用通用引用的模板]**

*tag dispatch*的关键是存在单独一个函数（没有重载）给客户端API。这个单独的函数分发给具体的实现函数。创建一个没有重载的分发函数通常是容易的，**但是[Item26](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item26.html)中所述第二个问题案例是`Person`类的完美转发构造函数**，是个例外。编译器可能会自行生成拷贝和移动构造函数，所以即使你只写了一个构造函数并在其中使用*tag dispatch*，有一些对构造函数的调用也被编译器生成的函数处理，绕过了分发机制。

实际上，真正的问题不是编译器生成的函数会绕过*tag dispatch*设计，而是并不能总是调用正确。你希望类的拷贝构造函数总是处理该类型的左值拷贝请求，但是如同[Item26](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item26.html)中所述，提供具有通用引用的构造函数，会使通用引用构造函数在拷贝non-`const`左值时被调用（而不是拷贝构造函数）。那个条款还说明了当一个基类声明了完美转发构造函数，派生类实现自己的拷贝和移动构造函数时会调用那个完美转发构造函数，尽管正确的行为是调用基类的拷贝或者移动构造。

**这种情况，采用通用引用的重载函数通常比期望的更加贪心，虽然不像单个分派函数一样那么贪心，而又不满足使用*tag dispatch*的条件。你需要另外的技术，可以让你确定允许使用通用引用模板的条件。朋友，你需要的就是`std::enable_if`。**

`std::enable_if`可以给你提供一种强制编译器执行行为的方法，像是特定模板不存在一样。这种模板被称为被**禁止**（disabled）。默认情况下，所有模板是**启用**的（enabled），但是使用`std::enable_if`可以使得仅在`std::enable_if`指定的条件满足时模板才启用。在这个例子中，我们只在传递的类型不是`Person`时使用`Person`的完美转发构造函数。如果传递的类型是`Person`，我们要禁止完美转发构造函数（即让编译器忽略它），因为这会让拷贝或者移动构造函数处理调用，这是我们想要使用`Person`初始化另一个`Person`的初衷。

这个主意听起来并不难，但是语法比较繁杂，尤其是之前没有接触过的话，让我慢慢引导你。有一些`std::enbale_if`的contidion（条件）部分的样板，让我们从这里开始。下面的代码是`Person`完美转发构造函数的声明，多展示`std::enable_if`的部分来简化使用难度。我仅展示构造函数的声明，因为`std::enable_if`的使用对函数实现没影响。实现部分跟[Item26](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item26.html)中没有区别。

```c++
class Person {
public:
    template<typename T,
             typename = typename std::enable_if<condition>::type>   
                 									//condition为某其他特定条件
    explicit Person(T&& n);
    …
};

```

为了理解`std::enable_if`部分发生了什么，我很遗憾的表示你要自行参考其他代码，因为详细解释需要花费一定空间和时间，而本书并没有足够的空间（在你自行学习过程中，请研究**“SFINAE”**以及`std::enable_if`，因为“SFINAE”就是使`std::enable_if`起作用的技术）。这里我想要集中讨论条件的表示，该条件表示此构造函数是否启用。

这里我们想表示的条件是确认`T`不是`Person`类型，即模板构造函数应该在`T`不是`Person`类型的时候启用。多亏了*type trait*可以确定两个对象类型是否相同（`std::is_same`），看起来我们需要的就是`!std::is_same<Person, T>::value`（注意语句开始的`!`，我们想要的是**不**相同）。这很接近我们想要的了，但是不完全正确，因为如同[Item28](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item28.html)中所述，使用左值来初始化通用引用的话会推导成左值引用，比如这个代码:

```c++
Person p("Nancy");
auto cloneOfP(p);       //用左值初始化
```

`T`的类型在通用引用的构造函数中被推导为`Person&`。`Person`和`Person&`类型是不同的，`std::is_same`的结果也反映了：`std::is_same<Person, Person&>::value`是false。

如果我们更精细考虑仅当`T`不是`Person`类型才启用模板构造函数，我们会意识到当我们查看`T`时，应该忽略：

- **是否是个引用**。对于决定是否通用引用构造函数启用的目的来说，`Person`，`Person&`，`Person&&`都是跟`Person`一样的。
- **是不是`const`或者`volatile`**。如上所述，`const Person`，`volatile Person` ，`const volatile Person`也是跟`Person`一样的。

这意味着我们需要一种方法消除对于`T`的引用，`const`，`volatile`修饰。再次，标准库提供了这样功能的*type trait*，就是`std::decay`。`std::decay<T>::value`与`T`是相同的，只不过会移除引用和cv限定符（*cv-qualifiers*，即`const`或`volatile`标识符）的修饰。（这里我没有说出另外的真相，`std::decay`如同其名一样，可以将数组或者函数退化成指针，参考[Item1](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item1.html)，但是在这里讨论的问题中，它刚好合适）。我们想要控制构造函数是否启用的条件可以写成：

```c++
!std::is_same<Person, typename std::decay<T>::type>::value
```

即`Person`和`T`的类型不同，忽略了所有引用和cv限定符。（如[Item9](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item9.html)所述，`std::decay`前的“`typename`”是必需的，因为`std::decay<T>::type`的类型取决于模板形参`T`。）

将其带回上面`std::enable_if`样板的代码中，加上调整一下格式，让各部分如何组合在一起看起来更容易，`Person`的完美转发构造函数的声明如下：

```c++
class Person {
public:
    template<
        typename T,
        typename = typename std::enable_if<
                       !std::is_same<Person, 
                                     typename std::decay<T>::type
                                    >::value
                   >::type
    >
    explicit Person(T&& n);
    …
};
```

如果你之前从没有看到过这种类型的代码，那你可太幸福了。最后才放出这种设计是有原因的。当你有其他机制来避免同时使用重载和通用引用时（你总会这样做），确实应该那样做。不过，一旦你习惯了使用函数语法和尖括号的使用，也不坏。此外，这可以提供你一直想要的行为表现。在上面的声明中，使用`Person`初始化一个`Person`——无论是左值还是右值，`const`还是non-`const`，`volatile`还是non-`volatile`——都不会调用到通用引用构造函数。

成功了，对吗？确实！

啊，不对。等会再庆祝。[Item26](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item26.html)还有一个情景需要解决，我们需要继续探讨下去。

假定从`Person`派生的类以常规方式实现拷贝和移动操作：

```c++
class SpecialPerson: public Person {
public:
    SpecialPerson(const SpecialPerson& rhs) //拷贝构造函数，调用基类的
    : Person(rhs)                           //完美转发构造函数！
    { … }
    
    SpecialPerson(SpecialPerson&& rhs)      //移动构造函数，调用基类的
    : Person(std::move(rhs))                //完美转发构造函数！
    { … }
    
    …
};
```

这和[Item26](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item26.html)中的代码是一样的，包括注释也是一样。当我们拷贝或者移动一个`SpecialPerson`对象时，我们希望调用基类对应的拷贝和移动构造函数，来拷贝或者移动基类部分，但是这里，我们将`SpecialPerson`传递给基类的构造函数，因为`SpecialPerson`和`Person`类型不同（在应用`std::decay`后也不同），所以完美转发构造函数是启用的，会实例化为精确匹配`SpecialPerson`实参的构造函数。相比于派生类到基类的转化——这个转化对于在`Person`拷贝和移动构造函数中把`SpecialPerson`对象绑定到`Person`形参非常重要，生成的精确匹配是更优的，所以这里的代码，拷贝或者移动`SpecialPerson`对象就会调用`Person`类的完美转发构造函数来执行基类的部分。跟[Item26](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item26.html)的困境一样。

派生类仅仅是按照常规的规则生成了自己的移动和拷贝构造函数，所以这个问题的解决还要落实在基类，尤其是控制是否使用`Person`通用引用构造函数启用的条件。现在我们意识到不只是禁止`Person`类型启用模板构造函数，而是禁止`Person`**以及任何派生自`Person`**的类型启用模板构造函数。讨厌的继承！

你应该不意外在这里看到标准库中也有*type trait*判断一个类型是否继承自另一个类型，就是**`std::is_base_of`**。如果`std::is_base_of<T1, T2>`是true就表示`T2`派生自`T1`。类型也可被认为是从他们自己派生，所以`std::is_base_of<T, T>::value`总是true。这就很方便了，我们想要修正控制`Person`完美转发构造函数的启用条件，只有当`T`在消除引用和cv限定符之后，并且既不是`Person`又不是`Person`的派生类时，才满足条件。所以使用`std::is_base_of`代替`std::is_same`就可以了：

```c++
class Person {
public:
    template<
        typename T,
        typename = typename std::enable_if<
                       !std::is_base_of<Person, 
                                        typename std::decay<T>::type
                                       >::value
                   >::type
    >
    explicit Person(T&& n);
    …
};

```

现在我们终于完成了最终版本。这是C++11版本的代码，如果我们使用C++14，这份代码也可以工作，但是可以使用`std::enable_if`和`std::decay`的别名模板来少写“`typename`”和“`::type`”这样的麻烦东西，产生了下面这样看起来舒爽的代码：

```c++
class Person  {                                         //C++14
public:
    template<
        typename T,
        typename = std::enable_if_t<                    //这儿更少的代码
                       !std::is_base_of<Person,
                                        std::decay_t<T> //还有这儿
                                       >::value
                   >                                    //还有这儿
    >
    explicit Person(T&& n);
    …
};
```

好了，我承认，我又撒谎了。我们还没有完成，但是越发接近最终版本了。非常接近，我保证。

我们已经知道如何使用`std::enable_if`来选择性禁止`Person`通用引用构造函数，来使得一些实参类型确保使用到拷贝或者移动构造函数，但是我们还没将其应用于区分整型参数和非整型参数。毕竟，我们的原始目标是解决构造函数模糊性问题。

我们需要的所有东西——我确实意思是所有——是

（1）加入一个`Person`构造函数重载来处理整型参数；

（2）约束模板构造函数使其对于某些实参禁用。

使用这些我们讨论过的技术组合起来，就能解决这个问题了：

```c++
class Person {
public:
    template<
        typename T,
        typename = std::enable_if_t<
            !std::is_base_of<Person, std::decay_t<T>>::value
            &&
            !std::is_integral<std::remove_reference_t<T>>::value
        >
    >
    explicit Person(T&& n)          //对于std::strings和可转化为
    : name(std::forward<T>(n))      //std::strings的实参的构造函数
    { … }

    explicit Person(int idx)        //对于整型实参的构造函数
    : name(nameFromIdx(idx))
    { … }

    …                               //拷贝、移动构造函数等

private:
    std::string name;
};
```

看！多么优美！好吧，优美之处只是对于那些迷信模板元编程之人，但是确实提出了不仅能工作的方法，而且极具技巧。因为使用了完美转发，所以具有最大效率，因为控制了通用引用与重载的结合而不是禁止它，这种技术可以被用于不可避免要用重载的情况（比如构造函数）。

**[折中]**

本条款提到的前三个技术——放弃重载、传递const T&、传值——在函数调用中指定每个形参的类型。后两个技术——*tag dispatch*和限制模板适用范围——使用完美转发，因此不需要指定形参类型。这一基本决定（是否指定类型）有一定后果。

**通常，完美转发更有效率**，因为它避免了仅仅去为了符合形参声明的类型而创建临时对象。在`Person`构造函数的例子中，完美转发允许将“`Nancy`”这种字符串字面量转发到`Person`内部的`std::string`的构造函数，不使用完美转发的技术则会从字符串字面值创建一个临时`std::string`对象，来满足`Person`构造函数指定的形参要求。

**但是完美转发也有缺点。即使某些类型的实参可以传递给接受特定类型的函数，也无法完美转发。[Item30](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item30.html)中探索了完美转发失败的例子。**

第二个问题是当**客户传递无效参数时错误消息的可理解性**。例如假如客户传递了一个由`char16_t`（一种C++11引入的类型表示16位字符）而不是`char`（`std::string`包含的）组成的字符串字面值来创建一个`Person`对象：

```cpp
Person p(u"Konrad Zuse");   //“Konrad Zuse”由const char16_t类型字符组成
```

使用本条款中讨论的前三种方法，编译器将看到可用的采用`int`或者`std::string`的构造函数，它们或多或少会产生错误消息，表示没有可以从`const char16_t[12]`转换为`int`或者`std::string`的方法。

**但是，基于完美转发的方法，`const char16_t`不受约束地绑定到构造函数的形参**。从那里将转发到`Person`的`std::string`数据成员的构造函数，在这里，调用者传入的内容（`const char16_t`数组）与所需内容（`std::string`构造函数可接受的类型）发生的不匹配会被发现。由此产生的错误消息会让人更印象深刻，在我使用的编译器上，**会产生超过160行错误信息**。

在这个例子中，通用引用仅被转发一次（从`Person`构造函数到`std::string`构造函数），但是更复杂的系统中，在最终到达判断实参类型是否可接受的地方之前，通用引用会被多层函数调用转发。通用引用被转发的次数越多，产生的错误消息偏差就越大。许多开发者发现，这种特殊问题是发生在留有通用引用形参的接口上，这些接口以性能作为首要考虑点。

在`Person`这个例子中，我们知道完美转发函数的通用引用形参要作为`std::string`的初始化器，所以我们可以用`**static_assert**`来确认它可以起这个作用。**`std::is_constructible`**这个*type trait*执行编译时测试，确定一个类型的对象是否可以用另一个不同类型（或多个类型）的对象（或多个对象）来构造，所以代码可以这样：

```c++
class Person {
public:
    template<                       //同之前一样
        typename T,
        typename = std::enable_if_t<
            !std::is_base_of<Person, std::decay_t<T>>::value
            &&
            !std::is_integral<std::remove_reference_t<T>>::value
        >
    >
    explicit Person(T&& n)
    : name(std::forward<T>(n))
    {
        //断言可以用T对象创建std::string
        static_assert(
        std::is_constructible<std::string, T>::value,
        "Parameter n can't be used to construct a std::string"
        );

        …               //通常的构造函数的工作写在这

    }
    
    …                   //Person类的其他东西（同之前一样）
};
```

如果客户代码尝试使用无法构造`std::string`的类型创建`Person`，会导致指定的错误消息。不幸的是，在这个例子中，`static_assert`在构造函数体中，但是转发的代码作为成员初始化列表的部分在检查之前。所以我使用的编译器，**结果是由`static_assert`产生的清晰的错误消息在常规错误消息（多达160行以上那个）后出现**。

> **请记住**

- ***通用引用和重载的组合替代方案包括***
  - ***使用不同的重载名，***
  - ***通过`lvalue-reference-to-const`传递形参，***
  - ***按值传递形参，***
  - ***使用`tag dispatch`***
- ***通过`std::enable_if`约束模板，允许组合通用引用和重载使用，但它也控制了编译器在哪种条件下才使用通用引用重载***
- ***通用引用参数通常具有高效率的优势，但是可用性就值得斟酌***



####	Item 28:理解引用折叠



引用折叠是`std::forward`工作的一种关键机制。就像[Item25](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item25.html)中解释的一样，`std::forward`应用在通用引用参数上，所以经常能看到这样使用：

```c++
template<typename T>
void f(T&& fParam)
{
    …                                   //做些工作
    someFunc(std::forward<T>(fParam));  //转发fParam到someFunc
}
```

因为`fParam`是通用引用，我们知道类型参数`T`的类型根据`f`被传入实参（即用来实例化`fParam`的表达式）是左值还是右值来编码。`std::forward`的作用是当且仅当传给`f`的实参为右值时，即`T`为非引用类型，才将`fParam`（左值）转化为一个右值。

`std::forward`可以这样实现：

```c++
template<typename T>                                //在std命名空间
T&& forward(typename
                remove_reference<T>::type& param)
{
    return static_cast<T&&>(param);
}
```

这不是标准库版本的实现（忽略了一些接口描述），但是为了理解`std::forward`的行为，这些差异无关紧要。

假设传入到`f`的实参是`Widget`的左值类型。`T`被推导为`Widget&`，然后调用`std::forward`将实例化为`std::forward<Widget&>`。`Widget&`带入到上面的`std::forward`的实现中：

```c++
Widget& && forward(typename 
                       remove_reference<Widget&>::type& param)
{ return static_cast<Widget& &&>(param); }
```

`std::remove_reference<Widget&>::type`这个*type trait*产生`Widget`（查看[Item9](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item9.html)），所以`std::forward`成为：

```c++
Widget& && forward(Widget& param)
{ return static_cast<Widget& &&>(param); }
```

根据引用折叠规则，返回值和强制转换可以化简，最终版本的`std::forward`调用就是：

```c++
Widget& forward(Widget& param)
{ return static_cast<Widget&>(param); }
```

正如你所看到的，当左值实参被传入到函数模板`f`时，`std::forward`被实例化为接受和返回左值引用。内部的转换不做任何事，因为`param`的类型已经是`Widget&`，所以转换没有影响。左值实参传入`std::forward`会返回左值引用。通过定义，左值引用就是左值，因此将左值传递给`std::forward`会返回左值，就像期待的那样。

现在假设一下，传递给`f`的实参是一个`Widget`的右值。在这个例子中，`f`的类型参数`T`的推导类型就是`Widget`。`f`内部的`std::forward`调用因此为`std::forward<Widget>`，`std::forward`实现中把`T`换为`Widget`得到：

```c++
Widget&& forward(typename
                     remove_reference<Widget>::type& param)
{ return static_cast<Widget&&>(param); }
```

将`std::remove_reference`引用到非引用类型`Widget`上还是相同的类型（`Widget`），所以`std::forward`变成

```c++
Widget&& forward(Widget& param)
{ return static_cast<Widget&&>(param); }
```

这里没有引用的引用，所以不需要引用折叠，这就是`std::forward`的最终实例化版本。

从函数返回的右值引用被定义为右值，因此在这种情况下，`std::forward`会将`f`的形参`fParam`（左值）转换为右值。最终结果是，传递给`f`的右值参数将作为右值转发给`someFunc`，正是想要的结果。

在C++14中，`std::remove_reference_t`的存在使得实现变得更简洁：

```c++
template<typename T>                        //C++14；仍然在std命名空间
T&& forward(remove_reference_t<T>& param)
{
  return static_cast<T&&>(param);
}
```

引用折叠发生在四种情况下。**第一，也是最常见的就是模板实例化。第二，是`auto`变量的类型生成，具体细节类似于模板，因为`auto`变量的类型推导基本与模板类型推导雷同（参见[Item2](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item2.html)）**。考虑本条款前面的例子：

```c++
Widget widgetFactory();     //返回右值的函数
Widget w;                   //一个变量（左值）
func(w);                    //用左值调用func；T被推导为Widget&
func(widgetFactory());      //用又值调用func；T被推导为Widget
```

在auto的写法中，规则是类似的。声明

```c++
auto&& w1 = w;
// Widget& && w1 = w;
// Widget& w1 = w
```

另一方面，这个声明，

```c++
auto&& w2 = widgetFactory();
// Widget&& w2 = widgetFactory()
```



> **请记住**

- ***引用折叠发生在四种情况下：模板实例化，`auto`类型推导，`typedef`与别名声明的创建和使用，`decltype`。***
- ***当编译器在引用折叠环境中生成了引用的引用时，结果就是单个引用。有左值引用用折叠结果就是左值引用，否则就是右值引用***
- ***通用引用是在特殊上下文的右值引用，这个上下文满足两个条件：类型推导区分左值和右值，并且发生引用折叠***



####	Item 29:假定移动操作不存在，成本高，未被使用

移动语义可以说是C++11最主要的特性。你可能会见过这些类似的描述“移动容器和拷贝指针一样开销小”， “拷贝临时对象现在如此高效，写代码避免这种情况简直就是过早优化”。这种情绪很容易理解。移动语义确实是这样重要的特性。它不仅允许编译器使用开销小的移动操作代替大开销的复制操作，而且默认这么做（当特定条件满足的时候）。以C++98的代码为基础，使用C++11重新编译你的代码，然后，哇，你的软件运行的更快了。

移动语义确实可以做这些事，这把这个特性封为一代传说。但是传说总有些夸大成分。这个条款的目的就是给你泼一瓢冷水，保持理智看待移动语义。

让我们从已知很多类型不支持移动操作开始这个过程。为了升级到C++11，C++98的很多标准库做了大修改，为很多类型提供了移动的能力，这些类型的移动实现比复制操作更快，并且对库的组件实现修改以利用移动操作。但是很有可能你工作中的代码没有完整地利用C++11。对于你的应用中（或者代码库中）的类型，没有适配C++11的部分，编译器即使支持移动语义也是无能为力的。的确，C++11倾向于为缺少移动操作的类生成它们，但是只有在没有声明复制操作，移动操作，或析构函数的类中才会生成移动操作（参考[Item17](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item17.html)）。数据成员或者某类型的基类禁止移动操作（比如通过delete移动操作，参考[Item11](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item11.html)），编译器不生成移动操作的支持。对于没有明确支持移动操作的类型，并且不符合编译器默认生成的条件的类，没有理由期望C++11会比C++98进行任何性能上的提升。

即使显式支持了移动操作，结果可能也没有你希望的那么好。比如，所有C++11的标准库容器都支持了移动操作，但是认为移动所有容器的开销都非常小是个错误。对于某些容器来说，压根就不存在开销小的方式来移动它所包含的内容。对另一些容器来说，容器的开销真正小的移动操作会有些容器元素不能满足的注意条件。

考虑一下`std::array`，这是C++11中的新容器。`std::array`本质上是具有STL接口的内置数组。这与其他标准容器将内容存储在堆内存不同。存储具体数据在堆内存的容器，本身只保存了指向堆内存中容器内容的指针（真正实现当然更复杂一些，但是基本逻辑就是这样）。这个指针的存在使得在常数时间移动整个容器成为可能，只需要从源容器拷贝保存指向容器内容的指针到目标容器，然后将源指针置为空指针就可以了：

```c++
std::vector<Widget> vm1;

//把数据存进vw1
…

//把vw1移动到vw2。以常数时间运行。只有vw1和vw2中的指针被改变
auto vm2 = std::move(vm1);
```

![image-20230405171115798](/images/mdpic/image-20230405171115798.png)

`std::array`没有这种指针实现，数据就保存在`std::array`对象中：

```c++
std::array<Widget, 10000> aw1;

//把数据存进aw1
…

//把aw1移动到aw2。以线性时间运行。aw1中所有元素被移动到aw2
auto aw2 = std::move(aw1);
```

![image-20230405171139477](/images/mdpic/image-20230405171139477.png)



注意`aw1`中的元素被**移动**到了`aw2`中。假定`Widget`类的移动操作比复制操作快，移动`Widget`的`std::array`就比复制要快。所以`std::array`确实支持移动操作。但是使用`std::array`的移动操作还是复制操作都将花费线性时间的开销，因为每个容器中的元素终归需要拷贝或移动一次，这与“移动一个容器就像操作几个指针一样方便”的含义相去甚远。

另一方面，`std::string`提供了常数时间的移动操作和线性时间的复制操作。这听起来移动比复制快多了，但是可能不一定。许多字符串的实现采用了小字符串优化（*small string optimization*，SSO）。“小”字符串（比如长度小于15个字符的）存储在了`std::string`的缓冲区中，并没有存储在堆内存，移动这种存储的字符串并不必复制操作更快。

SSO的动机是大量证据表明，短字符串是大量应用使用的习惯。使用内存缓冲区存储而不分配堆内存空间，是为了更好的效率。然而这种内存管理的效率导致移动的效率并不必复制操作高，即使一个半吊子程序员也能看出来对于这样的字符串，拷贝并不比移动慢。

即使对于支持快速移动操作的类型，某些看似可靠的移动操作最终也会导致复制。[Item14](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item14.html)解释了原因，标准库中的某些容器操作提供了强大的异常安全保证，确保依赖那些保证的C++98的代码在升级到C++11且仅当移动操作不会抛出异常，从而可能替换操作时，不会不可运行。结果就是，即使类提供了更具效率的移动操作，而且即使移动操作更合适（比如源对象是右值），编译器仍可能被迫使用复制操作，因为移动操作没有声明`noexcept`。

因此，存在几种情况，C++11的移动语义并无优势：

- **没有移动操作**：要移动的对象没有提供移动操作，所以移动的写法也会变成复制操作。
- **移动不会更快**：要移动的对象提供的移动操作并不比复制速度更快。
- **移动不可用**：进行移动的上下文要求移动操作不会抛出异常，但是该操作没有被声明为`noexcept`。

值得一提的是，还有另一个场景，会使得移动并没有那么有效率：

- **源对象是左值**：除了极少数的情况外（例如[Item25](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item25.html)），只有右值可以作为移动操作的来源。

但是该条款的标题是假定移动操作不存在，成本高，未被使用。这就是通用代码中的典型情况，比如编写模板代码，因为你不清楚你处理的具体类型是什么。在这种情况下，你必须像出现移动语义之前那样，像在C++98里一样保守地去复制对象。“不稳定的”代码也是如此，即那些由于经常被修改导致类型特性变化的源代码。

但是，通常，你了解你代码里使用的类型，依赖他们的特性不变性（比如是否支持快速移动操作）。这种情况，你无需这个条款的假设，只需要查找所用类型的移动操作详细信息。如果类型提供了快速移动操作，并且在调用移动操作的上下文中使用对象，可以安全的使用快速移动操作替换复制操作。



> 



####	Item 30:熟悉完美转发失败的情况

C++11最显眼的功能之一就是完美转发功能。**完美**转发，太**完美**了！哎，开始使用，你就发现“完美”，理想与现实还是有差距。C++11的完美转发是非常好用，但是还是有完美转发失败的情况，这个条款就是使你熟悉这些情形。

在我们开始探索这些例外之前，有必要回顾一下`完美转发`的含义。转发只是一个函数将它的参数转递给另一个函数。第二个函数的目标是接受到的对象与第一个函数接收到的相同。这就排除了传值参数，因为它们是调用者传入的原始内容的副本。我们希望转发的函数能够使用原始传入的对象。指针参数也被排除在外，因为它们不想强迫调用者一定要传指针。我们面临的是通用目的转发时，我们将要处理的是引用类型的参数。

完美转发意味着我们不仅转发对象，**还转发它们的显著特征**：**它们的类型是左值还是右值？是 const 还是 volatile？**结合刚才提到的，我们将要处理是引用参数**，这意味着我们将使用通用引用，因为只有通用引用参数才包含实参的左值和右值信息**。

假定我们有一些函数`f`，然后想编写一个转发给它的函数（事实上是一个函数模板）。我们需要的核心看起来像是这样：

```c++
template<typename T>
void fwd(T&& param)             //接受任何实参
{
    f(std::forward<T>(param));  //转发给f
}
```

从本质上说，转发函数是通用的。例如`fwd`模板，接受任何类型的实参，并转发得到的任何东西。这种通用性的逻辑扩展是，**转发函数不仅是模板，而且是可变模板，因此可以接受任何数量的实参**。`fwd`的可变形式如下：

```c++
template<typename... Ts>
void fwd(Ts&&... params)            //接受任何实参
{
    f(std::forward<Ts>(params)...); //转发给f
}
```

这种形式你会在标准化容器置入函数（emplace functions）中和智能指针的工厂函数`std::make_unique`和`std::make_shared`中看到，当然还有其他一些地方。

给定我们的目标函数`f`和转发函数`fwd`，如果`f`使用某特定实参会执行某个操作，但是`fwd`使用相同的实参会执行不同的操作，**完美转发就会失败**

```c++
f( expression );        //调用f执行某个操作
fwd( expression );		//但调用fwd执行另一个操作，则fwd不能完美转发expression给f
```

导致这种失败的实参种类有很多。知道它们是什么以及如何解决它们很重要，因此让我们来看看无法做到完美转发的实参类型。

**花括号初始化：**

假定`f`这样声明：

```c++
void f(const std::vector<int>& v);
```

在这个例子中，用花括号初始化调用`f`通过编译，

```c++
f({ 1, 2, 3 });         //可以，“{1, 2, 3}”隐式转换为std::vector<int>
```

但是传递相同的列表初始化给fwd不能编译

```c++
fwd({ 1, 2, 3 });       //错误！不能编译
```

这是因为这是完美转发失效的一种情况。

所有这种错误有相同的原因。在对`f`的直接调用（例如`f({ 1, 2, 3 })`），编译器看看调用地传入的实参，看看`f`声明的形参类型。它们把调用地的实参和声明的实参进行比较，看看是否匹配，并且必要时执行隐式转换操作使得调用成功。在上面的例子中，从`{ 1, 2, 3 }`生成了临时`std::vector<int>`对象，因此`f`的形参`v`会绑定到`std::vector<int>`对象上。

当通过调用函数模板`fwd`间接调用`f`时，编译器不再把调用地传入给`fwd`的实参和`f`的声明中形参类型进行比较。而是**推导**传入给`fwd`的实参类型，然后比较推导后的实参类型和`f`的形参声明类型。当下面情况任何一个发生时，完美转发就会失败：

- **编译器不能推导出`fwd`的一个或者多个形参类型。** 这种情况下代码无法编译。
- **编译器推导“错”了`fwd`的一个或者多个形参类型。** 在这里，“错误”可能意味着`fwd`的实例将无法使用推导出的类型进行编译，但是也可能意味着使用`fwd`的推导类型调用`f`，与用传给`fwd`的实参直接调用`f`表现出不一致的行为。这种不同行为的原因可能是因为`f`是个重载函数的名字，并且由于是“不正确

在上面的`fwd({ 1, 2, 3 })`例子中，问题在于，将花括号初始化传递给未声明为`std::initializer_list`的函数模板形参，被判定为——就像标准说的——“非推导上下文”。简单来讲，这意味着编译器不准在对`fwd`的调用中推导表达式`{ 1, 2, 3 }`的类型，因为`fwd`的形参没有声明为`std::initializer_list`。对于`fwd`形参的推导类型被阻止，编译器只能拒绝该调用。

有趣的是，[Item2](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item2.html)说明了使用花括号初始化的`auto`的变量的类型推导是成功的。这种变量被视为`std::initializer_list`对象，在转发函数应推导出类型为`std::initializer_list`的情况，这提供了一种简单的解决方法——使用`auto`声明一个局部变量，然后将局部变量传进转发函数：



**0或者NULL作为空指针**

[Item8](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item8.html)说明当你试图传递`0`或者`NULL`作为空指针给模板时，**类型推导会出错**，会把传来的实参推导为一个整型类型（典型情况为`int`）而不是指针类型。结果就是不管是`0`还是`NULL`都不能作为空指针被完美转发。解决方法非常简单，传一个`nullptr`而不是`0`或者`NULL`。具体的细节，参考[Item8](https://cntransgroup.github.io/EffectiveModernCppChinese/3.MovingToModernCpp/item8.html)。



**仅有声明的整型 static const 数据成员**

通常，无需在类中定义整型`static const`数据成员；声明就可以了。这是因为编译器会对此类成员实行**常量传播（*const propagation*）**，因此消除了保留内存的需要。比如，考虑下面的代码：

```c++
class Widget {
public:
    static const std::size_t MinVals = 28;  //MinVal的声明
    …
};
…                                           //没有MinVals定义

std::vector<int> widgetData;
widgetData.reserve(Widget::MinVals);        //使用MinVals
```

这里，我们使用`Widget::MinVals`（或者简单点`MinVals`）来确定`widgetData`的初始容量，即使`MinVals`缺少定义。编译器通过将值28放入所有提到`MinVals`的位置来补充缺少的定义（就像它们被要求的那样）。没有为`MinVals`的值留存储空间是没有问题的。如果要使用`MinVals`的地址（例如，有人创建了指向`MinVals`的指针），则`MinVals`需要存储（这样指针才有可指向的东西），尽管上面的代码仍然可以编译，但是链接时就会报错，直到为`MinVals`提供定义。

按照这个思路，想象下`f`（`fwd`要转发实参给它的那个函数）这样声明：

```c++
void f(std::size_t val);
```

使用`MinVals`调用`f`是可以的，因为编译器直接将值28代替`MinVals`：

```c++
f(Widget::MinVals);         //可以，视为“f(28)”
```

不过如果我们尝试通过`fwd`调用`f`，事情不会进展那么顺利：

```c++
fwd(Widget::MinVals);       //错误！不应该链接
```

代码可以编译，但是不应该链接。如果这让你想到使用`MinVals`地址会发生的事，确实，底层的问题是一样的。

尽管代码中没有使用`MinVals`的地址，但是`fwd`的形参是通用引用，而引用，在编译器生成的代码中，通常被视作指针。**在程序的二进制底层代码中（以及硬件中）指针和引用是一样的**。在这个水平上，引用只是可以自动解引用的指针。在这种情况下，通过引用传递`MinVals`实际上与通过指针传递`MinVals`是一样的，因此，必须有内存使得指针可以指向。**通过引用传递的整型`static const`数据成员，通常需要定义它们**，这个要求可能会造成在不使用完美转发的代码成功的地方，使用等效的完美转发失败。**（这里意思是没有定义，完美转发就会失败）**

可能你也注意到了在上述讨论中我使用了一些模棱两可的词。代码“不应该”链接。引用“通常”被看做指针。传递整型`static const`数据成员“通常”要求定义。看起来就像有些事情我没有告诉你......

确实，根据标准，通过引用传递`MinVals`要求有定义。但不是所有的实现都强制要求这一点。所以，取决于你的编译器和链接器，你可能发现你可以在未定义的情况使用完美转发，恭喜你，但是这不是那样做的理由。为了具有可移植性，只要给整型`static const`提供一个定义，比如这样：

```c++
const std::size_t Widget::MinVals;  //在Widget的.cpp文件
```

注意定义中不要重复初始化（这个例子中就是赋值28）。但是不要忽略这个细节。如果你忘了，并且在两个地方都提供了初始化，编译器就会报错，提醒你只能初始化一次。



**重载函数和名称和模板名称**



**位域**





**总结**

在大多数情况下，完美转发工作的很好。你基本不用考虑其他问题。但是当其不工作时——当看起来合理的代码无法编译，或者更糟的是，虽能编译但无法按照预期运行时——了解完美转发的缺陷就很重要了。同样重要的是如何解决它们。在大多数情况下，都很简单。

> **请记住**

- ***当模板类型推导失败或者推导出错误类型，完美转发会失败***
- ***导致完美转发失败的实参种类有***
  - ***花括号初始化***
  - ***作为空指针的`0`或者`NULL`***
  - ***仅有声明的整型`static const`数据成员***
  - ***模板和重载函数的名字***
  - ***位域***



##	6.lambda表达式

*lambda*表达式是C++编程中的游戏规则改变者。这有点令人惊讶，因为它没有给语言带来新的表达能力。***lambda*可以做的所有事情都可以通过其他方式完成**。但是*lambda*是创建函数对象相当便捷的一种方法，对于日常的C++开发影响是巨大的。

没有*lambda*时，STL中的“`_if`”算法（比如，`std::find_if`，`std::remove_if`，`std::count_if`等）通常需要繁琐的谓词，但是当有*lambda*可用时，这些算法使用起来就变得相当方便。

用比较函数（比如，`std::sort`，`std::nth_element`，`std::lower_bound`等）来自定义算法也是同样方便的。在STL外，*lambda*可以快速创建`std::unique_ptr`和`std::shared_ptr`的自定义删除器（见[Item18](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item18.html)和[19](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item19.html)），并且使线程API中条件变量的谓词指定变得同样简单（参见[Item39](https://cntransgroup.github.io/EffectiveModernCppChinese/7.TheConcurrencyAPI/item39.html)）。除了标准库，*lambda*有利于即时的回调函数，接口适配函数和特定上下文中的一次性函数。*lambda*确实使C++成为更令人愉快的编程语言。

与*lambda*相关的词汇可能会令人疑惑，这里做一下简单的回顾：

- ***lambda\*表达式**（*lambda expression*）就是一个表达式。下面是部分源代码。在

  ```c++
  std::find_if(container.begin(), container.end(),
               [](int val){ return 0 < val && val < 10; });   //译者注：本行高亮
  ```

  中，代码的高亮部分就是*lambda*。

- **闭包**（*enclosure*）是*lambda*创建的运行时对象。依赖捕获模式，闭包持有被捕获数据的副本或者引用。在上面的`std::find_if`调用中，闭包是作为第三个实参在运行时传递给`std::find_if`的对象。

- **闭包类**（*closure class*）是从中实例化闭包的类。每个*lambda*都会使编译器生成唯一的闭包类。*lambda*中的语句成为其闭包类的成员函数中的可执行指令。

*lambda*通常被用来创建闭包，该闭包仅用作函数的实参。上面对`std::find_if`的调用就是这种情况。然而，闭包通常可以拷贝，所以可能有多个闭包对应于一个*lambda*。比如下面的代码：

```c++
{
    int x;                                  //x是局部对象
    …

    auto c1 =                               //c1是lambda产生的闭包的副本
        [x](int y) { return x * y > 55; };

    auto c2 = c1;                           //c2是c1的拷贝

    auto c3 = c2;                           //c3是c2的拷贝
    …
}
```

`c1`，`c2`，`c3`都是*lambda*产生的闭包的副本。

非正式的讲，模糊*lambda*，闭包和闭包类之间的界限是可以接受的。但是，在随后的Item中，区分什么存在于编译期（*lambdas* 和闭包类），什么存在于运行时（闭包）以及它们之间的相互关系是重要的。



####	Item 31:避免使用默认（隐式）捕获模式

C++11中有两种默认捕获模式：按引用和按值。

默认按引用捕获可能导致空悬引用

默认按值捕获会误导你以为自己对这个问题免疫，并且会让你误以为闭包是自给自足的

按引用捕获会导致闭包包含对在 lambda 定义的作用域中可用的局部变量或参数的引 用。如果闭包的生命周期超过局部变量或参数的生命周期，那么在闭包中引用就会悬挂。

举个例子，假如我们有元素是过滤函数（filtering function）的一个容器，该函数接受一个`int`，并返回一个`bool`，该`bool`的结果表示传入的值是否满足过滤条件：

```c++
using FilterContainer =                     //“using”参见条款9，
    std::vector<std::function<bool(int)>>;  //std::function参见条款2

FilterContainer filters;                    //过滤函数
```

我们可以添加一个过滤器，用来过滤掉5的倍数：

```c++
filters.emplace_back(                       //emplace_back的信息见条款42
    [](int value) { return value % 5 == 0; }
);
```

然而我们可能需要的是能够在运行期计算除数（divisor），即不能将5硬编码到*lambda*中。因此添加的过滤器逻辑将会是如下这样：

```c++
void addDivisorFilter()
{
    auto calc1 = computeSomeValue1();
    auto calc2 = computeSomeValue2();

    auto divisor = computeDivisor(calc1, calc2);

    filters.emplace_back(                               //危险！对divisor的引用
        [&](int value) { return value % divisor == 0; } //将会悬空！
    );
}
```

这个代码实现是一个定时炸弹。***lambda*对局部变量`divisor`进行了引用**，但该变量的生命周期会在`addDivisorFilter`返回时结束，刚好就是在语句`filters.emplace_back`返回之后。因此添加到`filters`的函数添加完，该函数就死亡了。使用这个过滤器（就是那个添加进`filters`的函数）会导致未定义行为，这是由它被创建那一刻起就决定了的。

现在，同样的问题也会出现在`divisor`的显式按引用捕获。

```c++
filters.emplace_back(
    [&divisor](int value) 			    //危险！对divisor的引用将会悬空！
    { return value % divisor == 0; }
);
```

但通过显式的捕获，能更容易看到*lambda*的生存是依赖于变量`divisor`的生命周期的。同时，写下“divisor”这个名字能够提醒我们要注意确保`divisor`的生命周期至少跟*lambda*闭包一样长。比起“`[&]`”传达的意思，显式捕获能让人更容易想起“确保没有悬空变量”。

如果你知道一个闭包将会被马上使用（例如被传入到一个STL算法中）并且不会被拷贝，那么在它的*lambda*被创建的环境中，将不会有持有的引用比局部变量和形参活得长的风险。在这种情况下，你可能会说，没有悬空引用的危险，就不需要避免使用默认的引用捕获模式。例如，我们的过滤*lambda*只会用做C++11中`std::all_of`的一个实参，返回满足条件的所有元素：

```c++
template<typename C>
void workWithContainer(const C& container)
{
    auto calc1 = computeSomeValue1();               //同上
    auto calc2 = computeSomeValue2();               //同上
    auto divisor = computeDivisor(calc1, calc2);    //同上

    using ContElemT = typename C::value_type;       //容器内元素的类型
    using std::begin;                               //为了泛型，见条款13
    using std::end;

    if (std::all_of(                                //如果容器内所有值都为
            begin(container), end(container),       //除数的倍数
            [&](const ContElemT& value)
            { return value % divisor == 0; })
        ) {
        …                                           //它们...
    } else {
        …                                           //至少有一个不是的话...
    }
}
```

的确如此，这是安全的做法，但这种安全是不确定的。如果发现*lambda*在其它上下文中很有用（例如作为一个函数被添加在`filters`容器中），然后拷贝粘贴到一个`divisor`变量已经死亡，但闭包生命周期还没结束的上下文中，你又回到了悬空的使用上了。同时，在该捕获语句中，也没有特别提醒了你注意分析`divisor`的生命周期。

从长期来看，**显式列出*lambda*依赖的局部变量和形参**，是更加符合软件工程规范的做法。

额外提一下，C++14支持了在*lambda*中使用`auto`来声明变量，上面的代码在C++14中可以进一步简化，`ContElemT`的别名可以去掉，`if`条件可以修改为：

```c++
if (std::all_of(begin(container), end(container),
               [&](const auto& value)               // C++14
               { return value % divisor == 0; }))			
```

一个解决问题的方法是，`divisor`默认按值捕获进去，也就是说可以按照以下方式来添加*lambda*到`filters`：

```c++
filters.emplace_back( 							    //现在divisor不会悬空了
    [=](int value) { return value % divisor == 0; }
);
```

这足以满足本实例的要求，但在通常情况下，按值捕获并不能完全解决悬空引用的问题。这里的问题是如果你按值捕获的是一个指针，你将该指针拷贝到*lambda*对应的闭包里，但这样并不能避免*lambda*外`delete`这个指针的行为，从而导致你的副本指针变成悬空指针。

也许你要抗议说：“这不可能发生。看过了[第4章](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item18.html)，我对智能指针的使用非常热衷。只有那些失败的C++98的程序员才会用裸指针和`delete`语句。”这也许是正确的，但却是不相关的，**因为事实上你的确会使用裸指针，也的确存在被你`delete`的可能性**。**只不过在现代的C++编程风格中，不容易在源代码中显露出来而已。**

假设在一个`Widget`类，可以实现向过滤器的容器添加条目：

```c++
class Widget {
public:
    …                       //构造函数等
    void addFilter() const; //向filters添加条目
private:
    int divisor;            //在Widget的过滤器使用
};
```

这是`Widget::addFilter`的定义：

```c++
void Widget::addFilter() const
{
    filters.emplace_back(
        [=](int value) { return value % divisor == 0; }
    );
}	
```

这个做法看起来是安全的代码。*lambda*依赖于`divisor`，但默认的按值捕获确保`divisor`被拷贝进了*lambda*对应的所有闭包中，对吗？

**错误，完全错误。**

**捕获只能应用于*lambda*被创建时所在作用域里的`non-static`局部变量（包括形参）**。在`Widget::addFilter`的视线里，`divisor`并不是一个局部变量，而是`Widget`类的一个成员变量。它不能被捕获。而如果默认捕获模式被删除，代码就不能编译了：

```c++
void Widget::addFilter() const
{
    filters.emplace_back(                               //错误！
        [](int value) { return value % divisor == 0; }  //divisor不可用
    ); 
} 
```

**所以如果默认按值捕获不能捕获`divisor`，而不用默认按值捕获代码就不能编译，这是怎么一回事呢？**

解释就是这里隐式使用了一个原始指针：`this`。每一个`non-static`成员函数都有一个`this`指针，每次你使用一个类内的数据成员时都会使用到这个指针。例如，在任何`Widget`成员函数中，编译器会在内部将`divisor`替换成`this->divisor`。在默认按值捕获的`Widget::addFilter`版本中，

```c++
void Widget::addFilter() const
{
    filters.emplace_back(
        [=](int value) { return value % divisor == 0; }
    );
}
```

**真正被捕获的是`Widget`的`this`指针，而不是`divisor`**。编译器会将上面的代码看成以下的写法：

```c++
void Widget::addFilter() const
{
    auto currentObjectPtr = this;

    filters.emplace_back(
        [currentObjectPtr](int value)
        { return value % currentObjectPtr->divisor == 0; }
    );
}
```

明白了这个就相当于明白了*lambda*闭包的生命周期与`Widget`对象的关系，闭包内含有`Widget`的`this`指针的拷贝。特别是考虑以下的代码，参考[第4章](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item18.html)的内容，只使用智能指针：

```c++
using FilterContainer = 					//跟之前一样
    std::vector<std::function<bool(int)>>;

FilterContainer filters;                    //跟之前一样

void doSomeWork()
{
    auto pw =                               //创建Widget；std::make_unique
        std::make_unique<Widget>();         //见条款21

    pw->addFilter();                        //添加使用Widget::divisor的过滤器

    …
}                                           //销毁Widget；filters现在持有悬空指针！
```

当调用`doSomeWork`时，就会创建一个过滤器，其生命周期依赖于由`std::make_unique`产生的`Widget`对象，即一个含有指向`Widget`的指针——`Widget`的`this`指针——的过滤器。这个过滤器被添加到`filters`中，但当`doSomeWork`结束时，`Widget`会由管理它的`std::unique_ptr`来销毁（见[Item18](https://cntransgroup.github.io/EffectiveModernCppChinese/4.SmartPointers/item18.html)）。从这时起，`filter`会含有一个存着悬空指针的条目。

这个特定的问题可以通过给你想捕获的数据成员做一个局部副本，然后捕获这个副本去解决：

```c++
void Widget::addFilter() const
{
    auto divisorCopy = divisor;                 //拷贝数据成员

    filters.emplace_back(
        [divisorCopy](int value)                //捕获副本
        { return value % divisorCopy == 0; }	//使用副本
    );
}
```

事实上如果采用这种方法，默认的按值捕获也是可行的。

```c++
void Widget::addFilter() const
{
    auto divisorCopy = divisor;                 //拷贝数据成员

    filters.emplace_back(
        [=](int value)                          //捕获副本
        { return value % divisorCopy == 0; }	//使用副本
    );
}
```

但为什么要冒险呢？当一开始你认为你捕获的是`divisor`的时候，默认捕获模式可能会意外地捕获this指针。

在C++14中，一个更好的捕获成员变量的方式时使用通用的*lambda*捕获：

```c++
void Widget::addFilter() const
{
    filters.emplace_back(                   //C++14：
        [divisor = divisor](int value)      //拷贝divisor到闭包
        { return value % divisor == 0; }	//使用这个副本
    );
}
```

**这种通用的*lambda*捕获并没有默认的捕获模式**，因此在C++14中，本条款的建议——**避免使用默认捕获模式**——仍然是成立的。

使用默认的按值捕获还有另外的一个缺点，它们暗示了相关的闭包是独立的并且不受外部数据变化的影响。**一般来说，这是不对的**。*lambda*可能会依赖局部变量和形参（它们可能被捕获），还有**静态存储生命周期（static storage duration）**的对象。**这些对象定义在全局空间或者命名空间，或者在类、函数、文件中声明为`static`。这些对象也能在*lambda*里使用，但它们不能被捕获。但默认按值捕获可能会因此误导你，**让你以为捕获了这些变量**。参考下面版本的`addDivisorFilter`函数：

```c++
void addDivisorFilter()
{
    static auto calc1 = computeSomeValue1();    //现在是static
    static auto calc2 = computeSomeValue2();    //现在是static
    static auto divisor =                       //现在是static
    computeDivisor(calc1, calc2);

    filters.emplace_back(
        [=](int value)                          //什么也没捕获到！
        { return value % divisor == 0; }        //引用上面的static
    );

    ++divisor;                                  //调整divisor
}
```

随意地看了这份代码的读者可能看到“`[=]`”，就会认为“好的，*lambda*拷贝了所有使用的对象，因此这是独立的”。**但其实不独立**。这个*lambda*没有使用任何的`non-static`局部变量，所以它没有捕获任何东西。**然而*lambda*的代码引用了`static`变量`divisor`**，在每次调用`addDivisorFilter`的结尾，`divisor`都会递增，通过这个函数添加到`filters`的所有*lambda*都展示新的行为（分别对应新的`divisor`值）。这个*lambda*是通过引用捕获`divisor`，这和默认的按值捕获表示的含义有着直接的矛盾。如果你一开始就避免使用默认的按值捕获模式，你就能解除代码的风险。



> **请记住**

- ***默认的按引用捕获可能会导致悬空引用（闭包的生命周期比捕获的对象生命周期还长）***
- ***默认的按值捕获对于悬空指针很敏感（尤其是`this`指针），并且它会误导人产生lambda是独立的想法***
- ***作用域内的`static`变量能直接被 lambda使用，使用默认按值捕获会误导你以为自己拷贝了它，它是独立的，事实恰恰相反***





####	Item 32:使用初始化捕获来移动对象到闭包中

在某些场景下，按值捕获和按引用捕获都不是你所想要的。如果你有一个只能被移动的对象（例如`std::unique_ptr`或`std::future`）要进入到闭包里，使用C++11是无法实现的。如果你要复制的对象复制开销非常高，但移动的成本却不高（例如标准库中的大多数容器），并且你希望的是宁愿移动该对象到闭包而不是复制它。然而C++11却无法实现这一目标。

但那是C++11的时候。到了C++14就另一回事了，**它能支持将对象移动到闭包中**。如果你的编译器兼容支持C++14，那么请愉快地阅读下去。如果你仍然在使用仅支持C++11的编译器，也请愉快阅读，因为在C++11中有很多方法可以实现近似的移动捕获。

**缺少移动捕获被认为是C++11的一个缺点**，直接的补救措施是将该特性添加到C++14中，但标准化委员会选择了另一种方法。他们引入了一种新的捕获机制，该机制非常灵活，移动捕获是它可以执行的技术之一。新功能被称作**初始化捕获（*init capture*）**，C++11捕获形式能做的所有事它几乎可以做，甚至能完成更多功能。你不能用初始化捕获表达的东西是默认捕获模式，但[Item31](https://cntransgroup.github.io/EffectiveModernCppChinese/6.LambdaExpressions/item31.html)说明提醒了你无论如何都应该远离默认捕获模式。（在C++11捕获模式所能覆盖的场景里，初始化捕获的语法有点不大方便。因此在C++11的捕获模式能完成所需功能的情况下，使用它是完全合理的）。

使用初始化捕获可以让你指定：

1. 从lambda生成的闭包类中的**数据成员名称**；
2. 初始化该成员的**表达式**；

这是使用初始化捕获将`std::unique_ptr`移动到闭包中的方法：

```c++
class Widget {                          //一些有用的类型
public:
    …
    bool isValidated() const;
    bool isProcessed() const;
    bool isArchived() const;
private:
    …
};

auto pw = std::make_unique<Widget>();   //创建Widget；使用std::make_unique
                                        //的有关信息参见条款21

…                                       //设置*pw

auto func = [pw = std::move(pw)]        //使用std::move(pw)初始化闭包数据成员
            { return pw->isValidated()
                     && pw->isArchived(); };

```

高亮的文本包含了初始化捕获的使用（译者注：高亮了“`pw = std::move(pw)`”），“`=`”的左侧是指定的闭包类中数据成员的名称，右侧则是初始化表达式。有趣的是，“`=`”左侧的作用域不同于右侧的作用域。左侧的作用域是闭包类，右侧的作用域和*lambda*定义所在的作用域相同。在上面的示例中，“`=`”左侧的名称`pw`表示闭包类中的数据成员，而右侧的名称`pw`表示在*lambda*上方声明的对象，即由调用`std::make_unique`去初始化的变量。因此，“`pw = std::move(pw)`”的意思是“在闭包中创建一个数据成员`pw`，并使用将`std::move`应用于局部变量`pw`的结果来初始化该数据成员”。







> **请记住**

- ***使用C++14的初始化捕获将对象移动到闭包中***
- ***在C++11中，通过手写类或 `std::bind` 的方式来模拟初始化捕获***



####	Item 33:对auto&&形参使用decltype来std::forward

**泛型lambda**（*generic lambdas*）是C++14中最值得期待的特性之一——**因为在*lambda*的形参中可以使用`auto`关键字**。这个特性的**实现是非常直截了当的：即在闭包类中的`operator()`函数是一个函数模版**。例如存在这么一个*lambda*，

```c++
auto f = [](auto x){ return func(normalize(x)); };
```

对应的闭包类中的函数调用操作符看来就变成这样：

```c++
class SomeCompilerGeneratedClassName {
public:
    template<typename T>                //auto返回类型见条款3
    auto operator()(T x) const
    { return func(normalize(x)); }
    …                                   //其他闭包类功能
};
```

在这个样例中，*lambda*对变量`x`做的唯一一件事就是把它转发给函数`normalize`。如果函数`normalize`对待左值右值的方式不一样，这个*lambda*的实现方式就不大合适了，因为即使传递到*lambda*的实参是一个右值，*lambda*传递进`normalize`的总是一个左值（形参`x`）。

实现这个*lambda*的正确方式是把`x`完美转发给函数`normalize`。这样做需要对代码做两处修改。首先，`x`需要改成通用引用（见[Item24](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item24.html)），其次，需要使用`std::forward`将`x`转发到函数`normalize`（见[Item25](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item25.html)）。理论上，这都是小改动：

```c++
auto f = [](auto&& x)
         { return func(normalize(std::forward<???>(x))); };
```

在理论和实际之间存在一个问题：你应该传递给`std::forward`的什么类型，即确定我在上面写的`???`该是什么。

一般来说，当你在使用完美转发时，你是在一个接受类型参数为`T`的模版函数里，所以你可以写`std::forward<T>`。但在泛型*lambda*中，没有可用的类型参数`T`。**在*lambda*生成的闭包里，模版化的`operator()`函数中的确有一个`T`，但在*lambda*里却无法直接使用它**，所以也没什么用。

[Item28](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item28.html)解释过如果一个左值实参被传给通用引用的形参，那么形参类型会变成左值引用。传递的是右值，形参就会变成右值引用。这意味着在这个*lambda*中，可以通过检查形参`x`的类型来确定传递进来的实参是一个左值还是右值，`decltype`就可以实现这样的效果（见[Item3](https://cntransgroup.github.io/EffectiveModernCppChinese/1.DeducingTypes/item3.html)）。传递给*lambda*的是一个左值，`decltype(x)`就能产生一个左值引用；如果传递的是一个右值，`decltype(x)`就会产生右值引用。

[Item28](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item28.html)也解释过在调用`std::forward`时，惯例决定了类型实参是左值引用时来表明要传进左值，类型实参是非引用就表明要传进右值。在前面的*lambda*中，如果`x`绑定的是一个左值，**`decltype(x)`就能产生一个左值引用。这符合惯例。然而如果`x`绑定的是一个右值，`decltype(x)`就会产生右值引用**，而不是常规的非引用。

再看一下[Item28](https://cntransgroup.github.io/EffectiveModernCppChinese/5.RRefMovSemPerfForw/item28.html)中关于`std::forward`的C++14实现：

```c++
template<typename T>                        //在std命名空间
T&& forward(remove_reference_t<T>& param)
{
    return static_cast<T&&>(param);
}
```

如果用户想要完美转发一个`Widget`类型的右值时，它会使用`Widget`类型（即非引用类型）来实例化`std::forward`，然后产生以下的函数：

```c++
Widget&& forward(Widget& param)             //当T是Widget时的std::forward实例
{
    return static_cast<Widget&&>(param);
}
```

思考一下如果用户代码想要完美转发一个`Widget`类型的右值，但没有遵守规则将`T`指定为非引用类型，而是将`T`指定为右值引用，这会发生什么。也就是，思考将`T`换成`Widget&&`会如何。在`std::forward`实例化、应用了`std::remove_reference_t`后，引用折叠之前，`std::forward`看起来像这样：

```c++
Widget&& && forward(Widget& param)          //当T是Widget&&时的std::forward实例
{                                           //（引用折叠之前）
    return static_cast<Widget&& &&>(param);
}
```

应用了引用折叠之后（右值引用的右值引用变成单个右值引用），代码会变成：

```c++
Widget&& forward(Widget& param)             //当T是Widget&&时的std::forward实例
{                                           //（引用折叠之后）
    return static_cast<Widget&&>(param);
}
```

对比这个实例和用`Widget`设置`T`去实例化产生的结果，它们完全相同。表明用右值引用类型和用非引用类型去初始化`std::forward`产生的相同的结果。

那是一个很好的消息，因为当传递给*lambda*形参`x`的是一个右值实参时，`decltype(x)`可以产生一个右值引用。前面已经确认过，把一个左值传给*lambda*时，`decltype(x)`会产生一个可以传给`std::forward`的常规类型。而现在也验证了对于右值，把`decltype(x)`产生的类型传递给`std::forward`是非传统的，不过它产生的实例化结果与传统类型相同。所以无论是左值还是右值，把`decltype(x)`传递给`std::forward`都能得到我们想要的结果，因此*lambda*的完美转发可以写成：

```c++
auto f =
    [](auto&& param)
    {
        return
            func(normalize(std::forward<decltype(param)>(param)));
    };
```

再加上6个点，就可以让我们的*lambda*完美转发接受多个形参了，因为C++14中的*lambda*也可以是可变形参的：

```c++
auto f =
    [](auto&&... params)
    {
        return
            func(normalize(std::forward<decltype(params)>(params)...));
    };
```



> **请记住**

- ***对`auto&&`形参使用 `decltype`以`std::forward`它们。***



####	Item 34:考虑lambad而非std::bind



当`bind`在2005年被非正式地添加到C++中时，与1998年的前身相比有了很大的改进。 在C++11中增加了*lambda*支持，这使得`std::bind`几乎已经过时了，**从C++14开始，更是没有很好的用例了**。

> **请记住**

- ***与使用`std::bind`相比，lambda更易读，更具有表达力并且可能更高效***

- ***只有在C++11中，`std::bind`可能对实现***

  - ***移动捕获***
  - ***绑定带有模板化函数调用运算符***

  ***的对象时会很有用***









##	改进



####	Item 41:针对可复制的形参，在移动成本低并且一定会被复制的前提下，考虑将其按值传递





> **请记住**

- ***对于可拷贝，移动开销低，而且一定会被拷贝的形参，按值传递效率基本与按引用传递效率一致，而且易于实现，还生成更少的目标代码***
- ***通过拷贝形参可能比通过赋值拷贝形参开销大的多***
- ***按值传递会引起切片问题，所以基类型别不适用于按值传递***









####	Item 42:考虑就地创建而非插入





> **请记住：**

- ***原则上，置入函数有时会比插入函数高效，并且不会更差。***
- ***实际上，当以下条件满足时，置入函数更快：***
  - ***值被构造到容器中，而不是直接赋值；***
  - ***传入的类型与容器的元素类型不一致；***
  - ***容器不拒绝已经存在的重复值。***
- ***置入函数可能执行插入函数拒绝的类型转换。***


