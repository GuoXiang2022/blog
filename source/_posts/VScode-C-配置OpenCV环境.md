---
title: VScode C++ 配置OpenCV环境
date: 2023-05-17 00:04:58
tags:
    -OpenCV
    -环境配置
---

####	在VScode上配置C++ OpenCV环境



####	1.资源下载

- OpenCV

  下载4.6.0及以下版本。最新版4.7.0CMake编译不过，不清楚原因。

  下载链接：https://opencv.org/releases/

- CMake

  下载二进制版Binary distributions

  下载链接：https://cmake.org/download/

- MinGW

  下载x86_64-8.5.0-release-posix-seh-rt_v10-rev0.7z版本。最新版不知道为什么也编译不过，这里注意，gcc -v后其Thread model：posix。如果是win32，编译opencv时会报mutex错误。

  下载链接：https://github.com/niXman/mingw-builds-binaries/releases

​		

####	2.设置MinGW环境变量

- 将MinGW的bin目录配置到系统环境变量中。

  

####	3.使用CMake gui开始编译

- 选择源代码路径，以及编译后的路径。点Configure，弹出来的窗口选择MinGW，勾选第二个。

- 然后继续点击Configure
- 打开...\opencv\build\x64\mingw\CMakeDownloadLog.txt，下载缺失的四个文件
- 勾选BULID_opencv_world，WITH_OPENGL和BUILD_EXAMPLES
- 不勾选WITH_IPP，WITH_MSMF，D3*。CPU_DISPATCH选空
- 点击Configure，没有问题后点击 Generate
- cmd进入...\opencv\build\x64\mingw\，输入**mingw32-cake   -j8**开始编译。
- 如果编译执行到100%，则输入**mingw32-make install**



####	4.将编译后的OpenCV文件加入到系统环境变量

- 如：C:\opencv\opencv4dot6\opencv\build\x64\mingw\bin



####	5.配置VScode文件

- c_cpp_properties.json

  ```json
  {
      "configurations": [
          {
              "name": "Win32",
              "includePath": [
                  "${workspaceFolder}/**",
                  "C:/opencv/opencv4dot6/opencv/build/x64/mingw/install/include",
                  "C:/opencv/opencv4dot6/opencv/build/x64/mingw/install/include/opencv2"
              ],
              "defines": [
                  "_DEBUG",
                  "UNICODE",
                  "_UNICODE"
              ],
              "compilerPath": "G:/MinGW/mingw85/mingw64/bin/gcc.exe",
              "cStandard": "c17",
              "cppStandard": "gnu++17",
              "intelliSenseMode": "windows-gcc-x64"
          }
      ],
      "version": 4
  }
  ```

  

- tasks.json

  ```json
  {
      "version": "2.0.0",
      "command": "g++",
      "args": ["-g",
          "${file}",
          "-o",
          "${file}.exe",
          "C:/opencv/opencv4dot6/opencv/build/x64/mingw/bin/libopencv_world460.dll",
          "-I",
          "C:/opencv/opencv4dot6/opencv/build/x64/mingw/install/include",
          "-I",
          "C:/opencv/opencv4dot6/opencv/build/x64/mingw/install/include/opencv2"],    // 编译命令参数
      "problemMatcher": {
          "owner": "cpp",
          "fileLocation": ["relative", "${workspaceRoot}"],
          "pattern": {
              "regexp": "^(.*):(/d+):(/d+):/s+(warning|error):/s+(.*)$",
              "file": 1,
              "line": 2,
              "column": 3,
              "severity": 4,
              "message": 5
          }
      }
  }
  
  ```

  

- launch.json

  ```json
  {
      "version": "0.2.0",
      "configurations": [{
          "name": "C++ Launch (GDB)", // 配置名称，将会在启动配置的下拉菜单中显示
          "type": "cppdbg", // 配置类型，这里只能为cppdbg
          "request": "launch", // 请求配置类型，可以为launch（启动）或attach（附加）
          "targetArchitecture": "x86", // 生成目标架构，一般为x86或x64，可以为x86, arm, arm64, mips, x64, amd64, x86_64
          "program": "${file}.exe", // 将要进行调试的程序的路径
          //"miDebuggerPath": "C:/Program Files/MinGW/bin/gdb.exe", // miDebugger的路径，注意这里要与MinGw的路径对应
          "miDebuggerPath": "G:/MinGW/mingw85/mingw64/bin/gdb.exe", // miDebugger的路径，注意这里要与MinGw的路径对应
          "args": [], // 程序调试时传递给程序的命令行参数，一般设为空即可
          "stopAtEntry": false, // 设为true时程序将暂停在程序入口处，一般设置为false
          "cwd": "${fileDirname}", // 调试程序时的工作目录，一般为${workspaceRoot}即代码所在目录
          "externalConsole": true, // 调试时是否显示控制台窗口，一般设置为true显示控制台
          "preLaunchTask": "g++",// 调试会话开始前执行的任务，一般为编译程序，c++为g++, c为gcc
      }]
  }
  
  ```



####	6.重启VScode



