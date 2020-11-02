<!-- 本文件由 ./readme.make.md 自动生成，请不要直接修改此文件 -->

# @rmw/dirtree

##  安装

```
yarn add @rmw/dirtree
```

或者

```
npm install @rmw/dirtree
```

## 使用

```coffee
#!/usr/bin/env coffee
import dump from '@rmw/dirtree/dump'
import load from '@rmw/dirtree/load'
import fs from 'fs'
import {thisdir} from '@rmw/thisfile'
import {dirname} from 'path'
import path from 'path'
import Bls from '@rmw/dirtree/bls'
import os from 'os'

do =>
  bls_private = path.join os.homedir(), ".config/rmw/id_bls"
  r = await dump dirname(thisdir `import.meta`), await Bls(bls_private)
  for i from load r
    console.log i
    # if not fs.existsSync(i)
    #   console.log i

```

## 关于

本项目隶属于**人民网络([rmw.link](//rmw.link))** 代码计划。

![人民网络](https://raw.githubusercontent.com/rmw-link/logo/master/rmw.red.bg.svg)
