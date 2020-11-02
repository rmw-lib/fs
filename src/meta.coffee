import {unpack} from 'msgpackr'
import compressable from './compressable'
import {decompress} from 'cppzst'
import {CACHE} from './const.mjs'
import blake from 'blake3'
import {existsSync, createReadStream, promises as fs} from 'fs'
import {compressStream} from 'cppzst'
import {MB,Hash,BufferStreamLi} from '@rmw/merkle'
import {Hasher, write} from './hasher'
import {join} from 'path'
import load from './load'

FLAG_COMPRESS = 0b1
FLAG_HASHTREE = 0b10

_cached = (key)=>
  path_st = new Map()

  p = join(CACHE, "st", key.pubhashpath)
  if existsSync p
    li = unpack await decompress await fs.readFile(p)
    metali = li.pop()
    n = 0
    for i from load(li)
      path_st.set i, metali[n++]

  path_st

export default (dirpath, key)=>
  st = await _cached(key)
  dlen = dirpath.length+1

  (filepath)=>
    {size, mtime} = await fs.stat filepath
    mtime -= 0
    size_mtime = st.get(filepath[dlen..])
    if size_mtime
      if size==size_mtime[0] and mtime==size_mtime[1]
        return size_mtime

    s = createReadStream(filepath)
    flag = 0
    if await compressable(filepath, size)
      flag |= FLAG_COMPRESS
      s.pipe(compressStream(level:19))

    blake_stream = new Hash(=>new Hasher())
    bsli = new BufferStreamLi()
    s.pipe(blake_stream).pipe(bsli)

    new Promise (resolve)=>
      bsli.on 'finish', ->
        {_} = @
        if _.length > 1
          flag |= FLAG_HASHTREE
          buf = Buffer.concat(_)
          hash = blake.hash buf
          write hash, buf
        else
          hash = _[0]

        resolve [
          size
          mtime
          Buffer.concat [
            hash
            Buffer.from [flag]
          ]
        ]

