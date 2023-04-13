---
title: OSTEP
date: 2023-04-13 14:17:12
tags:
    - 操作系统
---
#	1.虚拟化



##	04 抽象:进程

> **关键问题：如何提供有许多CPU可用的假象？**
>
> 虽然只有少量的物理CPU可用，但是操作系统如何提供几乎有无数个CPU可用的假象？

​	操作系统通过虚拟化`virtualizing`CPU来提供这种假象。通过让一个进程只运行一个时间片，然后切换到其他进程，操作系统提供了存在多个虚拟CPU的假象。这就是**时分共享（time sharing）**CPU技术，允许用户如愿运行多个并非进程

​	要实现CPU的虚拟化，且要实现的好，OS需要一些低级机制以及一些高级智能。我们将低级机制称为机制。机制是一些低级方法和协议，实现了所需的功能。例如，稍后学习如何实现**上下文切换（context switch）**,它让OS能够停止运行一个程序，并开始在给定的CPU上运行另一个程序。所有现代OS都采用了这种分时机制。

![image-20230327132632519](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230327132632519.png)

​	在这些机制以上，OS中有一些智能以**策略（policy）**的形式存在。策略是在OS内做出某种决定的算法。例如；给定一组可能的程序要在CPU上运行，OS应该运行哪个程序？操作系统中的**调度策略（scheduling policy）**会做出这样的决定，可能利用历史信息，工作负载知识以及性能指标来做出决定



####	1.抽象:进程

操作系统为正在进行的程序提供的抽象，就是所谓的**进程（process）**



为了理解构成进程的是什么，我们必须理解它的**机器状态（machine state）**：

- 程序在运行时可以读取或更新的内容
- 在任何时刻，机器的哪些部分对执行该程序很重要？

进行的机器状态有一个明显的组成成分，就是它的内存；指令存在内存中，正在运行的程序读取和写入的数据也在内存中。因此进程可以访问的内存（称为**地址空间**，**address space**）是该进程的一部分

进程的机器状态的另一部分是**寄存器**。许多指令明确地读取和更新寄存器，因此显然，它们对于执行该进程很重要

![image-20230327135118691](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230327135118691.png)



####	2.进程API

几乎所有现代操作系统都以某种形式提供这些API

- 创建（create）
- 销毁（destroy）
- 等待（wait）
- 其他控制
- 状态（statu）



####	3.进程创建:更多细节

![image-20230317224529699](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230317224529699.png)



在早期的（或简单的）操作系统中，加载过程**尽早（eagerly）**完成，即在运行程序之前全部完成。现代操作系统**惰性（lazily）**执行该过程，即仅在程序执行期间需要加载的代码或数据片段，才会加载。



要真正理解代码和数据的惰性加载是如何工作的，必须更多地了解**分页**和**交换**的机制，这是我们将来讨论内存虚拟化时要涉及的主题。



将代码和静态数据加载到内存后，操作系统在运行此进程之前还需要执行其他一些操作。必须为程序的**运行时栈（run-time stack 或 stack 又又别称：执行栈，控制栈，机器栈）**分配一些内存。

![cc831af51cec9c7b20c8bd94ac79b4f](C:\Users\guoxiang\AppData\Local\Temp\WeChat Files\cc831af51cec9c7b20c8bd94ac79b4f.png)



C程序使用stack存放局部变量，函数参数和返回地址。OS分配这些内存，并提供给进程。OS也可能会用参数初始化stack。具体来说，它会将参数填入main()函数，即argc和argv数组。



OS也可能为程序的**堆（heap）**分配一些内存；还将执行一些其他初始化任务，特别是**输入/输出（I/O）**相关的任务



通过将代码和静态数据加载到内存中，通过创建和初始化以及执行与I/O设置相关的其他工作，OS现在终于为程序执行搭好了舞台。然后它有最后一项任务：启动程序，在入口处运行，即main()。通过跳转到main()例程，OS将CPU的控制权转移到新创建的进程中，从而程序开始执行。



####	4.进程状态



进程可以处于以下三种状态之一：

- **运行（running）**
- **就绪（ready）**
- **阻塞（blocked）**



![image-20230317225754765](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230317225754765.png)



####	5.数据结构

