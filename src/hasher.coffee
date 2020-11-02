import fs from 'fs'
import b64path from './b64path'
import blake from 'blake3'
import {DATA} from './const.mjs'
import {dirname, join} from 'path'
import ENV from '@rmw/env'

HASH = join DATA, "hash"

export write = (hash, buf)=>
  outpath = join HASH, b64path(hash)
  if not fs.existsSync(outpath)
    fs.mkdirSync(dirname(outpath),{recursive:true})
    fs.writeFileSync(outpath, buf)
  return

export class Hasher
  constructor:->
    @_ = blake.createHash()
    @cache = []

  update:(buf)->
    @_.update buf
    @cache.push buf
    return @

  digest:->
    h = @_.digest()
    write h, Buffer.concat @cache
    h
