<div align="center">

<img src=".github/logo.png">

## 铁暮秋
*一个俯瞰世界的机器人*

</div>

## 构建和运行
铁暮秋通过 [./pom.ml](./pom.ml) 统一管理所有的模块，可以通过
- `./pom.ml setup` 自动安装所有模块的依赖
- `./pom.ml build` 自动构建所有模块
- `./pom.ml start` 启动所有模块（即启动铁暮秋）


## 开发文档
### 架构
铁暮秋整体由三个模块组成：Core，Client，Service，各司其职：
- Core是铁暮秋的核心，用于调度Client与Service之间的数据交换
- Client是铁暮秋的接收外界信息的主要方式
- Service是铁暮秋向外界做出反馈的主要方式

...

## 开源协议
The MIT License (MIT)

Copyright (c) 2022 Muqiu Han

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.