OS是一个程序，和其他程序一样，它有一些关键的数据结构来跟踪各种相关的信息。例如，为了跟踪每个进程的状态，OS可能会为所有就绪的进程保留某种**进程列表（process list）**，以及跟踪当前正在运行的进程的一些附加信息。OS还必须以某种方式跟踪被阻塞的进程。当I/O事情完成时，OS应该确保唤醒正确的进程，让它准备好再次运行。



处理运行，就绪，阻塞之外，还有其他一些进程可以处于的状态。有时候系统会有一个**初始（initial）状态**，表示进程在创建时处于的状态。另外，一个程序可以处于已退出但尚未清理的**最终（final）状态**（在基于UNIX的系统中，这称为**僵尸状态**），这个最终状态非常有用，因为它允许其他进程（通常是创建进程的父进程）检查进程的返回代码，并查看刚刚完成的进程是否成功执行（通常，程序成功完成任务时返回零，否则返回非零）



![image-20230327173749301](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230327173749301.png)











##	05 插叙:进程API

> 本章将介绍系统实践方面的内容，包括OS的API及其使用方式。
>
> **关键问题：如何创建并控制进程**
>
> OS应该提供怎样的接口来创建及控制进程？如何设计这些接口才能既方便又实用？



####	1.fork()系统调用



####	2.wait()系统调用



####	3.exec()系统调用



####	4.为什么这么设计API



####	5.其他API





##	06 机制：受限直接执行

> 为了虚拟化CPU，操作系统需要以某种方式让许多任务共享物理CPU，让它们看起来像是同时运行，基本思想很简单：运行一个进程一段时间，然后运行另一个进程，如此轮换。通过以这种方式**时分共享（time sharing）**CPU，就实现了虚拟化。

然而，在构建这样的虚拟化机制时存在一些挑战

- 性能

  如何在不增加系统开销的情况下实现虚拟化？

- 控制权

  如何有效地运行进程，同时保留对CPU的控制？

在保持控制权的同时获得高性能，这是构建OS的主要挑战之一

![image-20230327194725913](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230327194725913.png)



####	1.基本技巧：受限直接执行

为了使程序尽可能快地运行，OS开发人员想出了一种技术，我们称之为**受限的直接执行（limited direct execution）**。这个概念的“直接执行”部分很简单：只需直接CPU上运行程序即可：

![image-20230327195231806](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230327195231806.png)

这种方法在我们虚拟化CPU时产生了一些问题：

- 如果我们只运行一个程序，OS怎么能确保程序不做任何我们不希望它做的事情，同时高效地运行它？
- 当我们运行一个程序时，OS如何让它停下来并切换到另一个进程，从而实现虚拟化CPU所需的时空共享？



####	2.问题1：受限制的操作

采用受保护的控制权转移，来实现进程的受限操作。

![image-20230327200059414](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230327200059414.png)

- 用户模式（user mode）：在该模式下运行的代码会受到限制。例如；进程不能发出I/O请求。这样做会导致处理器引发异常，OS可能会终止进程
- 内核模式（kernel mode）：OS就以这种模式运行。在该模式下，运行的代码可以做它喜欢的事情，包括特权操作；如发出I/O请求和执行所有类型的受限指令

如果用户希望执行某种特权操作（如从磁盘读取），应该怎么做？

为了实现这一点，几乎所有的现代硬件都提供了用户程序执行**系统调用**的能力

要执行系统调用，程序必须执行特殊的**陷阱（trap）指令**。该指令同时跳入内核并将特权级别提升到内核模式。一旦进入内核，系统就可以执行任何需要的特权操作，从而为调用进程执行所需的工作。完成后，OS调用一个特殊的**陷阱返回（return -from-trap）指令**，该指令返回到发起调用的用户程序中，同时将特权级别降低，回到用户模式

![image-20230327201321859](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230327201321859.png)

还有一个重要的细节没讨论：陷阱如何知道在 OS 内运行哪些代码？

显然，发起调用的 过程不能指定要跳转到的地址（就像你在进行过程调用时一样），这样做让程序可以跳转到 内核中的任意位置，这显然是一个糟糕的主意（想象一下跳到访问文件的代码，但在权限 检查之后。实际上，这种能力很可能让一个狡猾的程序员令内核运行任意代码序列）。 因此内核必须谨慎地控制在陷阱上执行的代码。 

