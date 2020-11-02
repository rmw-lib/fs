#!/usr/bin/env coffee

import fs from 'fs'
import {decompressSync} from 'cppzst'
import {join} from 'path'


export load = (dirli, fileli, count_li, prefix)->
  if not count_li.length
    return

  [dirn,filen] = count_li.splice(0,2)

  for i from fileli.splice(0, filen)
    yield join(prefix, i)

  if dirn # 0 是虚拟目录，需要从外部加载目录列表
    dirn = dirn - 1

    for i from dirli.splice(0,dirn)
      yield from load(dirli, fileli, count_li, join(prefix,i))

export default ([li, count_li] )->

  li=li.split("\n")

  n = (count_li.length>>1)-1
  dirli = li[...n]
  fileli = li[n..]

  yield from load(dirli, fileli, count_li,"")

