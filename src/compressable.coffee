import {readSync, openSync, closeSync, promises as fs} from 'fs'
import {compress }from 'cppzst'
import {MB} from './const.mjs'

export IGNORE = new Set()

do =>
  for i in """xz bz2 lzma 7z aac ape avif flac flv mp3 mp4 mpg ogg png rar rm webp wma wmv""".split(' ')
    IGNORE.add(i)

export default (filepath)=>
  n = filepath.lastIndexOf('.')
  if n>0
    if IGNORE.has(filepath[n+1..].toLowerCase())
      return false

  {size} = await fs.stat filepath
  if size < 256
    return false
  buflen = Math.min(MB,size)
  buf = Buffer.allocUnsafe buflen
  fd = openSync filepath,"r"
  try
    readSync fd,buf
    p = await compress buf, level:1
    return buflen > (1.1*p.length)
  finally
    closeSync(fd)
  return false