内核通过在启动时设置**陷阱表（trap table）**来实现。当机器启动时，它在特权（内核）模式下执行，因此可以根据需要自由配置机器硬件。操作系统做的第一件事，就是告诉硬件在 发生某些异常事件时要运行哪些代码。例如，当发生硬盘中断，发生键盘中断或程序进行系 统调用时，应该运行哪些代码？操作系统通常通过某种特殊的指令，通知硬件这些陷阱处理 程序的位置。一旦硬件被通知，它就会记住这些处理程序的位置，直到下一次重新启动机器， 并且硬件知道在发生系统调用和其他异常事件时要做什么（即跳转到哪段代码）。 最后再插一句：能够执行指令来告诉硬件陷阱表的位置是一个非常强大的功能。因此， 你可能已经猜到，这也是一项特权（privileged）操作。如果你试图在用户模式下执行这个 指令，硬件不会允许，你可能会猜到会发生什么（提示：再见，违规程序）。思考问题：如 果可以设置自己的陷阱表，你可以对系统做些什么？你能接管机器吗？

![image-20230327201642422](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230327201642422.png)



####	3.问题2：在进程之间切换

如果一个进程在CPU上运行，就意味着OS没有在CPU上运行。

OS如何重新获得CPU的**控制权（regain control）**,以便它可以在进程之间切换？



- **协作方式：等待系统调用**

  过去的某些系统采用的一种方式，在这种风格下，OS相信系统的进程会合理运行。运行时间长的进程被假定会定期放弃CPU，以便OS可以决定其他任务。

  大多数进程通过系统调用，将CPU的控制权转移给OS。例如打开文件并随后读取文件，或者创建进程。这样的系统通常包括一个显示的yield系统调用，它什么也不做，只是将控制权交给OS，以便系统可以运行其他进程。

  如果某个进程进入无限循环，并且从不进行系统调用，会发生什么情况？

- **非协作方式：操作系统进行控制**

  如果进程拒绝进行系统调用（也不出错），从而将控制权交还给OS，那么OS无法做任何事情。在协作模式下，当进程陷入无限循环时，唯一的办法就是重启电脑。

  如何在没有协作的情况下获得控制权？

  答案很简单：**时钟中断（timer interrupt）**。时钟设备可以编程为每隔几毫秒产生一次中断。产生中断时，当前正在运行的进程停止，OS中预先配置的中断处理程序（interrupt handler）会运行。此时，OS重新获得CPU的控制权，因此可以做它想做的事：停止当前进程，并启动另一个进程。

  ![image-20230327203535076](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230327203535076.png)



**保存和恢复上下文**

既然OS已经重新获得了控制权，无论通过系统调用协作，还是通过时钟中断强制执行，都必须决定：是继续允许当前正在运行的进程，还是切换到另一个进程。这个决定是由**调度程序（scheduler）**做出的，它是OS的一部分



如果决定进行切换，OS就会执行一些底层代码，即所谓的**上下文切换（context switch）**。上下文切换在概念上很简单：操作系统要做的就是为当前正在执行的进程保存一些寄存器 的值（例如，到它的内核栈），并为即将执行的进程恢复一些寄存器的值（从它的内核栈）。 这样一来，操作系统就可以确保最后执行从陷阱返回指令时，不是返回到之前运行的进程， 而是继续执行另一个进程。







####	4.担心并发吗

在系统调用期间发生时钟中断会发生什么？ 处理一个中断时发生另一个中断会发生什么？

这正是第二部分关于并发的主题。

![image-20230327205307488](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230327205307488.png)



####	5.小结：

我们已经表述了一些实现CPU虚拟化的关键底层机制，并将其统称为受限直接执行（limited direct execution）。基本思路很简单；就让你想运行的程序在CPU上运行，但首先确保设置好硬件，以便在没有OS帮助的情况下限制进程可以执行的操作（用户模式和内核模式）。

通过类似的方式，OS在启动时设置陷阱处理程序（陷阱表）并启动时钟中断，然后仅在受限模式下运行进程。这样做，OS能确信进程可以高效运行，只在执行特权操作，或者当它们独占CPU时间过长并因此需要切换时，才需要OS干预。



##	07 进程调度：介绍

> 现在，运行进程的底层机制（如上下文切换）应该清楚了。现在，我们还不清楚OS调度程序采用的上层**策略（policy）**。接下来会介绍一系列的调度策略

关键问题：如何开发调度策略

什么是关键假设？哪些指标非常重要？



####	1.工作负载假设

