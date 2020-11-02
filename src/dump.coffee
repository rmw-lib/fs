#!/usr/bin/env coffee

import blake from 'blake3'
import fs from 'fs-extra'
import {pack} from 'msgpackr'
import {join} from 'path'
import ignore from './ignore'
import {compress} from 'cppzst'
import Meta from './meta'
import {DATA, CACHE} from './const.mjs'
import b64path from './b64path'
import int2buf from './int2buf'
import BASE64 from 'urlsafe-base64'

export dump = (dirpath, meta, ig)=>
  dirli = []
  fileli = []
  metali = []

  todo = []

  for await i from await fs.promises.opendir(dirpath)
    {name} = i

    filepath = dirpath+"/"+name
    if ig(filepath)
      continue
    if i.isDirectory()
      dirli.push name
    else if i.isFile()
      fileli.push name

  dirli.sort()
  fileli.sort()

  for name from fileli
    metali.push meta(dirpath+"/"+name)

  metali = await Promise.all metali

  for name from dirli
    todo.push dump(
      dirpath+"/"+name, meta, ig
    )

  countli = [dirli.length+1, fileli.length]

  r = [dirli, fileli, countli, metali]
  for li from await Promise.all(todo)
    for i,pos in li
      r[pos] = r[pos].concat i
  r

DATA_V = DATA+"/"+"v/"

export default (dirpath, key)=>
  meta = await Meta(dirpath, key)
  ig = ignore(dirpath)
  r = await dump(dirpath, meta, ig)

  metali = r[3]
  hashli = []

  for [size, mtime, hash] from metali
    hashli.push hash

  r = [
    r[0].concat(r[1]).join("\n")
  ].concat r[2..]

  {pubhashpath} = key
  await fs.outputFile(
    join(CACHE, "st", pubhashpath)
    await compress(pack(r))
  )

  v = await compress(pack(r[..1].concat [hashli]), level:19)
  vhash = blake.hash v
  vb64 = b64path vhash

  dir = DATA_V+pubhashpath+"/"
  await fs.outputFile(
    dir+vb64
    v
  )
  pub = dir+"pub"

  if not await fs.exists pub
    await fs.outputFile pub, key.pubbin

  now = parseInt new Date()/1000
  nowbin = int2buf now
  await fs.outputFile dir+"v.ts", nowbin

  f = (new Date(now*1000)).toISOString()[..18].replace(/-/g,'/').replace("T","/").replace(/:/g,".")

  # 签名长度48字节
  await fs.outputFile(
    dir+"!/"+f
    Buffer.concat([
      vhash
      key.sign Buffer.concat [nowbin,vhash]
    ])
  )

  r