探讨可能的策略范围之前，我们先做一些简化假设。这些假设与系统中运行的进程有关，有时候统称为**工作负载（workload）**。确定工作负载是构建调度策略的关键部分。工作负载了解得越多，你的策略就越优化。

我们这里做的工作负载的假设是不切实际的，但这没问题（目前），因为我们将来会放宽这些假定，并最终开发出我们所谓的 一个完全可操作的调度准则（a fully-operational scheduling discipline）。 

我们对操作系统中运行的进程（有时也叫工作任务）做出如下的假设：

1. 每一个工作运行相同的时间。
2. 所有的工作同时到达。
3. 一旦开始，每个工作保持运行直到完成。
4. 所有的工作只是用 CPU（即它们不执行 IO 操作）。
5. 每个工作的运行时间是已知的。

显然，这些假设很多是不现实的。





####	2.调度指标

**周转时间（turnaround time）：**

任务的周转时间定义为，任务完成时间减去任务到达系统的时间。更正式的周转时间定义是：` 周转时间` = `完成时间`− `到达时间`

因为我们假设所有的任务在同一时间到达，那么 到达时间= 0，因此 周转时间= 完成时间。随 着我们放宽上述假设，这个情况将改变。 你应该注意到，周转时间是一个**性能（performance）指标**，这将是本章的首要关注点。





####	3.先进先出（FIFO）

我们可以实现的最基本的算法，被称为**先进先出（First In First Out 或 FIFO）调度**，有 时候也称为**先到先服务（First Come First Served 或 FCFS）**。

FIFO 有一些积极的特性：它很简单，而且易于实现。而且，对于我们的假设，它的效果很好。

但是它的周转时间是一个致命的缺点：

![image-20230329231826725](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230329231826725.png)

这个问题通常被称为**护航效应（convoy effect）**，一些耗时较少的潜在资源消费者被排在重量级的资源消费者之后。这个调度方案可能让你想起在杂货店只有一个排队队伍的时候，如果看到前面的人装满 3 辆购物车食品并且掏出了支票本，你感觉如何？



####	4.最短任务优先（SJF）

事实证明，一个非常简单的方法解决了这个问题。实际上这是从运筹学中借鉴的一个想法，然后应用到计算机系统的任务调度中。这个新的调度准则被称为**最短任务优先（Shortest Job First，SJF）**，该名称应该很容易记住，因为它完全描述了这个策略： **先运行最短的任务，然后是次短的任务，如此下去。**

如果我们放宽假设；工作可以随时到达，而不是同时到达，这又会出现新的问题：

![image-20230329232058743](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230329232058743.png)

从图中可以看出，即使 B 和 C 在 A 之后不久到达，它们仍然被迫等到 A 完成，从而遭遇同样的**护航问题**。



####	5.最短完成时间优先（STCF）

为了解决这个问题，我们继续放宽假设（工作必须保持运行直到完成）。

鉴于我们先前关于**时钟中断**和**上下文切换**的讨论，当 B 和 C 到达时，调度程序当然可以做其他事情：它可以**抢占（preempt）**工作 A，并 决定运行另一个工作，或许稍后继续工作 A。根据我们的定义，**SJF 是一种非抢占式 （non-preemptive）调度程序，因此存在上述问题。**



幸运的是，有一个调度程序完全就是这样做的：向 SJF 添加抢占，称为**最短完成时间优先（Shortest Time-to-Completion First，STCF）**或抢占式最短作业优先（Preemptive Shortest Job First ，PSJF）调度程序。每当新工作进入系统时，它就会确定剩余工作和新工作中， 谁的剩余时间最少，然后调度该工作。因此，在我们的例子中，STCF 将抢占 A 并运行 B 和 C 以完 成。只有在它们完成后，才能调度 A 的剩余时间：

![image-20230329232329320](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230329232329320.png)

如果所用工作同时到达，SJF是最优的。如果不是同时到达，显然STCF是最优的





####	6.新度量指标：响应时间

用户会坐在终端前面，同时也要求系统的交互性好。因此，一个新的度量标准诞生了：**响应时间（response time）**。 响应时间定义为从任务到达系统到首次运行的时间。更正式的定义是： T 响应时间= T 首次运行−T 到达时间



STCF 和相关方法在响应时间上并不是很好。例如，如果 3 个工作同时到 达，第三个工作必须等待前两个工作全部运行后才能运行。这种方法虽然有很好的周转时 间，但对于响应时间和交互性是相当糟糕的。假设你在终端前输入，不得不等待 10s 才能看 到系统的回应，只是因为其他一些工作已经在你之前被调度：你肯定不太开心。



####	7.轮转

为了解决这个问题，我们将介绍一种新的调度算法，通常被称为**轮转（Round-Robin， RR）调度**。基本思想很简单：RR 在一个时间片（time slice，有时称为调度量子，scheduling quantum）内运行一个工作，然后切换到运行队列中的下一个任务，而不是运行一个任务直到结束。它反复执行，直到所有任务完成。因此，RR 有时被称为时间切片（time-slicing）。 请注意，时间片长度必须是时钟中断周期的倍数。因此，如果时钟中断是每 10ms 中断一次， 则时间片可以是 10ms、20ms 或 10ms 的任何其他倍数。

![image-20230329232629440](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230329232629440.png)

如你所见，时间片长度对于 RR 是至关重要的。越短，RR 在响应时间上表现越好。然而，时间片太短是有问题的：**突然上下文切换的成本将影响整体性能**。因此，系统设计者 需要权衡时间片的长度，使其足够长，以便**摊销（amortize）**上下文切换成本，而又不会使 系统不及时响应。

![image-20230329232722545](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230329232722545.png)

如果响应时间是我们的唯一指标，那么带有合理时间片的 RR，就会是非常好的调度程序。但是我们老朋友的周转时间呢？



如果周转时间是我们的指标，那么 RR 确实是最糟糕的策略之一。直观地说，这应该是有意义的：RR 所做的正是延伸每个工作，只运行每个工作一小段时间，就转 向下一个工作。因为周转时间只关心作业何时完成，RR 几乎是最差的，在很多情况下甚至比简单的 FIFO 更差。



更一般地说，任何公平（fair）的政策（如 RR），即在小规模的时间内将 CPU 均匀分配到活动进程之间，在周转时间这类指标上表现不佳。事实上，这是固有的权衡：**如果你愿意不公平，你可以运行较短的工作直到完成，但是要以响应时间为代价。如果你重视公平 性，则响应时间会较短，但会以周转时间为代价。**这种权衡在系统中很常见。鱼和熊掌不能兼得。

接下来我们还有两个假设需要放宽：作业没有I/O和每个作业运行时间是已知的。



####	8.结合I/O

调度程序显然要在工作发起 I/O 请求时做出决定，因为当前正在运行的作业在 I/O 期间不会使用 CPU，它被阻塞等待 I/O 完成。如果将 I/O 发送到硬盘驱动器，则进程可能会被阻塞几毫秒或更长时间，具体取决于驱动器当前的 I/O 负载。因此，这时调度程序应该在 CPU 上安排另一项工作。 调度程序还必须在 I/O 完成时做出决定。发生这种情况时，会产生中断，操作系统运行 并将发出 I/O 的进程从阻塞状态移回就绪状态。当然，它甚至可以决定在那个时候运行该项 工作。操作系统应该如何处理每项工作？



一种常见的方法是将 A 的每个 10ms 的子工作视为一项独立的工作。因此，当系统启动 时，它的选择是调度 10ms 的 A，还是 50ms 的 B。对于 STCF，选择是明确的：选择较短的 一个，在这种情况下是 A。然后，A 的工作已完成，只剩下 B，并开始运行。然后提交 A 的一个新子工作，它抢占 B 并运行 10ms。这样做可以实现**重叠（overlap）**，一个进程在等 待另一个进程的 I/O 完成时使用 CPU，系统因此得到更好的利用：

![image-20230329233148222](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230329233148222.png)



这样我们就看到了调度程序可能如何结合 I/O。通过将每个 CPU 突发作为一项工作， 调度程序确保“交互”的进程经常运行。当这些交互式作业正在执行 I/O 时，其他 CPU 密 集型作业将运行，从而更好地利用处理器。



####	9.无法预知

有了应对 I/O 的基本方法，我们来到最后的假设：调度程序知道每个工作的长度。如前所述，这可能是可以做出的最糟糕的假设。事实上，在一个通用的操作系统中（比如我们 所关心的操作系统），操作系统通常对每个作业的长度知之甚少。



####	10.小结

我们介绍了调度的基本思想，并开发了两类方法。第一类是**运行最短的工作**，从而**优化周转时间**。第二类是**交替运行所有工作**，从而**优化响应时间**。但很难做到“鱼与熊掌兼 得”，这是系统中常见的、固有的折中。我们也看到了如何将 I/O 结合到场景中，但仍未解决操作系统根本无法看到未来的问题。稍后，我们将看到如何通过构建一个调度程序，利用最近的历史预测未来，从而解决这个问题。这个调度程序称为**多级反馈队列**，是第 8 章的主题。





##	08 调度：多级反馈队列

> 多级反馈队列（Multi-level Feedback Queue，MLFQ），是一种著名的调度方法，由1962年首次提出。
>
> 多级反馈队列需要解决两方面的问题；首先，它要**优化周转时间**，这通过先执行短工作来完成。然而，OS通常不知道工作要运行多久，这又是**SJF**或**STCF**等算法所必需的。其次，MLFQ希望给交互用户很好的交互体验，因此需要**降低响应时间**。然而，像**轮转**这样的算法虽然降低了响应时间，周转时间却很差。所以这里的问题是：**通常我们对进程一无所知，应该如何构建调度程序来实现这些目标？调度程序如何在运行过程中学习进程的特征，从而做出更好的调度决策？**

关键问题：没有完备的知识如何调度？

没有工作长度的先验知识，如何设计一个能同时减少响应时间和周转时间的调度程序？

![image-20230330123004855](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230330123004855.png)



####	1.MLFQ：基本规则

MLFQ 中有许多独立的**队列（queue）**，每个队列有不同的**优先级（priority level）**。任何 时刻，一个工作只能存在于一个队列中。MLFQ 总是优先执行较高优先级的工作（即在较高级队列中的工作）。

当然，每个队列中可能会有多个工作，因此具有同样的优先级。在这种情况下，我们 就对这些工作采用**轮转调度**。

因此，MLFQ 调度策略的关键在于如何**设置优先级**。MLFQ 没有为每个工作指定不变的优先情绪而已，而是根据观察到的行为调整它的优先级。例如，如果一个工作不断放弃 CPU 去等待键盘输入，这是交互型进程的可能行为，MLFQ 因此会让它保持高优先级。相 反，如果一个工作长时间地占用 CPU，MLFQ 会降低其优先级。通过这种方式，MLFQ 在 进程运行过程中学习其行为，从而利用工作的历史来预测它未来的行为。

至此，我们得到了 MLFQ 的两条基本规则。 

**规则 1：如果 A 的优先级 > B 的优先级，运行 A（不运行 B）。** 

**规则 2：如果 A 的优先级 = B 的优先级，轮转运行 A 和 B。**

![image-20230330123310581](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230330123310581.png)



####	2.尝试1：如何改变优先级

我们必须决定，在一个工作的生命周期中，MLFQ 如何改变其优先级（在哪个队列中）。 要做到这一点，我们必须记得工作负载：既有运行时间很短、频繁放弃 CPU 的交互型工作， 也有需要很多 CPU 时间、响应时间却不重要的长时间计算密集型工作。下面是我们第一次 尝试优先级调整算法：

**规则 3：工作进入系统时，放在最高优先级（最上层队列）。** 

**规则 4a：工作用完整个时间片后，降低其优先级（移入下一个队列）。** 

**规则 4b：如果工作在其时间片以内主动释放 CPU， 则优先级不变。**



**实例 1：单个长工作**

我们来看一些例子。首先，如果系统中有一个需要长 时间运行的工作，看看会发生什么：

![image-20230330123904908](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230330123904908.png)

从这个例子可以看出，该工作首先进入最高优先级 （Q2）。执行一个 10ms 的时间片后，调度程序将工作的优先 级减 1，因此进入 Q1。在 Q1 执行一个时间片后，最终降低优先级进入系统的最低优先级 （Q0），一直留在那里。相当简单，不是吗？



**实例 2：来了一个短工作** 

再看一个较复杂的例子，看看 MLFQ 如何近似 SJF。在这个例子中，有两个工作：A 是一个长时间运行的 CPU 密集型工作，B 是一个运行时间很短的交互型工作。假设 A 执行 一段时间后 B 到达。会发生什么呢？对 B 来说，MLFQ 会近似于 SJF 吗？

![image-20230330123943611](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230330123943611.png)

通过这个例子，你大概可以体会到这个算法的一个主要目标：**如果不知道工作是短工作还是长工作，那么就在开始的时候假设其是短工作，并赋予最高优先级。**如果确实是短 工作，则很快会执行完毕，否则将被慢慢移入低优先级队列，而这时该工作也被认为是长 工作了。通过这种方式，MLFQ 近似于 SJF。



**实例 3：如果有 I/O 呢** 

看一个有 I/O 的例子。根据上述规则 4b，如果进程在时间片用完之前主动放弃 CPU， 则保持它的优先级不变。这条规则的意图很简单：假设交互型工作中有大量的 I/O 操作（比 如等待用户的键盘或鼠标输入），它会在时间片用完之前放弃 CPU。在这种情况下，我们不想处罚它，只是保持它的优先级不变：

![image-20230330124100713](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230330124100713.png)





**当前 MLFQ 的一些问题**

至此，我们有了基本的 MLFQ。它看起来似乎相当不错，长工作之间可以公平地分享CPU，又能给短工作或交互型工作很好的响应时间。然而，这种算法有一些非常严重的缺点；

首先，会有**饥饿（starvation）问题**。如果系统有“太多”交互型工作，就会不断占用 CPU，导致**长工作永远无法得到 CPU（它们饿死了）**。即使在这种情况下，我们希望这些长工作也能有所进展。 

其次，聪明的用户会重写程序，**愚弄调度程序（game the scheduler）**。愚弄调度程序指 的是用一些卑鄙的手段欺骗调度程序，让它给你远超公平的资源。上述算法对如下的攻击束手无策：**进程在时间片用完之前，调用一个 I/O 操作（比如访问一个无关的文件），从而主动释放CPU。如此便可以保持在高优先级，占用更多的 CPU 时间。**做得好时（比如，每 运行 99%的时间片时间就主动放弃一次 CPU），工作可以几乎独占 CPU。

最后，**一个程序可能在不同时间表现不同**。**一个计算密集的进程可能在某段时间表现为一个交互型的进程。用我们目前的方法，它不会享受系统中其他交互型工作的待遇。**





####	3.尝试2：提升优先级

让我们试着改变之前的规则，看能否避免**饥饿问题**。要让 CPU 密集型工作也能取得一些进展（即使不多），我们能做些什么？



一个简单的思路是**周期性地提升（boost）所有工作的优先级**。可以有很多方法做到， 但我们就用最简单的：将所有工作扔到最高优先级队列。于是有了如下的新规则。



 **规则 5：经过一段时间 S，就将系统中所有工作重新加入最高优先级队列。**



新规则一下**解决了两个问题**。首先，进程不会饿死——在最高优先级队列中，它会以**轮转**的方式，与其他高优先级工作分享 CPU，从而最终获得执行。其次，如果一个 CPU 密集型工作变成了交互型，当它优先级提升时，调度程序会正确对待它。



![image-20230330124506545](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230330124506545.png)

当然，添加时间段 S 导致了明显的问题：S 的值应该如何设置？德高望重的系统研究员John Ousterhout曾将这种值称为“**巫毒常量（voo-doo constant）**”，因为似乎需要一些黑魔法才能正确设置。**如果 S 设置得太高，长工作会饥饿；如果设置得太低，交互型工作又得不到合适的 CPU 时间比例。**



####	4.尝试3：更好的计时方式

现在还有一个问题要解决：**如何阻止调度程序被愚弄？**可以看出，这里的元凶是规则 4a 和 4b，导致工作在时间片以内释放 CPU，就保留它的优先级。那么应该怎么做？ 

这里的解决方案，是为 MLFQ 的每层队列提供更完善的 CPU **计时方式（accounting**）。 调度程序应该记录一个进程在某一层中消耗的总时间，而不是在调度时重新计时。只要进程用完了自己的配额，就将它降到低一优先级的队列中去。不论它是一次用完的，还是拆成很多次用完。因此，我们重写规则 4a 和 4b。

**规则 4：一旦工作用完了其在某一层中的时间配额（无论中间主动放弃了多少次 CPU），就降低其优先级（移入低一级队列）。**



来看一个例子。图 8.6 对比了在规则 4a、4b 的策略下（左图），以及在新的规则 4（右图）的策略下，同样试图愚弄调度程序的进程的表现。没有规则 4 的保护时，进程可以在 每个时间片结束前发起一次 I/O 操作，从而垄断 CPU 时间。有了这样的保护后，**不论进程 的 I/O 行为如何，都会慢慢地降低优先级，因而无法获得超过公平的 CPU 时间比例。**

![image-20230330130301278](C:\Users\guoxiang\AppData\Roaming\Typora\typora-user-images\image-20230330130301278.png)



####	5.MLFQ调优及其他问题

关于 MLFQ 调度算法还有一些问题；其中一个大问题是如何配置一个调度程序，例如， **配置多少队列？每一层队列的时间片配置多大？为了避免饥饿问题以及进程行为改变，应该多久提升一次进程的优先级？**这些问题都没有显而易见的答案，因此只有利用对工作负载的经验，以及后续对调度程序的调优，才会导致令人满意的平衡。







####	6.MLFQ：小结

本章介绍了一种调度方式，名为**多级反馈队列（MLFQ）**。你应该已经知道它为什么叫 这个名字——它有多级队列，并**利用反馈信息决定某个工作的优先级。以史为鉴：关注进程的一贯表现，然后区别对待。**



本章包含了一组优化的 MLFQ 规则。为了方便查阅，我们重新列在这里。

- **规则 1：如果 A 的优先级 > B 的优先级，运行 A（不运行 B）。** 
- **规则 2：如果 A 的优先级 = B 的优先级，轮转运行 A 和 B。** 
- **规则 3：工作进入系统时，放在最高优先级（最上层队列）。** 
- **规则 4：一旦工作用完了其在某一层中的时间配额（无论中间主动放弃了多少次 CPU），就降低其优先级（移入低一级队列）。** 
- **规则 5：经过一段时间 S，就将系统中所有工作重新加入最高优先级队列。**



MLFQ 有趣的原因是：**它不需要对工作的运行方式有先验知识，而是通过观察工作的运行来给出对应的优先级。**通过这种方式，MLFQ 可以同时满足各种工作的需求：**对于短时间运行的交互型工作，获得类似于 SJF/STCF 的很好的全局性能，同时对长时间运行的 CPU 密集型负载也可以公平地、不断地稳步向前。**因此，许多系统使用某种类型的 MLFQ 作为自己的基础调度程序，包括类 BSD UNIX 系统、Solaris以及 Windows NT 和其后的 Window 系列操作系统。







##	09 调度：比例分配

在本章中，我们来看一个不同类型的调度程序——**比例份额（proportional-share）调度**程序，有时也称为**公平份额（fair-share）调度**程序。比例份额算法基于一个简单的想法：**调度程序的最终目标，是确保每个工作获得一定比例的 CPU 时间，而不是优化周转时间和响应时间。**







####	7.小结

本章介绍了比例份额调度的概念，并简单讨论了两种实现：**彩票调度**和**步长调度**。 **彩票调度通过随机值，聪明地做到了按比例分配。步长调度算法能够确定的获得需要的比例**。虽然两者都很有趣，但由于一些原因，并没有作为 CPU 调度程序被广泛使用。**一 个原因是这两种方式都不能很好地适合 I/O；另一个原因是其中最难的票数分配问题并没有确定的解决方式，**例如，如何知道浏览器进程应该拥有多少票数？通用调度程序（像前面讨论的 MLFQ 及其他类似的 Linux 调度程序）做得更好，因此得到了广泛的应用。 

结果，比例份额调度程序只有在这些问题可以相对容易解决的领域更有用（例如容易 确定份额比例）。例如在虚拟（virtualized）数据中心中，你可能会希望分配 1/4 的 CPU 周 期给 Windows 虚拟机，剩余的给 Linux 系统，比例分配的方式可以更简单高效。



##	10 多处理器调度（高级）







##	11 关于CPU虚拟化的总结对话

我学到了什么？

首先，我了解了OS如何虚拟化CPU。为了理解这一点，我必须了解一些重要的机制：陷阱和陷阱处理程序，时钟中断以及OS和硬件在进程间切换时如何谨慎地保存和恢复状态。OS希望确保控制机器；虽然它希望程序能够尽可能地高效运行`受限直接执行（limited direct execution）`，但OS也希望能够对错误或恶意地程序说不。这也许就是我们将OS视为资源管理器地原因

其次，在机制之上地策略，可以建立一个既像SJF又像RR地调度程序（MLFQ）。





##	12 关于内存虚拟化的对话
